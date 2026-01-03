import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:swiftbill_app/theme_manager.dart';
import 'package:swiftbill_app/premium_manager.dart';
import 'package:swiftbill_app/home_page.dart';
import 'login_page.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🔥 Starting Firebase initialization...');
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully!');
  } catch (e, stackTrace) {
    print('❌ Firebase initialization failed!');
    print('Error: $e');
    print('Stack trace: $stackTrace');
  }
  
  runApp(const SwiftBillApp());
}

class SwiftBillApp extends StatefulWidget {
  const SwiftBillApp({super.key});

  @override
  State<SwiftBillApp> createState() => _SwiftBillAppState();
}

class _SwiftBillAppState extends State<SwiftBillApp> {
  final ThemeManager _themeManager = ThemeManager();
  final PremiumManager _premiumManager = PremiumManager();

  @override
  void initState() {
    super.initState();
    _themeManager.addListener(_onThemeChanged);
    _premiumManager.addListener(_onPremiumChanged);
    
    // Listen to auth state changes for debugging
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        print('🔓 User is currently signed out');
      } else {
        print('🔐 User is signed in: ${user.email ?? "Anonymous"}');
        print('   UID: ${user.uid}');
        print('   Display Name: ${user.displayName ?? "None"}');
      }
    });
  }

  @override
  void dispose() {
    _themeManager.removeListener(_onThemeChanged);
    _premiumManager.removeListener(_onPremiumChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    setState(() {});
  }

  void _onPremiumChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeManager.lightTheme.copyWith(
        textTheme: GoogleFonts.interTextTheme(
          ThemeManager.lightTheme.textTheme,
        ),
      ),
      darkTheme: ThemeManager.darkTheme.copyWith(
        textTheme: GoogleFonts.interTextTheme(
          ThemeManager.darkTheme.textTheme,
        ),
      ),
      themeMode: _themeManager.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      
      // FIXED: Better StreamBuilder implementation
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          print('🔄 Auth State Update: ${snapshot.connectionState}');
          
          // Show loading while checking auth state
          if (snapshot.connectionState == ConnectionState.waiting) {
            print('⏳ Waiting for auth state...');
            return const Scaffold(
              backgroundColor: Colors.white,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading...'),
                  ],
                ),
              ),
            );
          }
          
          // Check for errors
          if (snapshot.hasError) {
            print('❌ Auth Stream Error: ${snapshot.error}');
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    const Text('Authentication Error'),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            );
          }
          
          // CRITICAL FIX: Check auth state is active before deciding
          final user = snapshot.data;
          final hasUser = snapshot.hasData && user != null;
          
          if (hasUser) {
            print('✅ User authenticated, showing HomePage');
            print('   Email: ${user.email}');
            // IMPORTANT: Return new instance to force rebuild
            return const HomePage(key: ValueKey('home_page'));
          }
          
          // User is not signed in
          print('❌ No user authenticated, showing LoginPage');
          // IMPORTANT: Return new instance to force rebuild
          return const LoginPage(key: ValueKey('login_page'));
        },
      ),
    );
  }
}