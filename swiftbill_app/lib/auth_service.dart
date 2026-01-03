import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  bool get isSignedIn => _auth.currentUser != null;

  Future<UserCredential?> signInWithGoogle() async {
    try {
      // IMPORTANT: First disconnect any existing session
      await _googleSignIn.disconnect().catchError((_) {});
      
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        await _saveUserData(userCredential.user!);
      }

      return userCredential;
    } catch (e) {
      print('Error signing in with Google: $e');
      rethrow;
    }
  }

  Future<UserCredential?> signInWithApple() async {
    try {
      if (!Platform.isIOS && !Platform.isMacOS) {
        throw Exception('Apple Sign In is only available on iOS and macOS');
      }

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final userCredential = await _auth.signInWithCredential(oauthCredential);

      if (userCredential.user != null) {
        await _saveUserData(
          userCredential.user!,
          displayName: appleCredential.givenName != null && appleCredential.familyName != null
              ? '${appleCredential.givenName} ${appleCredential.familyName}'
              : null,
        );
      }

      return userCredential;
    } catch (e) {
      print('Error signing in with Apple: $e');
      rethrow;
    }
  }

  Future<UserCredential?> signInAnonymously() async {
    try {
      final userCredential = await _auth.signInAnonymously();
      
      if (userCredential.user != null) {
        await _saveUserData(userCredential.user!, isGuest: true);
      }
      
      return userCredential;
    } catch (e) {
      print('Error signing in anonymously: $e');
      rethrow;
    }
  }

  Future<void> _saveUserData(
    User user, {
    String? displayName,
    bool isGuest = false,
  }) async {
    try {
      final userDoc = _firestore.collection('users').doc(user.uid);
      final docSnapshot = await userDoc.get();

      if (!docSnapshot.exists) {
        await userDoc.set({
          'uid': user.uid,
          'email': user.email ?? '',
          'displayName': displayName ?? user.displayName ?? (isGuest ? 'Guest User' : 'User'),
          'photoURL': user.photoURL ?? '',
          'isGuest': isGuest,
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
        });
      } else {
        await userDoc.update({
          'lastLogin': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error saving user data: $e');
    }
  }

  Future<Map<String, dynamic>?> getUserData() async {
    try {
      if (currentUser == null) return null;
      final doc = await _firestore.collection('users').doc(currentUser!.uid).get();
      return doc.data();
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  Future<void> updateUserProfile({String? displayName, String? photoURL}) async {
    try {
      if (currentUser == null) return;
      await currentUser!.updateDisplayName(displayName);
      await currentUser!.updatePhotoURL(photoURL);
      await _firestore.collection('users').doc(currentUser!.uid).update({
        if (displayName != null) 'displayName': displayName,
        if (photoURL != null) 'photoURL': photoURL,
      });
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    }
  }

  // COMPLETE FIX FOR SIGN OUT - Forces account picker on next login
  Future<void> signOut() async {
    try {
      print('🔴 Starting sign out process...');
      
      // Step 1: Check if user was signed in with Google
      final wasGoogleUser = currentUser?.providerData.any(
        (info) => info.providerId == 'google.com'
      ) ?? false;
      
      print('Was Google user: $wasGoogleUser');
      
      // Step 2: Sign out from Firebase FIRST
      await _auth.signOut();
      print('✅ Firebase signed out');
      
      // Step 3: CRITICAL - Disconnect Google to clear cached credentials
      if (wasGoogleUser) {
        try {
          // This is the key - disconnect() removes the cached account
          await _googleSignIn.disconnect();
          print('✅ Google disconnected (forces account picker)');
        } catch (e) {
          print('⚠️ Google disconnect error (non-critical): $e');
        }
        
        // Extra cleanup - sign out too
        try {
          await _googleSignIn.signOut();
          print('✅ Google signed out');
        } catch (e) {
          print('⚠️ Google signOut error (non-critical): $e');
        }
      }
      
      // Step 4: Give native side time to process
      await Future.delayed(const Duration(milliseconds: 300));
      
      print('✅ Sign out completed successfully');
    } catch (e) {
      print('❌ Error during signOut: $e');
      rethrow;
    }
  }

  Future<void> deleteAccount() async {
    try {
      if (currentUser == null) return;
      await _firestore.collection('users').doc(currentUser!.uid).delete();
      await currentUser!.delete();
      await signOut();
    } catch (e) {
      print('Error deleting account: $e');
      rethrow;
    }
  }

  Future<UserCredential?> linkWithGoogle() async {
    try {
      if (currentUser == null || !currentUser!.isAnonymous) {
        throw Exception('No anonymous user to link');
      }

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await currentUser!.linkWithCredential(credential);

      await _firestore.collection('users').doc(userCredential.user!.uid).update({
        'isGuest': false,
        'email': userCredential.user!.email,
        'displayName': userCredential.user!.displayName,
        'photoURL': userCredential.user!.photoURL,
      });

      return userCredential;
    } catch (e) {
      print('Error linking account: $e');
      rethrow;
    }
  }
}