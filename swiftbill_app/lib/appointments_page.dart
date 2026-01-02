import 'package:flutter/material.dart';
import 'package:swiftbill_app/client_meeting_page.dart';
import 'package:swiftbill_app/product_demo_page.dart';
import 'package:swiftbill_app/consultation_page.dart';
import 'package:swiftbill_app/business_data.dart';

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key});
  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6F9),
      appBar: AppBar(
        title: const Text("Appointments", 
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF2563EB),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF2563EB),
          tabs: const [
            Tab(text: "Book New"),
            Tab(text: "Scheduled"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBookingCategories(),
          _buildScheduledAppointments(),
        ],
      ),
    );
  }
  Widget _buildBookingCategories() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildStatsRow(),
        const SizedBox(height: 24),
        const Text("Booking Categories", 
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _enhancedBookingItem(
          context,
          "Client Meeting",
          "Schedule structured client discussions",
          Icons.groups,
          Colors.blue.shade50,
          Colors.blue,
          "45 min average",
          const ClientMeetingPage(),
        ),
        _enhancedBookingItem(
          context,
          "Product Demo",
          "Showcase your products to prospects",
          Icons.play_circle_outline,
          Colors.orange.shade50,
          Colors.orange,
          "1 hour session",
          const ProductDemoPage(),
        ),
        _enhancedBookingItem(
          context,
          "Consultation",
          "Expert advice and session booking",
          Icons.psychology,
          Colors.green.shade50,
          Colors.green,
          "30-60 min",
          const ConsultationPage(),
        ),
      ],
    );
  }
  Widget _buildStatsRow() {
    return ValueListenableBuilder<List<Appointment>>(
      valueListenable: BusinessData().appointments,
      builder: (context, appointments, child) {
        final upcoming = appointments.where((apt) => 
          apt.dateTime.isAfter(DateTime.now()) && apt.status != "Completed"
        ).length;
        final today = appointments.where((apt) => 
          apt.dateTime.day == DateTime.now().day &&
          apt.dateTime.month == DateTime.now().month
        ).length;
        return Row(
          children: [
            Expanded(child: _statCard("Upcoming", upcoming.toString(), Icons.schedule, Colors.blue)),
            const SizedBox(width: 12),
            Expanded(child: _statCard("Today", today.toString(), Icons.today, Colors.green)),
          ],
        );
      },
    );
  }
  Widget _statCard(String label, String value, IconData icon, Color color) {
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
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(value, 
            style: const TextStyle(
              fontSize: 24, 
              fontWeight: FontWeight.bold
            )),
          Text(label, 
            style: const TextStyle(
              color: Colors.grey, 
              fontSize: 12
            )),
        ],
      ),
    );
  }
  Widget _buildScheduledAppointments() {
    return ValueListenableBuilder<List<Appointment>>(
      valueListenable: BusinessData().appointments,
      builder: (context, appointments, child) {
        if (appointments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calendar_today, size: 64, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                const Text("No appointments scheduled",
                  style: TextStyle(color: Colors.grey, fontSize: 16)),
              ],
            ),
          );
        }
        final upcoming = appointments.where((apt) => 
          apt.dateTime.isAfter(DateTime.now())
        ).toList()..sort((a, b) => a.dateTime.compareTo(b.dateTime));
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: upcoming.length,
          itemBuilder: (context, index) {
            return _appointmentCard(upcoming[index]);
          },
        );
      },
    );
  }
  Widget _appointmentCard(Appointment appointment) {
    final isToday = appointment.dateTime.day == DateTime.now().day &&
                    appointment.dateTime.month == DateTime.now().month;
    Color statusColor = appointment.status == "Confirmed" ? Colors.green :
                       appointment.status == "Pending" ? Colors.orange :
                       Colors.grey;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isToday ? Border.all(color: const Color(0xFF2563EB), width: 2) : null,
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(appointment.status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  )),
              ),
              const Spacer(),
              if (isToday)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text("TODAY",
                    style: TextStyle(
                      color: Color(0xFF2563EB),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    )),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(appointment.type,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            )),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.person, size: 16, color: Colors.grey),
              const SizedBox(width: 6),
              Text(appointment.clientName,
                style: const TextStyle(color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.access_time, size: 16, color: Colors.grey),
              const SizedBox(width: 6),
              Text(_formatDateTime(appointment.dateTime),
                style: const TextStyle(color: Colors.grey)),
              const Spacer(),
              if (appointment.fee != null)
                Text("UGX ${appointment.fee!.toStringAsFixed(0)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2563EB),
                  )),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _cancelAppointment(appointment.id),
                  icon: const Icon(Icons.close, size: 16),
                  label: const Text("Cancel"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _markCompleted(appointment.id),
                  icon: const Icon(Icons.check, size: 16),
                  label: const Text("Complete"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  Widget _enhancedBookingItem(
    BuildContext context,
    String title,
    String sub,
    IconData icon,
    Color bgColor,
    Color iconColor,
    String duration,
    Widget targetPage,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => targetPage),
          );
          setState(() {});
        },
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 28),
        ),
        title: Text(title, 
          style: const TextStyle(
            fontWeight: FontWeight.bold, 
            fontSize: 16
          )),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(sub, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, size: 12, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(duration, 
                  style: TextStyle(
                    fontSize: 11, 
                    color: Colors.grey.shade600
                  )),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);
    if (difference.inDays == 0) {
      return "Today at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";
    } else if (difference.inDays == 1) {
      return "Tomorrow at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";
    } else {
      return "${dateTime.day}/${dateTime.month} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";
    }
  }
  void _cancelAppointment(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cancel Appointment"),
        content: const Text("Are you sure you want to cancel this appointment?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () {
              BusinessData().updateAppointmentStatus(id, "Cancelled");
              Navigator.pop(context);
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Appointment cancelled")),
              );
            },
            child: const Text("Yes", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  void _markCompleted(String id) {
    BusinessData().updateAppointmentStatus(id, "Completed");
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Appointment marked as completed"),
        backgroundColor: Colors.green,
      ),
    );
  }
}