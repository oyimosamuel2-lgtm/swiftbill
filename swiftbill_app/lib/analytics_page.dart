import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:swiftbill_app/business_data.dart';
import 'package:swiftbill_app/download_utils.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> with TickerProviderStateMixin {
  String selectedTimeframe = "Monthly";
  late AnimationController _fadeController;
  late AnimationController _slideController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  // Enhanced differentiation for invoices and receipts
  Map<String, Map<String, List<double>>> _calculateChartData() {
    final invoices = BusinessData().invoices.value;

    Map<String, List<double>> invoiceData = {
      "Weekly": List.filled(7, 0.0),
      "Monthly": List.filled(6, 0.0),
      "Yearly": List.filled(12, 0.0),
    };

    Map<String, List<double>> receiptData = {
      "Weekly": List.filled(7, 0.0),
      "Monthly": List.filled(6, 0.0),
      "Yearly": List.filled(12, 0.0),
    };

    final now = DateTime.now();

    for (var invoice in invoices) {
      final isReceipt = invoice.date.isBefore(now);
      final daysDiff = now.difference(invoice.date).inDays;
      final monthsDiff = (now.year - invoice.date.year) * 12 +
          (now.month - invoice.date.month);

      if (daysDiff >= 0 && daysDiff < 7) {
        if (isReceipt) {
          receiptData["Weekly"]![6 - daysDiff] += invoice.paid;
        } else {
          invoiceData["Weekly"]![6 - daysDiff] += invoice.amount;
        }
      }
      if (monthsDiff >= 0 && monthsDiff < 6) {
        if (isReceipt) {
          receiptData["Monthly"]![5 - monthsDiff] += invoice.paid;
        } else {
          invoiceData["Monthly"]![5 - monthsDiff] += invoice.amount;
        }
      }
      if (monthsDiff >= 0 && monthsDiff < 12) {
        if (isReceipt) {
          receiptData["Yearly"]![11 - monthsDiff] += invoice.paid;
        } else {
          invoiceData["Yearly"]![11 - monthsDiff] += invoice.amount;
        }
      }
    }

    return {
      "Invoices": invoiceData,
      "Receipts": receiptData,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6F9),
      appBar: AppBar(
        ...
      ),
      body: ValueListenableBuilder<List<Invoice>>(
        valueListenable: BusinessData().invoices,
        builder: (context, invoices, child) {
          final chartData = _calculateChartData();
          final invoiceChartData = chartData["Invoices"]!;
          final receiptChartData = chartData["Receipts"]!;

          return ListView(...
            children: [
              ...[             ....Expanded
          ]
]}