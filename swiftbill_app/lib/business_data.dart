import 'package:flutter/material.dart';

// Models
class Invoice {
  final String id;
  final String customerName;
  final String customerEmail;
  final double amount;
  final double paid;
  final DateTime date;
  final String status;
  final List<InvoiceItem> items;
  
  Invoice({
    required this.id,
    required this.customerName,
    required this.customerEmail,
    required this.amount,
    required this.paid,
    required this.date,
    required this.status,
    required this.items,
  });
  
  double get balance => amount - paid;
}

class InvoiceItem {
  final String description;
  final double quantity;
  final double rate;
  
  InvoiceItem({
    required this.description,
    required this.quantity,
    required this.rate,
  });
  
  double get amount => quantity * rate;
}

class Appointment {
  final String id;
  final String type;
  final String clientName;
  final DateTime dateTime;
  final String status;
  final double? fee;
  
  Appointment({
    required this.id,
    required this.type,
    required this.clientName,
    required this.dateTime,
    required this.status,
    this.fee,
  });
}

class Client {
  final String id;
  final String name;
  final String email;
  final String phone;
  final DateTime addedDate;
  final double totalRevenue;
  
  Client({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.addedDate,
    required this.totalRevenue,
  });
}

class Activity {
  final String id;
  final String title;
  final String type;
  final DateTime timestamp;
  final String? amount;
  final IconData icon;
  final Color color;
  
  Activity({
    required this.id,
    required this.title,
    required this.type,
    required this.timestamp,
    this.amount,
    required this.icon,
    required this.color,
  });
}

// Enhanced Business Data Manager
class BusinessData {
  static final BusinessData _instance = BusinessData._internal();
  factory BusinessData() => _instance;
  BusinessData._internal() {
    _initializeSampleData();
  }
  
  // Business Profile
  final ValueNotifier<String> name = ValueNotifier<String>("My Business");
  final ValueNotifier<String> email = ValueNotifier<String>("hello@business.com");
  final ValueNotifier<String> address = ValueNotifier<String>("Plot 12, Kampala Road, Uganda");
  final ValueNotifier<String?> logoPath = ValueNotifier<String?>(null);
  
  // Data Lists
  final ValueNotifier<List<Invoice>> invoices = ValueNotifier<List<Invoice>>([]);
  final ValueNotifier<List<Appointment>> appointments = ValueNotifier<List<Appointment>>([]);
  final ValueNotifier<List<Client>> clients = ValueNotifier<List<Client>>([]);
  final ValueNotifier<List<Activity>> activities = ValueNotifier<List<Activity>>([]);
  
  void updateBusiness({required String newName, required String newEmail, required String newAddress}) {
    name.value = newName;
    email.value = newEmail;
    address.value = newAddress;
  }
  
  // Invoice Management
  void addInvoice(Invoice invoice) {
    invoices.value = [...invoices.value, invoice];
    _addActivity(
      title: "Invoice ${invoice.id} Created",
      type: "invoice",
      amount: "+UGX ${invoice.amount.toStringAsFixed(0)}",
      icon: Icons.receipt_long,
      color: Colors.blue,
    );
  }
  
  void updateInvoicePayment(String invoiceId, double paidAmount) {
    final updatedInvoices = invoices.value.map((inv) {
      if (inv.id == invoiceId) {
        return Invoice(
          id: inv.id,
          customerName: inv.customerName,
          customerEmail: inv.customerEmail,
          amount: inv.amount,
          paid: paidAmount,
          date: inv.date,
          status: paidAmount >= inv.amount ? "Paid" : "Partial",
          items: inv.items,
        );
      }
      return inv;
    }).toList();
    invoices.value = updatedInvoices;
    
    if (paidAmount > 0) {
      _addActivity(
        title: "Payment Received",
        type: "payment",
        amount: "+UGX ${paidAmount.toStringAsFixed(0)}",
        icon: Icons.payments,
        color: Colors.green,
      );
    }
  }
  
  // Appointment Management
  void addAppointment(Appointment appointment) {
    appointments.value = [...appointments.value, appointment];
    _addActivity(
      title: "${appointment.type} Booked",
      type: "appointment",
      amount: appointment.fee != null ? "UGX ${appointment.fee!.toStringAsFixed(0)}" : null,
      icon: Icons.calendar_today,
      color: Colors.orange,
    );
  }
  
  void updateAppointmentStatus(String appointmentId, String status) {
    final updatedAppointments = appointments.value.map((apt) {
      if (apt.id == appointmentId) {
        return Appointment(
          id: apt.id,
          type: apt.type,
          clientName: apt.clientName,
          dateTime: apt.dateTime,
          status: status,
          fee: apt.fee,
        );
      }
      return apt;
    }).toList();
    appointments.value = updatedAppointments;
  }
  
  // Client Management
  void addClient(Client client) {
    clients.value = [...clients.value, client];
    _addActivity(
      title: "New Client: ${client.name}",
      type: "client",
      icon: Icons.person_add,
      color: Colors.purple,
    );
  }
  
