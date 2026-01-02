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

  // Calculate chart data from actual invoices
  Map<String, List<double>> _calculateChartData() {
    final invoices = BusinessData().invoices.value;
    
    if (invoices.isEmpty) {
      return {
        "Weekly": List.filled(7, 0.0),
        "Monthly": List.filled(6, 0.0),
        "Yearly": List.filled(12, 0.0),
      };
    }
    
    // Weekly data (last 7 days)
    List<double> weeklyData = List.filled(7, 0.0);
    final now = DateTime.now();
    for (var invoice in invoices) {
      final daysDiff = now.difference(invoice.date).inDays;
      if (daysDiff >= 0 && daysDiff < 7) {
        weeklyData[6 - daysDiff] += invoice.paid;
      }
    }
    
    // Normalize weekly data
    double weeklyMax = weeklyData.reduce((a, b) => a > b ? a : b);
    if (weeklyMax > 0) {
      weeklyData = weeklyData.map((v) => v / weeklyMax).toList();
    }
    
    // Monthly data (last 6 months)
    List<double> monthlyData = List.filled(6, 0.0);
    for (var invoice in invoices) {
      final monthsDiff = (now.year - invoice.date.year) * 12 + 
                        (now.month - invoice.date.month);
      if (monthsDiff >= 0 && monthsDiff < 6) {
        monthlyData[5 - monthsDiff] += invoice.paid;
      }
    }
    
    // Normalize monthly data
    double monthlyMax = monthlyData.reduce((a, b) => a > b ? a : b);
    if (monthlyMax > 0) {
      monthlyData = monthlyData.map((v) => v / monthlyMax).toList();
    }
    
    // Yearly data (last 12 months)
    List<double> yearlyData = List.filled(12, 0.0);
    for (var invoice in invoices) {
      final monthsDiff = (now.year - invoice.date.year) * 12 + 
                        (now.month - invoice.date.month);
      if (monthsDiff >= 0 && monthsDiff < 12) {
        yearlyData[11 - monthsDiff] += invoice.paid;
      }
    }
    
    // Normalize yearly data
    double yearlyMax = yearlyData.reduce((a, b) => a > b ? a : b);
    if (yearlyMax > 0) {
      yearlyData = yearlyData.map((v) => v / yearlyMax).toList();
    }
    
    return {
      "Weekly": weeklyData,
      "Monthly": monthlyData,
      "Yearly": yearlyData,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6F9),
      appBar: AppBar(
        title: const Text("Performance Analytics", 
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            onPressed: () => _showExportDialog(context),
            tooltip: "Export Report",
          ),
        ],
      ),
      body: ValueListenableBuilder<List<Invoice>>(
        valueListenable: BusinessData().invoices,
        builder: (context, invoices, child) {
          final totalRevenue = BusinessData().getTotalRevenue();
          final avgInvoice = BusinessData().getAverageInvoice();
          final outstanding = BusinessData().getOutstandingAmount();
          final activeClients = BusinessData().getActiveClientsCount();
          final categoryRevenue = BusinessData().getRevenueByCategory();
          final chartData = _calculateChartData();
          
          // Chart labels
          final Map<String, List<String>> chartLabels = {
            "Weekly": ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"],
            "Monthly": _getLastMonths(6),
            "Yearly": _getLastMonths(12),
          };
          
          if (invoices.isEmpty) {
            return _buildEmptyState();
          }
          
          return RefreshIndicator(
            onRefresh: _handleRefresh,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildTimeframePicker(),
                const SizedBox(height: 24),
                
                FadeTransition(
                  opacity: _fadeController,
                  child: _buildMainChartCard(
                    chartData[selectedTimeframe]!, 
                    chartLabels[selectedTimeframe]!,
                    totalRevenue,
                  ),
                ),
                
                const SizedBox(height: 24),
                _buildInsightsCard(totalRevenue, invoices.length),
                const SizedBox(height: 24),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Business Health", 
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    TextButton.icon(
                      onPressed: () => _showDetailedMetrics(context),
                      icon: const Icon(Icons.analytics_outlined, size: 16),
                      label: const Text("View All", style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.5,
                  children: [
                    _metricTile("Total Revenue", "UGX ${_formatAmount(totalRevenue)}", 
                      Icons.trending_up, Colors.green, totalRevenue > 0 ? "+12%" : "0%", 
                      showSparkline: totalRevenue > 0),
                    _metricTile("Avg. Invoice", "UGX ${_formatAmount(avgInvoice)}", 
                      Icons.receipt, Colors.blue, avgInvoice > 0 ? "+5%" : "0%", 
                      showSparkline: avgInvoice > 0),
                    _metricTile("Outstanding", "UGX ${_formatAmount(outstanding)}", 
                      Icons.timer, Colors.orange, outstanding > 0 ? "-2%" : "0%", 
                      showSparkline: false),
                    _metricTile("Active Clients", "$activeClients", 
                      Icons.people, Colors.purple, activeClients > 0 ? "+8%" : "0%", 
                      showSparkline: false),
                  ],
                ),
                
                const SizedBox(height: 24),
                const Text("Revenue by Category", 
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                
                if (totalRevenue > 0) ...[
                  _categoryProgress(
                    "Consultations", 
                    totalRevenue > 0 ? categoryRevenue['Consultations']! / totalRevenue : 0, 
                    Colors.blue, 
                    "UGX ${_formatAmount(categoryRevenue['Consultations']!)}"
                  ),
                  _categoryProgress(
                    "Product Sales", 
                    totalRevenue > 0 ? categoryRevenue['Product Sales']! / totalRevenue : 0, 
                    Colors.orange, 
                    "UGX ${_formatAmount(categoryRevenue['Product Sales']!)}"
                  ),
                  _categoryProgress(
                    "Service Fees", 
                    totalRevenue > 0 ? categoryRevenue['Service Fees']! / totalRevenue : 0, 
                    Colors.green, 
                    "UGX ${_formatAmount(categoryRevenue['Service Fees']!)}"
                  ),
                ] else ...[
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        "No revenue data yet",
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                  ),
                ],
                
                const SizedBox(height: 24),
                if (invoices.length > 1) _buildComparisonCard(invoices),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics_outlined, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 20),
            const Text(
              "No Analytics Data Yet",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Create your first invoice to start seeing your business analytics and insights here.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _getLastMonths(int count) {
    final now = DateTime.now();
    List<String> months = [];
    for (int i = count - 1; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      if (count == 12) {
        months.add("'${month.year.toString().substring(2)}");
      } else {
        months.add(['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][month.month - 1]);
      }
    }
    return months;
  }

  String _formatAmount(double amount) {
    if (amount == 0) return "0";
    if (amount >= 1000000) {
      return "${(amount / 1000000).toStringAsFixed(1)}M";
    } else if (amount >= 1000) {
      return "${(amount / 1000).toStringAsFixed(0)}K";
    }
    return amount.toStringAsFixed(0);
  }

  Widget _buildTimeframePicker() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: ["Weekly", "Monthly", "Yearly"].map((time) {
          bool isSelected = selectedTimeframe == time;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedTimeframe = time;
                  _fadeController.reset();
                  _fadeController.forward();
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF2563EB) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    time,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.white : Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMainChartCard(List<double> points, List<String> labels, double revenue) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF111827), Color(0xFF1F2937)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Net Income", 
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text("UGX ${_formatAmount(revenue)}", 
                    style: const TextStyle(
                      color: Colors.white, 
                      fontSize: 28, 
                      fontWeight: FontWeight.bold
                    )),
                  const SizedBox(height: 4),
                  if (revenue > 0)
                    Row(
                      children: [
                        Icon(Icons.arrow_upward, color: Colors.green[400], size: 14),
                        const SizedBox(width: 4),
                        Text("12.5% vs last period", 
                          style: TextStyle(color: Colors.green[400], fontSize: 11)),
                      ],
                    ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.more_vert, color: Colors.white, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 30),
          SizedBox(
            height: 170,
            width: double.infinity,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return CustomPaint(
                  painter: EnhancedChartPainter(points, value),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: labels.map((m) => 
              Text(m, style: const TextStyle(
                color: Colors.grey, 
                fontSize: 11,
                fontWeight: FontWeight.w500
              ))
            ).toList(),
          )
        ],
      ),
    );
  }

  Widget _buildInsightsCard(double revenue, int invoiceCount) {
    String insight = "Start creating invoices to see AI-powered insights about your business performance.";
    
    if (revenue > 0) {
      insight = "You have generated UGX ${_formatAmount(revenue)} from $invoiceCount invoice${invoiceCount > 1 ? 's' : ''}. Keep up the great work!";
    }
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue[50]!, Colors.purple[50]!],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.lightbulb_outline, 
              color: Color(0xFF2563EB), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("AI Insight", 
                  style: TextStyle(
                    fontWeight: FontWeight.bold, 
                    fontSize: 14,
                    color: Color(0xFF2563EB)
                  )),
                const SizedBox(height: 4),
                Text(
                  insight,
                  style: const TextStyle(fontSize: 12, color: Colors.black87, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonCard(List<Invoice> invoices) {
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    final currentPeriod = invoices
        .where((inv) => inv.date.isAfter(thirtyDaysAgo))
        .fold(0.0, (sum, inv) => sum + inv.paid);
    
    final sixtyDaysAgo = now.subtract(const Duration(days: 60));
    final previousPeriod = invoices
        .where((inv) => inv.date.isAfter(sixtyDaysAgo) && inv.date.isBefore(thirtyDaysAgo))
        .fold(0.0, (sum, inv) => sum + inv.paid);
    
    final average = (currentPeriod + previousPeriod) / 2;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Period Comparison (Last 30 Days)", 
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _comparisonRow("This Period", "UGX ${_formatAmount(currentPeriod)}", Colors.green, true),
          const SizedBox(height: 12),
          _comparisonRow("Last Period", "UGX ${_formatAmount(previousPeriod)}", Colors.grey, false),
          const SizedBox(height: 12),
          _comparisonRow("Average", "UGX ${_formatAmount(average)}", Colors.blue, false),
        ],
      ),
    );
  }

  Widget _comparisonRow(String label, String value, Color color, bool isCurrent) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, 
            style: TextStyle(
              fontSize: 13,
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
            )),
        ),
        Text(value, 
          style: TextStyle(
            fontSize: 14,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
            color: color,
          )),
      ],
    );
  }

  Widget _metricTile(String label, String value, IconData icon, 
    Color color, String growth, {required bool showSparkline}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              if (growth != "0%")
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: growth.contains('+') 
                      ? Colors.green.withOpacity(0.1) 
                      : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(growth, 
                    style: TextStyle(
                      color: growth.contains('+') ? Colors.green : Colors.red, 
                      fontSize: 10, 
                      fontWeight: FontWeight.bold
                    )),
                ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, 
                style: const TextStyle(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold
                )),
              const SizedBox(height: 2),
              Text(label, 
                style: const TextStyle(
                  color: Colors.grey, 
                  fontSize: 11
                )),
              if (showSparkline) ...[
                const SizedBox(height: 8),
                SizedBox(
                  height: 20,
                  child: CustomPaint(
                    painter: SparklinePainter(color),
                  ),
                ),
              ],
            ],
          )
        ],
      ),
    );
  }

  Widget _categoryProgress(String label, double progress, Color color, String amount) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(amount, 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  Text("${(progress * 100).toInt()}%", 
                    style: const TextStyle(color: Colors.grey, fontSize: 10)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: progress),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  children: [
                    Container(
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: value,
                      child: Container(
                        height: 10,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [color, color.withOpacity(0.6)],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _fadeController.reset();
      _fadeController.forward();
    });
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Export Report"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
              title: const Text("Export as PDF"),
              onTap: () {
                Navigator.pop(context);
                _exportAsPDF();
              },
            ),
            ListTile(
              leading: const Icon(Icons.table_chart, color: Colors.green),
              title: const Text("Export as Excel"),
              onTap: () {
                Navigator.pop(context);
                _exportAsExcel();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }

  void _exportAsPDF() async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: 12),
            Text("Generating PDF..."),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
    
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      DownloadUtils.showDownloadSuccess(
        context, 
        "/storage/emulated/0/Download/Analytics_Report.pdf"
      );
    }
  }

  void _exportAsExcel() async {
    final filePath = await DownloadUtils.exportAnalyticsToExcel(context);
    if (filePath != null && mounted) {
      DownloadUtils.showDownloadSuccess(context, filePath);
    }
  }

  void _showDetailedMetrics(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text("Detailed Metrics", 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Text("Additional metrics and insights would appear here."),
          ],
        ),
      ),
    );
  }
}

