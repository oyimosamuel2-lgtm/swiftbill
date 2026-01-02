import 'package:flutter/material.dart';

class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});
  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  bool twoFactorEnabled = true;
  bool biometricEnabled = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6F9),
      appBar: AppBar(
        title: const Text("Security",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSecurityScore(),
          const SizedBox(height: 24),
          const Text("Authentication",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _enhancedSecurityItem(
            "Change Password",
            "Last changed 3 months ago",
            Icons.lock_outline,
            Colors.blue,
            () => _showChangePasswordDialog(),
          ),
          _securityToggle(
            "Two-Factor Authentication",
            "Extra security with SMS verification",
            Icons.verified_user_outlined,
            Colors.green,
            twoFactorEnabled,
            (v) => setState(() => twoFactorEnabled = v),
          ),
          _securityToggle(
            "Biometric Login",
            "Use fingerprint or Face ID",
            Icons.fingerprint,
            Colors.purple,
            biometricEnabled,
            (v) => setState(() => biometricEnabled = v),
          ),
          const SizedBox(height: 24),
          const Text("Account Management",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _enhancedSecurityItem(
            "Active Sessions",
            "Manage logged-in devices",
            Icons.devices,
            Colors.orange,
            () => _showActiveSessions(),
          ),
          _enhancedSecurityItem(
            "Login History",
            "View recent login activity",
            Icons.history,
            Colors.teal,
            () => _showLoginHistory(),
          ),
          const SizedBox(height: 24),
          const Text("Privacy",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _enhancedSecurityItem(
            "Download My Data",
            "Export your business data",
            Icons.download,
            Colors.indigo,
            () => _downloadData(),
          ),
          _enhancedSecurityItem(
            "Delete Account",
            "Permanently remove your account",
            Icons.delete_forever_outlined,
            Colors.red,
            () => _showDeleteConfirmation(),
            isDanger: true,
          ),
        ],
      ),
    );
  }
  Widget _buildSecurityScore() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.green.shade400, Colors.teal.shade400],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.shield, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Security Score",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Strong",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Text(
                "85%",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: 0.85,
              minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "Your account is well protected. Consider enabling biometric login for even better security.",
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
  Widget _enhancedSecurityItem(
    String title,
    String sub,
    IconData icon,
    Color color,
    VoidCallback onTap, {
    bool isDanger = false,
  }) {
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
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: isDanger ? Colors.red : Colors.black,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            sub,
            style: const TextStyle(fontSize: 12),
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: isDanger ? Colors.red : Colors.grey,
          size: 20,
        ),
        onTap: onTap,
      ),
    );
  }
  Widget _securityToggle(
    String title,
    String sub,
    IconData icon,
    Color color,
    bool value,
    Function(bool) onChanged,
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
        value: value,
        activeColor: const Color(0xFF2563EB),
        onChanged: onChanged,
      ),
    );
  }
  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Change Password"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Current Password",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: "New Password",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Confirm Password",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Password changed successfully"),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text("Change"),
          ),
        ],
      ),
    );
  }
  void _showActiveSessions() {
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
            const Text("Active Sessions",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _sessionItem("Current Device", "Now", true),
            _sessionItem("iPhone 12", "2 hours ago", false),
            _sessionItem("MacBook Pro", "Yesterday", false),
          ],
        ),
      ),
    );
  }
  Widget _sessionItem(String device, String time, bool isCurrent) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: const Color(0xFF2563EB).withOpacity(0.1),
        child: Icon(
          isCurrent ? Icons.phone_iphone : Icons.devices,
          color: const Color(0xFF2563EB),
        ),
      ),
      title: Text(device),
      subtitle: Text(time),
      trailing: isCurrent
        ? const Chip(
            label: Text("Current", style: TextStyle(fontSize: 11)),
            backgroundColor: Colors.green,
            labelStyle: TextStyle(color: Colors.white),
          )
        : TextButton(
            onPressed: () {},
            child: const Text("Revoke"),
          ),
    );
  }
  void _showLoginHistory() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Login history feature coming soon")),
    );
  }
  void _downloadData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Preparing your data for download..."),
        backgroundColor: Colors.green,
      ),
    );
  }
  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Account"),
        content: const Text(
          "This action is permanent and cannot be undone. All your data will be deleted.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Account deletion initiated"),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}