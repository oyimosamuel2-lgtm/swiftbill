import 'package:flutter/material.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});
  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool pushNotifications = true;
  bool emailNotifications = true;
  bool paymentAlerts = true;
  bool invoiceReminders = true;
  bool appointmentReminders = true;
  bool weeklyReports = false;
  bool marketingEmails = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6F9),
      appBar: AppBar(
        title: const Text("Notifications",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildInfoCard(),
          const SizedBox(height: 24),
          _sectionHeader("Push Notifications", Icons.notifications),
          _enhancedSwitchTile(
            "Push Notifications",
            "Receive alerts on your device",
            pushNotifications,
            (v) => setState(() => pushNotifications = v),
            Icons.phone_iphone,
            Colors.blue,
          ),
          _enhancedSwitchTile(
            "Payment Alerts",
            "Notify when an invoice is paid",
            paymentAlerts,
            (v) => setState(() => paymentAlerts = v),
            Icons.payments,
            Colors.green,
          ),
          _enhancedSwitchTile(
            "Invoice Reminders",
            "Remind clients about pending payments",
            invoiceReminders,
            (v) => setState(() => invoiceReminders = v),
            Icons.receipt_long,
            Colors.orange,
          ),
          _enhancedSwitchTile(
            "Appointment Reminders",
            "Notifications for upcoming meetings",
            appointmentReminders,
            (v) => setState(() => appointmentReminders = v),
            Icons.calendar_today,
            Colors.purple,
          ),
          const SizedBox(height: 24),
          _sectionHeader("Email Notifications", Icons.email),
          _enhancedSwitchTile(
            "Email Notifications",
            "Receive updates via email",
            emailNotifications,
            (v) => setState(() => emailNotifications = v),
            Icons.email,
            Colors.teal,
          ),
          _enhancedSwitchTile(
            "Weekly Reports",
            "Weekly business performance summaries",
            weeklyReports,
            (v) => setState(() => weeklyReports = v),
            Icons.assessment,
            Colors.indigo,
          ),
          _enhancedSwitchTile(
            "Marketing Emails",
            "Tips, updates, and product news",
            marketingEmails,
            (v) => setState(() => marketingEmails = v),
            Icons.campaign,
            Colors.pink,
          ),
          const SizedBox(height: 24),
          _buildNotificationHistory(),
        ],
      ),
    );
  }
  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade50, Colors.purple.shade50],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.info_outline, color: Color(0xFF2563EB)),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "Manage how you receive notifications and stay updated with your business.",
              style: TextStyle(fontSize: 12, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
  Widget _sectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF2563EB)),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  Widget _enhancedSwitchTile(
    String title,
    String sub,
    bool val,
    Function(bool) onChanged,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        secondary: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            sub,
            style: const TextStyle(fontSize: 12),
          ),
        ),
        value: val,
        activeColor: const Color(0xFF2563EB),
        onChanged: onChanged,
      ),
    );
  }
  Widget _buildNotificationHistory() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
            children: [
              const Icon(Icons.history, size: 20, color: Color(0xFF2563EB)),
              const SizedBox(width: 8),
              const Text(
                "Recent Notifications",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _notificationHistoryItem(
            "Payment Received",
            "Invoice #1024 was paid",
            "2 hours ago",
            Icons.payments,
            Colors.green,
          ),
          _notificationHistoryItem(
            "New Appointment",
            "Client meeting scheduled for tomorrow",
            "5 hours ago",
            Icons.calendar_today,
            Colors.blue,
          ),
          _notificationHistoryItem(
            "Invoice Overdue",
            "Invoice #1020 is 3 days overdue",
            "1 day ago",
            Icons.warning,
            Colors.orange,
          ),
        ],
      ),
    );
  }
  Widget _notificationHistoryItem(
    String title,
    String message,
    String time,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}