  // Activity Management
  void _addActivity({
    required String title,
    required String type,
    String? amount,
    required IconData icon,
    required Color color,
  }) {
    final activity = Activity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      type: type,
      timestamp: DateTime.now(),
      amount: amount,
      icon: icon,
      color: color,
    );
    activities.value = [activity, ...activities.value];
  }
  
  // Analytics Calculations
  double getTotalRevenue() {
    return invoices.value.fold(0.0, (sum, inv) => sum + inv.paid);
  }
  
  double getOutstandingAmount() {
    return invoices.value.fold(0.0, (sum, inv) => sum + inv.balance);
  }
  
  double getAverageInvoice() {
    if (invoices.value.isEmpty) return 0.0;
    final total = invoices.value.fold(0.0, (sum, inv) => sum + inv.amount);
    return total / invoices.value.length;
  }
  
  int getActiveClientsCount() {
    return clients.value.length;
  }
  
  int getPendingInvoicesCount() {
    return invoices.value.where((inv) => inv.status != "Paid").length;
  }
  
  List<Invoice> getRecentInvoices({int limit = 5}) {
    final sorted = [...invoices.value]..sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(limit).toList();
  }
  
  List<Appointment> getUpcomingAppointments() {
    final now = DateTime.now();
    return appointments.value
        .where((apt) => apt.dateTime.isAfter(now) && apt.status != "Completed")
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }
  
  List<Activity> getRecentActivities({int limit = 10}) {
    return activities.value.take(limit).toList();
  }
  
  Map<String, double> getRevenueByCategory() {
    // Categorize based on invoice items
    Map<String, double> categoryRevenue = {
      'Consultations': 0.0,
      'Product Sales': 0.0,
      'Service Fees': 0.0,
    };
    
    for (var invoice in invoices.value) {
      for (var item in invoice.items) {
        final desc = item.description.toLowerCase();
        if (desc.contains('consult')) {
          categoryRevenue['Consultations'] = 
            (categoryRevenue['Consultations'] ?? 0) + item.amount;
        } else if (desc.contains('product')) {
          categoryRevenue['Product Sales'] = 
            (categoryRevenue['Product Sales'] ?? 0) + item.amount;
        } else {
          categoryRevenue['Service Fees'] = 
            (categoryRevenue['Service Fees'] ?? 0) + item.amount;
        }
      }
    }
    
    return categoryRevenue;
  }
  
  // Initialize with sample data
  void _initializeSampleData() {
    // Sample Clients
    clients.value = [
      Client(
        id: "C001",
        name: "John Doe",
        email: "john@example.com",
        phone: "+256 772 123 456",
        addedDate: DateTime.now().subtract(const Duration(days: 30)),
        totalRevenue: 850000,
      ),
      Client(
        id: "C002",
        name: "Jane Smith",
        email: "jane@example.com",
        phone: "+256 772 234 567",
        addedDate: DateTime.now().subtract(const Duration(days: 20)),
        totalRevenue: 650000,
      ),
      Client(
        id: "C003",
        name: "Bob Wilson",
        email: "bob@example.com",
        phone: "+256 772 345 678",
        addedDate: DateTime.now().subtract(const Duration(days: 10)),
        totalRevenue: 450000,
      ),
    ];
    
    // Sample Invoices
    invoices.value = [
      Invoice(
        id: "INV-001",
        customerName: "John Doe",
        customerEmail: "john@example.com",
        amount: 500000,
        paid: 500000,
        date: DateTime.now().subtract(const Duration(days: 2)),
        status: "Paid",
        items: [
          InvoiceItem(description: "Consultation Service", quantity: 2, rate: 250000),
        ],
      ),
      Invoice(
        id: "INV-002",
        customerName: "Jane Smith",
        customerEmail: "jane@example.com",
        amount: 750000,
        paid: 400000,
        date: DateTime.now().subtract(const Duration(days: 5)),
        status: "Partial",
        items: [
          InvoiceItem(description: "Product Package", quantity: 1, rate: 750000),
        ],
      ),
      Invoice(
        id: "INV-003",
        customerName: "Bob Wilson",
        customerEmail: "bob@example.com",
        amount: 300000,
        paid: 0,
        date: DateTime.now().subtract(const Duration(days: 1)),
        status: "Pending",
        items: [
          InvoiceItem(description: "Service Fee", quantity: 3, rate: 100000),
        ],
      ),
    ];
    
    // Sample Appointments
    appointments.value = [
      Appointment(
        id: "APT-001",
        type: "Client Meeting",
        clientName: "John Doe",
        dateTime: DateTime.now().add(const Duration(hours: 2)),
        status: "Confirmed",
        fee: 150000,
      ),
      Appointment(
        id: "APT-002",
        type: "Product Demo",
        clientName: "Jane Smith",
        dateTime: DateTime.now().add(const Duration(days: 1)),
        status: "Confirmed",
        fee: 200000,
      ),
      Appointment(
        id: "APT-003",
        type: "Consultation",
        clientName: "New Client",
        dateTime: DateTime.now().add(const Duration(days: 2)),
        status: "Pending",
        fee: 100000,
      ),
    ];
    
    // Sample Activities
    activities.value = [
      Activity(
        id: "ACT-001",
        title: "Invoice INV-001 Paid",
        type: "payment",
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        amount: "+UGX 500,000",
        icon: Icons.check_circle,
        color: Colors.green,
      ),
      Activity(
        id: "ACT-002",
        title: "New Appointment Booked",
        type: "appointment",
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        icon: Icons.calendar_today,
        color: Colors.blue,
      ),
      Activity(
        id: "ACT-003",
        title: "Payment Received",
        type: "payment",
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        amount: "+UGX 400,000",
        icon: Icons.payments,
        color: Colors.orange,
      ),
    ];
  }
}