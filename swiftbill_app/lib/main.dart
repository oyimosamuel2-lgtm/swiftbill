import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';  // Add this import
import 'login_page.dart';

void main() {
  runApp(const SwiftBillApp());
}

class SwiftBillApp extends StatelessWidget {
  const SwiftBillApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF2563EB),
        scaffoldBackgroundColor: const Color(0xFFF3F6F9),
        // Apply Inter font to the entire app
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme,
        ),
        // Optional: Also set default text style for better consistency
        appBarTheme: AppBarTheme(
          titleTextStyle: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      home: const LoginPage(),
    );
  }
}