import 'package:flutter/material.dart';
import 'package:swiftbill_app/invoice_page.dart';
import 'package:swiftbill_app/payment_methods_page.dart';
import 'package:swiftbill_app/appointments_page.dart';
import 'package:swiftbill_app/analytics_page.dart';
import 'package:swiftbill_app/business_data.dart';
import 'package:swiftbill_app/premium_gate.dart';
import 'package:swiftbill_app/clients_page.dart';
import 'package:swiftbill_app/documents_page.dart';

class OverviewPage extends StatefulWidget {
  const OverviewPage({super.key});
  @override
  State<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  String selectedFilter = "All";
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6F9),
      appBar: AppBar(
        title: const Text("Business Overview", 
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => _showNotifications(context),
            tooltip: "Notifications",
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterOptions(context),
            tooltip: "Filter",
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildWelcomeCard(),
            const SizedBox(height: 20),
            _buildQuickActions(),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Quick Stats", 
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PremiumGate(
                      child: const AnalyticsPage(), 
                      featureName: "Analytics"
                    )),
                  ),
                  icon: const Icon(Icons.analytics_outlined, size: 16),
                  label: const Text("View All", style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatsGrid(),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Recent Activity", 
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                _buildActivityFilter(),
              ],
            ),
            const SizedBox(height: 16),
            _buildActivityList(),
            const SizedBox(height: 24),
            _buildUpcomingTasks(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showQuickAddMenu(context),
        backgroundColor: const Color(0xFF2563EB),
        icon: const Icon(Icons.add),
        label: const Text("Quick Add"),
      ),
    );
  }
  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Welcome Back! 👋",
                  style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 6),
                const Text("Your Business Today",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  )),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.trending_up, color: Colors.white, size: 14),
                      SizedBox(width: 6),
                      Text("Revenue up 12% this week",
                        style: TextStyle(color: Colors.white, fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.business_center, color: Colors.white, size: 32),
          ),
        ],
      ),
    );
  }
  Widget _buildQuickActions() {
    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _quickActionButton("New Invoice", Icons.receipt_long, const Color(0xFF2563EB)),
          _quickActionButton("Add Client", Icons.person_add, const Color(0xFF10B981)),
          _quickActionButton("Schedule", Icons.calendar_today, const Color(0xFFF59E0B)),
          _quickActionButton("Payment", Icons.payment, const Color(0xFF8B5CF6)),
          _quickActionButton("Reports", Icons.bar_chart, const Color(0xFFEC4899)),
        ],
      ),
    );
  }
  Widget _quickActionButton(String label, IconData icon, Color color) {
    return Container(
      width: 90,
      margin: const EdgeInsets.only(right: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => _handleQuickAction(label),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(height: 8),
                Text(label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildStatsGrid() {
    return ValueListenableBuilder<List<Client>>(
      valueListenable: BusinessData().clients,
      builder: (context, clients, _) {
        return ValueListenableBuilder<List<Invoice>>(
          valueListenable: BusinessData().invoices,
          builder: (context, invoices, _) {
            return ValueListenableBuilder<List<Appointment>>(
              valueListenable: BusinessData().appointments,
              builder: (context, appointments, _) {
                final pendingInvoices = invoices.where((inv) => inv.paid < inv.amount).length;
                final totalRevenue = invoices.fold(0.0, (sum, inv) => sum + inv.paid);
                final upcomingAppointments = appointments.where((apt) => 
                  apt.dateTime.isAfter(DateTime.now())
                ).length;
                
                return GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.5,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ClientsPage()),
                      ),
                      child: _enhancedStatBox("Active Clients", "${clients.length}", Icons.people, 
                        const Color(0xFF10B981), "+4 this week"),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const DocumentsPage()),
                      ),
                      child: _enhancedStatBox("Pending Invoices", "$pendingInvoices", Icons.description, 
                        const Color(0xFFF59E0B), "2 overdue"),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PremiumGate(
                          child: const AnalyticsPage(), 
                          featureName: "Analytics"
                        )),
                      ),
                      child: _enhancedStatBox("Today's Revenue", "UGX ${_formatAmount(totalRevenue)}", Icons.attach_money, 
                        const Color(0xFF2563EB), "+15% vs yesterday"),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PremiumGate(
                          child: const AppointmentsPage(), 
                          featureName: "Appointments"
                        )),
                      ),
                      child: _enhancedStatBox("Appointments", "$upcomingAppointments", Icons.event, 
                        const Color(0xFF8B5CF6), "3 today"),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
  Widget _enhancedStatBox(String title, String value, IconData icon, Color color, String subtitle) {
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
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                )),
              const SizedBox(height: 2),
              Text(title,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                )),
              const SizedBox(height: 4),
              Text(subtitle,
                style: TextStyle(
                  color: color,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                )),
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildActivityFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(selectedFilter,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(width: 4),
          const Icon(Icons.arrow_drop_down, size: 18),
        ],
      ),
    );
  }
  Widget _buildActivityList() {
    return ValueListenableBuilder<List<Appointment>>(
      valueListenable: BusinessData().appointments,
      builder: (context, appointments, _) {
        return ValueListenableBuilder<List<Client>>(
          valueListenable: BusinessData().clients,
          builder: (context, clients, _) {
            return ValueListenableBuilder<List<Invoice>>(
              valueListenable: BusinessData().invoices,
              builder: (context, invoices, _) {
                // Get most recent items
                final recentAppointment = appointments.isNotEmpty 
                    ? appointments.reduce((a, b) => a.dateTime.isAfter(b.dateTime) ? a : b)
                    : null;
                
                final recentClient = clients.isNotEmpty
                    ? clients.reduce((a, b) => a.addedDate.isAfter(b.addedDate) ? a : b)
                    : null;
                
                final recentPayment = invoices.where((inv) => inv.paid > 0).isNotEmpty
                    ? invoices.where((inv) => inv.paid > 0).reduce((a, b) => a.date.isAfter(b.date) ? a : b)
                    : null;
                
                final paidInvoice = invoices.where((inv) => inv.status == "Paid").isNotEmpty
                    ? invoices.where((inv) => inv.status == "Paid").reduce((a, b) => a.date.isAfter(b.date) ? a : b)
                    : null;
                
                final sentInvoice = invoices.isNotEmpty
                    ? invoices.reduce((a, b) => a.date.isAfter(b.date) ? a : b)
                    : null;
                
                return Column(
                  children: [
                    if (paidInvoice != null)
                      GestureDetector(
                        onTap: () => _showInvoiceDetails(paidInvoice),
                        child: _enhancedActivityTile(
                          "Invoice ${paidInvoice.id} Paid",
                          _getTimeAgo(paidInvoice.date),
                          Icons.check_circle,
                          Colors.green,
                          "+UGX ${_formatAmount(paidInvoice.paid)}",
                        ),
                      ),
                    if (recentAppointment != null)
                      GestureDetector(
                        onTap: () => _showAppointmentDetails(recentAppointment),
                        child: _enhancedActivityTile(
                          "New Appointment Booked",
                          _getTimeAgo(recentAppointment.dateTime),
                          Icons.calendar_today,
                          Colors.blue,
                          "",
                        ),
                      ),
                    if (recentPayment != null)
                      GestureDetector(
                        onTap: () => _showInvoiceDetails(recentPayment),
                        child: _enhancedActivityTile(
                          "Payment Received",
                          _getTimeAgo(recentPayment.date),
                          Icons.payments,
                          Colors.orange,
                          "+UGX ${_formatAmount(recentPayment.paid)}",
                        ),
                      ),
                    if (recentClient != null)
                      GestureDetector(
                        onTap: () => _showClientDetails(recentClient),
                        child: _enhancedActivityTile(
                          "Client Added: ${recentClient.name}",
                          _getTimeAgo(recentClient.addedDate),
                          Icons.person_add,
                          Colors.purple,
                          "",
                        ),
                      ),
                    if (sentInvoice != null && sentInvoice.status != "Paid")
                      GestureDetector(
                        onTap: () => _showInvoiceDetails(sentInvoice),
                        child: _enhancedActivityTile(
                          "Invoice ${sentInvoice.id} Sent",
                          _getTimeAgo(sentInvoice.date),
                          Icons.send,
                          Colors.teal,
                          "UGX ${_formatAmount(sentInvoice.amount)}",
                        ),
                      ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
  
  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    
    if (difference.inDays > 365) {
      return "${(difference.inDays / 365).floor()} year${(difference.inDays / 365).floor() > 1 ? 's' : ''} ago";
    } else if (difference.inDays > 30) {
      return "${(difference.inDays / 30).floor()} month${(difference.inDays / 30).floor() > 1 ? 's' : ''} ago";
    } else if (difference.inDays > 0) {
      return "${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago";
    } else if (difference.inHours > 0) {
      return "${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago";
    } else if (difference.inMinutes > 0) {
      return "${difference.inMinutes} min${difference.inMinutes > 1 ? 's' : ''} ago";
    } else {
      return "Just now";
    }
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
  Widget _enhancedActivityTile(String title, String time, IconData icon, Color color, String amount) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Row(
          children: [
            Icon(Icons.access_time, size: 12, color: Colors.grey.shade400),
            const SizedBox(width: 4),
            Text(time, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          ],
        ),
        trailing: amount.isNotEmpty
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(amount,
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                )),
            )
          : const Icon(Icons.chevron_right, color: Colors.grey),
      ),
    );
  }
  Widget _buildUpcomingTasks() {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Upcoming Tasks",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () {},
                child: const Text("View All", style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _taskItem("Follow up with Client A", "Today, 2:00 PM", false),
          _taskItem("Send Invoice #1025", "Today, 4:30 PM", false),
          _taskItem("Team Meeting", "Tomorrow, 10:00 AM", true),
        ],
      ),
    );
  }
  Widget _taskItem(String title, String time, bool isCompleted) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            isCompleted ? Icons.check_circle : Icons.circle_outlined,
            color: isCompleted ? Colors.green : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                    color: isCompleted ? Colors.grey : Colors.black,
                  )),
                const SizedBox(height: 2),
                Text(time,
                  style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {});
  }
  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Notifications",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _notificationItem("Payment received", "2 mins ago", Icons.payments),
            _notificationItem("New appointment", "1 hour ago", Icons.calendar_today),
            _notificationItem("Invoice overdue", "3 hours ago", Icons.warning),
          ],
        ),
      ),
    );
  }
  Widget _notificationItem(String title, String time, IconData icon) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: const Color(0xFF2563EB).withOpacity(0.1),
        child: Icon(icon, color: const Color(0xFF2563EB), size: 20),
      ),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      subtitle: Text(time, style: const TextStyle(fontSize: 12)),
    );
  }
  void _showFilterOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Filter Activity"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ["All", "Payments", "Invoices", "Appointments", "Clients"].map((filter) {
            return RadioListTile<String>(
              title: Text(filter),
              value: filter,
              groupValue: selectedFilter,
              onChanged: (value) {
                setState(() {
                  selectedFilter = value!;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
  void _showQuickAddMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Quick Add",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _quickAddOption("Create Invoice", Icons.receipt_long, Colors.blue),
            _quickAddOption("Add Client", Icons.person_add, Colors.green),
            _quickAddOption("New Appointment", Icons.calendar_today, Colors.orange),
            _quickAddOption("Record Payment", Icons.payment, Colors.purple),
          ],
        ),
      ),
    );
  }
  Widget _quickAddOption(String title, IconData icon, Color color) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        Navigator.pop(context);
        _handleQuickAction(title);
      },
    );
  }
  
  // Handle quick action button clicks
  void _handleQuickAction(String action) {
    switch (action) {
      case "New Invoice":
      case "Create Invoice":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const InvoicePage()),
        );
        break;
      case "Add Client":
        _showAddClientDialog();
        break;
      case "Schedule":
      case "New Appointment":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PremiumGate(
            child: const AppointmentsPage(), 
            featureName: "Appointments"
          )),
        );
        break;
      case "Payment":
      case "Record Payment":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PaymentMethodsPage()),
        );
        break;
      case "Reports":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PremiumGate(
            child: const AnalyticsPage(), 
            featureName: "Analytics"
          )),
        );
        break;
    }
  }
  
  // Dialog to add a new client
  void _showAddClientDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.person_add, color: Color(0xFF10B981)),
            ),
            const SizedBox(width: 12),
            const Text("Add New Client", style: TextStyle(fontSize: 18)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "Client Name *",
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "Email Address",
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: "Phone Number",
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Please enter client name"),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              
              final client = Client(
                id: "CLI-${DateTime.now().millisecondsSinceEpoch}",
                name: nameController.text,
                email: emailController.text,
                phone: phoneController.text,
                addedDate: DateTime.now(),
                totalRevenue: 0.0,
              );
              
              BusinessData().addClient(client);
              
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: const [
                      Icon(Icons.check_circle, color: Colors.white),
                      SizedBox(width: 12),
                      Text("Client added successfully!"),
                    ],
                  ),
                  backgroundColor: const Color(0xFF10B981),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text("Add Client", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
  
  // Show appointment details
  void _showAppointmentDetails(Appointment appointment) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.calendar_today, color: Color(0xFF8B5CF6), size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.type,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: appointment.status == "Confirmed" 
                              ? Colors.green.withOpacity(0.1)
                              : Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          appointment.status,
                          style: TextStyle(
                            color: appointment.status == "Confirmed" ? Colors.green : Colors.orange,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _detailRow(Icons.person, "Client", appointment.clientName),
            const SizedBox(height: 12),
            _detailRow(Icons.access_time, "Date & Time", 
              "${appointment.dateTime.day}/${appointment.dateTime.month}/${appointment.dateTime.year} at ${appointment.dateTime.hour}:${appointment.dateTime.minute.toString().padLeft(2, '0')}"),
            if (appointment.fee != null) ...[
              const SizedBox(height: 12),
              _detailRow(Icons.attach_money, "Fee", "UGX ${appointment.fee!.toStringAsFixed(0)}"),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PremiumGate(
                    child: const AppointmentsPage(), 
                    featureName: "Appointments"
                  )),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("View All Appointments", 
                style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
  
  // Show client details
  void _showClientDetails(Client client) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: const Color(0xFF10B981).withOpacity(0.1),
                  child: Text(
                    client.name.isNotEmpty ? client.name[0].toUpperCase() : "C",
                    style: const TextStyle(
                      color: Color(0xFF10B981),
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        client.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          "Active Client",
                          style: TextStyle(
                            color: Color(0xFF10B981),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (client.email.isNotEmpty) ...[
              _detailRow(Icons.email, "Email", client.email),
              const SizedBox(height: 12),
            ],
            if (client.phone.isNotEmpty) ...[
              _detailRow(Icons.phone, "Phone", client.phone),
              const SizedBox(height: 12),
            ],
            _detailRow(Icons.calendar_today, "Added On", 
              "${client.addedDate.day}/${client.addedDate.month}/${client.addedDate.year}"),
            const SizedBox(height: 12),
            _detailRow(Icons.attach_money, "Total Revenue", 
              "UGX ${_formatAmount(client.totalRevenue)}"),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ClientsPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("View All Clients", 
                style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
  
  // Show invoice details
  void _showInvoiceDetails(Invoice invoice) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(24),
          child: ListView(
            controller: scrollController,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.receipt_long, color: Color(0xFF2563EB), size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          invoice.id,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: invoice.status == "Paid" 
                                ? Colors.green.withOpacity(0.1)
                                : invoice.status == "Partial"
                                    ? Colors.orange.withOpacity(0.1)
                                    : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            invoice.status,
                            style: TextStyle(
                              color: invoice.status == "Paid" 
                                  ? Colors.green
                                  : invoice.status == "Partial"
                                      ? Colors.orange
                                      : Colors.red,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                "Customer Information",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _detailRow(Icons.person, "Customer", invoice.customerName),
              const SizedBox(height: 12),
              _detailRow(Icons.email, "Email", invoice.customerEmail),
              const SizedBox(height: 12),
              _detailRow(Icons.calendar_today, "Date", 
                "${invoice.date.day}/${invoice.date.month}/${invoice.date.year}"),
              const SizedBox(height: 24),
              const Text(
                "Items",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...invoice.items.map((item) => Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.description,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${item.quantity.toStringAsFixed(0)} × UGX ${item.rate.toStringAsFixed(0)}",
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      "UGX ${item.amount.toStringAsFixed(0)}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              )).toList(),
              const SizedBox(height: 24),
              const Text(
                "Payment Summary",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.blue.shade50, Colors.purple.shade50],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Total Amount"),
                        Text(
                          "UGX ${invoice.amount.toStringAsFixed(0)}",
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Paid"),
                        Text(
                          "UGX ${invoice.paid.toStringAsFixed(0)}",
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Balance",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "UGX ${invoice.balance.toStringAsFixed(0)}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: invoice.balance > 0 ? Colors.red : Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const DocumentsPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("View All Invoices", 
                  style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: const Color(0xFF2563EB)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}