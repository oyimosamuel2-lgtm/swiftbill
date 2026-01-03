import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PremiumManager extends ChangeNotifier {
  static final PremiumManager _instance = PremiumManager._internal();
  factory PremiumManager() => _instance;
  PremiumManager._internal() {
    _loadPremiumStatus();
  }

  bool _isPremium = false;
  bool get isPremium => _isPremium;

  String _premiumPlan = 'free';
  String get premiumPlan => _premiumPlan;

  DateTime? _premiumExpiryDate;
  DateTime? get premiumExpiryDate => _premiumExpiryDate;

  Future<void> _loadPremiumStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isPremium = prefs.getBool('isPremium') ?? false;
    _premiumPlan = prefs.getString('premiumPlan') ?? 'free';
    
    final expiryTimestamp = prefs.getInt('premiumExpiryDate');
    if (expiryTimestamp != null) {
      _premiumExpiryDate = DateTime.fromMillisecondsSinceEpoch(expiryTimestamp);
      
      // Check if premium has expired
      if (_premiumExpiryDate!.isBefore(DateTime.now())) {
        await _revokePremium();
      }
    }
    
    notifyListeners();
  }

  Future<void> upgradeToPremium(String plan, {int durationInDays = 365}) async {
    _isPremium = true;
    _premiumPlan = plan;
    _premiumExpiryDate = DateTime.now().add(Duration(days: durationInDays));
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isPremium', true);
    await prefs.setString('premiumPlan', plan);
    await prefs.setInt('premiumExpiryDate', _premiumExpiryDate!.millisecondsSinceEpoch);
    
    notifyListeners();
  }

  Future<void> _revokePremium() async {
    _isPremium = false;
    _premiumPlan = 'free';
    _premiumExpiryDate = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isPremium', false);
    await prefs.setString('premiumPlan', 'free');
    await prefs.remove('premiumExpiryDate');
    
    notifyListeners();
  }

  // For testing - toggle premium status
  Future<void> togglePremium() async {
    if (_isPremium) {
      await _revokePremium();
    } else {
      await upgradeToPremium('pro', durationInDays: 365);
    }
  }

  // Check if specific feature is available
  bool hasFeatureAccess(String feature) {
    if (_isPremium) return true;
    
    // Free tier features
    const freeFeatures = [
      'invoicing',
      'basic_analytics',
      'clients',
      'documents',
    ];
    
    return freeFeatures.contains(feature);
  }

  // Premium-only features
  static const List<String> premiumFeatures = [
    'overview',
    'analytics',
    'appointments',
    'advanced_reports',
    'bulk_operations',
    'custom_branding',
    'api_access',
  ];
}