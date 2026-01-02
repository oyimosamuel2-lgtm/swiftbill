import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> with TickerProviderStateMixin {
  String selectedTimeframe = "Monthly";
  late AnimationController _fadeController;
  late AnimationController _slideController;
  
  // Enhanced data sets with actual values
  final Map<String, List<double>> chartData = {
    "Weekly": [0.2, 0.5, 0.4, 0.7, 0.6, 0.9, 0.8],
    "Monthly": [0.8, 0.9, 0.4, 0.1, 0.5, 0.2],
    "Yearly": [0.3, 0.4, 0.6, 0.5, 0.8, 0.7, 0.9, 0.6, 0.5, 0.7, 0.8, 0.9],
  };

  final Map<String, List<String>> chartLabels = {
    "Weekly": ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"],
    "Monthly": ["Jan", "Feb", "Mar", "Apr", "May", "Jun"],
    "Yearly": ["'15", "'16", "'17", "'18", "'19", "'20", "'21", "'22", "'23", "'24", "'25", "'26"],
  };

  // Revenue data for each timeframe
  final Map<String, String> revenueData = {
    "Weekly": "UGX 2,850,000",
    "Monthly": "UGX 12,450,000",
    "Yearly": "UGX 145,200,000",
  };

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
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildTimeframePicker(),
            const SizedBox(height: 24),
            
            // Enhanced chart card with animation
            FadeTransition(
              opacity: _fadeController,
              child: _buildMainChartCard(
                chartData[selectedTimeframe]!, 
                chartLabels[selectedTimeframe]!
              ),
            ),
            
            const SizedBox(height: 24),
            _buildInsightsCard(),
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
                _metricTile("Total Revenue", "UGX 4.2M", Icons.trending_up, 
                  Colors.green, "+12%", showSparkline: true),
                _metricTile("Avg. Invoice", "UGX 150K", Icons.receipt, 
                  Colors.blue, "+5%", showSparkline: true),
                _metricTile("Outstanding", "UGX 800K", Icons.timer, 
                  Colors.orange, "-2%", showSparkline: false),
                _metricTile("Active Clients", "32", Icons.people, 
                  Colors.purple, "+8%", showSparkline: false),
              ],
            ),
            
            const SizedBox(height: 24),
            const Text("Revenue by Category", 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _categoryProgress("Consultations", 0.75, Colors.blue, "UGX 3.15M"),
            _categoryProgress("Product Sales", 0.45, Colors.orange, "UGX 1.89M"),
            _categoryProgress("Service Fees", 0.30, Colors.green, "UGX 1.26M"),
            
            const SizedBox(height: 24),
            _buildComparisonCard(),
          ],
        ),
      ),
    );
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

  Widget _buildMainChartCard(List<double> points, List<String> labels) {
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
                  Text(revenueData[selectedTimeframe]!, 
                    style: const TextStyle(
                      color: Colors.white, 
                      fontSize: 28, 
                      fontWeight: FontWeight.bold
                    )),
                  const SizedBox(height: 4),
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

  Widget _buildInsightsCard() {
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
              children: const [
                Text("AI Insight", 
                  style: TextStyle(
                    fontWeight: FontWeight.bold, 
                    fontSize: 14,
                    color: Color(0xFF2563EB)
                  )),
                SizedBox(height: 4),
                Text(
                  "Revenue increased 12% this month. Consider expanding consultations service.",
                  style: TextStyle(fontSize: 12, color: Colors.black87, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonCard() {
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
          const Text("Period Comparison", 
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _comparisonRow("This Period", "UGX 4.2M", Colors.green, true),
          const SizedBox(height: 12),
          _comparisonRow("Last Period", "UGX 3.7M", Colors.grey, false),
          const SizedBox(height: 12),
          _comparisonRow("Average", "UGX 3.9M", Colors.blue, false),
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
            ListTile(
              leading: const Icon(Icons.image, color: Colors.blue),
              title: const Text("Export as Image"),
              onTap: () {
                Navigator.pop(context);
                _exportAsImage();
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
  void _exportAsPDF() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.download, color: Colors.white, size: 20),
            SizedBox(width: 12),
            Text("Analytics report downloaded as PDF"),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: "View",
          textColor: Colors.white,
          onPressed: () {
            // Open the downloaded file
          },
        ),
      ),
    );
  }
  void _exportAsExcel() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.download, color: Colors.white, size: 20),
            SizedBox(width: 12),
            Text("Analytics report downloaded as Excel"),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: "View",
          textColor: Colors.white,
          onPressed: () {
            // Open the downloaded file
          },
        ),
      ),
    );
  }
  void _exportAsImage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.download, color: Colors.white, size: 20),
            SizedBox(width: 12),
            Text("Analytics report downloaded as Image"),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: "View",
          textColor: Colors.white,
          onPressed: () {
            // Open the downloaded file
          },
        ),
      ),
    );
  }
  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Analytics Settings"),
        content: const Text("Configure your analytics preferences here."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
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
    if (points.isEmpty) return;

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
    
    // Animate the line drawing
    int visiblePoints = (points.length * animationValue).ceil();
    List<double> animatedPoints = points.sublist(0, visiblePoints);
    
    if (animatedPoints.isEmpty) return;
    
    path.moveTo(0, size.height * (1 - animatedPoints[0]));

    for (int i = 1; i < animatedPoints.length; i++) {
      path.quadraticBezierTo(
        (i - 0.5) * dx, size.height * (1 - animatedPoints[i-1]),
        i * dx, size.height * (1 - animatedPoints[i]),
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