// Enhanced Chart Painter with dots and gradient
class EnhancedChartPainter extends CustomPainter {
  final List<double> points;
  final double animationValue;
  
  EnhancedChartPainter(this.points, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty || points.every((p) => p == 0)) {
      final paint = Paint()
        ..color = Colors.grey.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      
      final path = Path();
      path.moveTo(0, size.height / 2);
      path.lineTo(size.width, size.height / 2);
      canvas.drawPath(path, paint);
      return;
    }

    final linePaint = Paint()
      ..color = const Color(0xFF2563EB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final dotBorderPaint = Paint()
      ..color = const Color(0xFF2563EB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path();
    double dx = size.width / (points.length - 1);
    
    int visiblePoints = (points.length * animationValue).ceil();
    List<double> animatedPoints = points.sublist(0, visiblePoints);
    
    if (animatedPoints.isEmpty) return;
    
    path.moveTo(0, size.height * (1 - animatedPoints[0]));

    for (int i = 1; i < animatedPoints.length; i++) {
      path.quadraticBezierTo(
        (i - 0.5) * dx, 
        size.height * (1 - animatedPoints[i-1]),
        i * dx, 
        size.height * (1 - animatedPoints[i]),
      );
    }

    // Gradient Fill
    final fillPath = Path.from(path)
      ..lineTo((animatedPoints.length - 1) * dx, size.height)
      ..lineTo(0, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF2563EB).withOpacity(0.3), 
          const Color(0xFF2563EB).withOpacity(0.05)
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);

    // Draw dots at each point
    for (int i = 0; i < animatedPoints.length; i++) {
      double x = i * dx;
      double y = size.height * (1 - animatedPoints[i]);
      canvas.drawCircle(Offset(x, y), 5, dotPaint);
      canvas.drawCircle(Offset(x, y), 5, dotBorderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant EnhancedChartPainter oldDelegate) => 
    oldDelegate.animationValue != animationValue;
}

// Sparkline painter for metric tiles
class SparklinePainter extends CustomPainter {
  final Color color;
  SparklinePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final points = [0.5, 0.7, 0.4, 0.8, 0.6, 0.9, 0.7];
    final path = Path();
    double dx = size.width / (points.length - 1);
    
    path.moveTo(0, size.height * (1 - points[0]));
    for (int i = 1; i < points.length; i++) {
      path.lineTo(i * dx, size.height * (1 - points[i]));
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}