import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'customerName': customerName,
    'customerEmail': customerEmail,
    'amount': amount,
    'paid': paid,
    'date': date.toIso8601String(),
    'status': status,
    'items': items.map((i) => i.toJson()).toList(),
  };
  
  factory Invoice.fromJson(Map<String, dynamic> json) => Invoice(
    id: json['id'],
    customerName: json['customerName'],
    customerEmail: json['customerEmail'],
    amount: json['amount'],
    paid: json['paid'],
    date: DateTime.parse(json['date']),
    status: json['status'],
    items: (json['items'] as List).map((i) => InvoiceItem.fromJson(i)).toList(),
  );
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
  
  Map<String, dynamic> toJson() => {
    'description': description,
    'quantity': quantity,
    'rate': rate,
  };
  
  factory InvoiceItem.fromJson(Map<String, dynamic> json) => InvoiceItem(
    description: json['description'],
    quantity: json['quantity'],
    rate: json['rate'],
  );
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
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'clientName': clientName,
    'dateTime': dateTime.toIso8601String(),
    'status': status,
    'fee': fee,
  };
  
  factory Appointment.fromJson(Map<String, dynamic> json) => Appointment(
    id: json['id'],
    type: json['type'],
    clientName: json['clientName'],
    dateTime: DateTime.parse(json['dateTime']),
    status: json['status'],
    fee: json['fee'],
  );
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
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'addedDate': addedDate.toIso8601String(),
    'totalRevenue': totalRevenue,
  };
  
  factory Client.fromJson(Map<String, dynamic> json) => Client(
    id: json['id'],
    name: json['name'],
    email: json['email'],
    phone: json['phone'],
    addedDate: DateTime.parse(json['addedDate']),
    totalRevenue: json['totalRevenue'],
  );
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

// Enhanced Business Data Manager with Persistence
class BusinessData {
  static final BusinessData _instance = BusinessData._internal();
  factory BusinessData() => _instance;
  BusinessData._internal() {
    _loadData();
  }
  
  // Business Profile
  final ValueNotifier<String> name = ValueNotifier<String>("My Business");
  final ValueNotifier<String> email = ValueNotifier<String>("hello@business.com");
  final ValueNotifier<String> address = ValueNotifier<String>("Kampala, Uganda");
  final ValueNotifier<String?> logoPath = ValueNotifier<String?>(null);
  
  // Data Lists - Start Empty
  final ValueNotifier<List<Invoice>> invoices = ValueNotifier<List<Invoice>>([]);
  final ValueNotifier<List<Appointment>> appointments = ValueNotifier<List<Appointment>>([]);
  final ValueNotifier<List<Client>> clients = ValueNotifier<List<Client>>([]);
  final ValueNotifier<List<Activity>> activities = ValueNotifier<List<Activity>>([]);
  
  // Load data from SharedPreferences
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load business profile
    name.value = prefs.getString('business_name') ?? "My Business";
    email.value = prefs.getString('business_email') ?? "hello@business.com";
    address.value = prefs.getString('business_address') ?? "Kampala, Uganda";
    logoPath.value = prefs.getString('business_logo');
    
    // Load invoices
    final invoicesJson = prefs.getString('invoices');
    if (invoicesJson != null) {
      final List<dynamic> invoicesList = jsonDecode(invoicesJson);
      invoices.value = invoicesList.map((json) => Invoice.fromJson(json)).toList();
    }
    
    // Load appointments
    final appointmentsJson = prefs.getString('appointments');
    if (appointmentsJson != null) {
      final List<dynamic> appointmentsList = jsonDecode(appointmentsJson);
      appointments.value = appointmentsList.map((json) => Appointment.fromJson(json)).toList();
    }
    
    // Load clients
    final clientsJson = prefs.getString('clients');
    if (clientsJson != null) {
      final List<dynamic> clientsList = jsonDecode(clientsJson);
      clients.value = clientsList.map((json) => Client.fromJson(json)).toList();
    }
  }
  
  // Save data to SharedPreferences
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Save business profile
    await prefs.setString('business_name', name.value);
    await prefs.setString('business_email', email.value);
    await prefs.setString('business_address', address.value);
    if (logoPath.value != null) {
      await prefs.setString('business_logo', logoPath.value!);
    }
    
    // Save invoices
    final invoicesJson = jsonEncode(invoices.value.map((i) => i.toJson()).toList());
    await prefs.setString('invoices', invoicesJson);
    
    // Save appointments
    final appointmentsJson = jsonEncode(appointments.value.map((a) => a.toJson()).toList());
    await prefs.setString('appointments', appointmentsJson);
    
    // Save clients
    final clientsJson = jsonEncode(clients.value.map((c) => c.toJson()).toList());
    await prefs.setString('clients', clientsJson);
  }
  
  void updateBusiness({required String newName, required String newEmail, required String newAddress}) {
    name.value = newName;
    email.value = newEmail;
    address.value = newAddress;
    _saveData();
  }
  
  void updateLogo(String? path) {
    logoPath.value = path;
    _saveData();
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
    _saveData();
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
    _saveData();
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
    _saveData();
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
    _saveData();
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
    _saveData();
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
  
  // Clear all data (for testing or logout)
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    invoices.value = [];
    appointments.value = [];
    clients.value = [];
    activities.value = [];
    name.value = "My Business";
    email.value = "hello@business.com";
    address.value = "Kampala, Uganda";
    logoPath.value = null;
  }
}