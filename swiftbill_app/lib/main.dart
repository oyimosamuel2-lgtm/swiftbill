import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:swiftbill_app/theme_manager.dart';
import 'package:swiftbill_app/premium_manager.dart';
import 'login_page.dart';

void main() {
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
      home: const LoginPage(),
    );
  }
}