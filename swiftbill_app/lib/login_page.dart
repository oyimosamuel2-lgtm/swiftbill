import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:swiftbill_app/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool isLoading = false;
  final AuthService _authService = AuthService();
  
  @override
  void initState() {
    super.initState();
    
    // CRITICAL FIX: Reset loading state when page initializes
    isLoading = false;
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final String googleSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 533.5 544.3">
  <path d="M533.5 278.4c0-18.5-1.5-37.1-4.7-55.3H272.1v104.8h147c-6.1 33.8-25.7 63.7-54.4 82.7v68h87.7c51.5-47.4 81.1-117.4 81.1-200.2z" fill="#4285f4"/>
  <path d="M272.1 544.3c73.4 0 135-24.1 180.4-65.7l-87.7-68c-24.4 16.6-55.9 26-92.6 26-71 0-131-48-152.8-112.3H28.9v70.1c46.2 91.9 140.3 149.9 243.2 149.9z" fill="#34a853"/>
  <path d="M119.3 324.3c-11.4-33.8-11.4-70.4 0-104.2V150H28.9c-38.6 76.9-38.6 167.5 0 244.4l90.4-70.1z" fill="#fbbc04"/>
  <path d="M272.1 107.7c38.8 0 76.3 13.4 104.4 40.8l77.7-77.7C405 24.6 339.7 0 272.1 0 169.2 0 75.1 58 28.9 150l90.4 70.1c21.8-64.3 81.8-112.4 152.8-112.4z" fill="#ea4335"/>
</svg>
''';
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF2563EB).withOpacity(0.1),
              const Color(0xFF8B5CF6).withOpacity(0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(Icons.bolt, color: Colors.white, size: 40),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          "SwiftBill",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Professional invoicing made simple",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 15,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40),
                        _socialButton(
                          "Continue with Google",
                          SvgPicture.string(googleSvg, width: 24, height: 24),
                          Colors.white,
                          Colors.black,
                          () => _handleGoogleLogin(context),
                        ),
                        const SizedBox(height: 12),
                        _socialButton(
                          "Continue with Apple",
                          const Icon(Icons.apple, color: Colors.white),
                          Colors.black,
                          Colors.white,
                          () => _handleAppleLogin(context),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(child: Divider(color: Colors.grey.shade300)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                "or",
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                              ),
                            ),
                            Expanded(child: Divider(color: Colors.grey.shade300)),
                          ],
                        ),
                        const SizedBox(height: 24),
                        OutlinedButton(
                          onPressed: isLoading ? null : () => _handleGuestLogin(context),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 54),
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Continue as Guest",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          "By continuing, you agree to our Terms of Service and Privacy Policy",
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 11,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _socialButton(
    String text,
    Widget icon,
    Color bgColor,
    Color textColor,
    VoidCallback onPressed,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: bgColor == Colors.white
                ? Colors.black.withOpacity(0.05)
                : Colors.transparent,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          minimumSize: const Size(double.infinity, 54),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: bgColor == Colors.white
                ? BorderSide(color: Colors.grey.shade300)
                : BorderSide.none,
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(textColor),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  icon,
                  const SizedBox(width: 12),
                  Text(
                    text,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
  
  // FIXED: Better state management and cleanup
  void _handleGoogleLogin(BuildContext context) async {
    print('🔵 [${DateTime.now()}] Google login initiated');
    
    // Prevent multiple simultaneous login attempts
    if (isLoading) {
      print('⚠️ Login already in progress, ignoring duplicate request');
      return;
    }
    
    setState(() => isLoading = true);
    
    try {
      final startTime = DateTime.now();
      final result = await _authService.signInWithGoogle();
      final signInDuration = DateTime.now().difference(startTime);
      
      print('🔵 [${DateTime.now()}] Sign in completed in ${signInDuration.inMilliseconds}ms');
      print('   Result: ${result != null ? "Success" : "Cancelled"}');
      
      if (result != null) {
        print('✅ User signed in: ${result.user?.email}');
        print('   UID: ${result.user?.uid}');
        
        // Wait for Firebase auth state to propagate
        print('⏳ Waiting for auth state propagation...');
        await Future.delayed(const Duration(milliseconds: 150));
        
        // Double-check that user is actually signed in
        final currentUser = FirebaseAuth.instance.currentUser;
        print('🔍 Current user after delay: ${currentUser?.email ?? "null"}');
        
        if (currentUser != null) {
          print('✅ Auth state confirmed, StreamBuilder should navigate now');
          // Keep loading state - widget will be unmounted when HomePage loads
        } else {
          print('⚠️ Auth state not propagated yet, waiting longer...');
          await Future.delayed(const Duration(milliseconds: 200));
          
          final retryUser = FirebaseAuth.instance.currentUser;
          if (retryUser != null) {
            print('✅ Auth state confirmed on retry');
          } else {
            print('❌ Auth state still null after retry');
            // CRITICAL: Reset loading state if auth failed
            if (mounted) {
              setState(() => isLoading = false);
            }
          }
        }
      } else {
        print('⚠️ User cancelled Google sign-in');
        // CRITICAL: Reset loading state when cancelled
        if (mounted) {
          setState(() => isLoading = false);
        }
      }
    } catch (e) {
      print('❌ Google login error: $e');
      // CRITICAL: Always reset loading state on error
      if (mounted) {
        setState(() => isLoading = false);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${e.toString()}"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }
  
  void _handleAppleLogin(BuildContext context) async {
    print('🍎 Apple login initiated');
    
    if (isLoading) return;
    
    setState(() => isLoading = true);
    
    try {
      final result = await _authService.signInWithApple();
      
      if (result != null) {
        print('✅ User signed in with Apple: ${result.user?.email}');
        await Future.delayed(const Duration(milliseconds: 150));
        // StreamBuilder will handle navigation
      } else {
        if (mounted) {
          setState(() => isLoading = false);
        }
      }
    } catch (e) {
      print('❌ Apple login error: $e');
      if (mounted) {
        setState(() => isLoading = false);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${e.toString()}"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }
  
  void _handleGuestLogin(BuildContext context) async {
    print('👤 Guest login initiated');
    
    if (isLoading) return;
    
    setState(() => isLoading = true);
    
    try {
      await _authService.signInAnonymously();
      print('✅ Guest signed in');
      await Future.delayed(const Duration(milliseconds: 150));
      // StreamBuilder will handle navigation
    } catch (e) {
      print('❌ Guest login error: $e');
      if (mounted) {
        setState(() => isLoading = false);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${e.toString()}"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }
}