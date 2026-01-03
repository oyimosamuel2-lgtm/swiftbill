import 'package:flutter/material.dart';
import 'package:swiftbill_app/business_data.dart';

class DocumentsPage extends StatefulWidget {
  const DocumentsPage({super.key});
  @override
  State<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> {
  String selectedFilter = "All";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6F9),
      appBar: AppBar(
        title: const Text("Documents", 
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list, color: Colors.black),
            onSelected: (value) {
              setState(() {
                selectedFilter = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: "All", child: Text("All Documents")),
              const PopupMenuItem(value: "Paid", child: Text("Paid")),
              const PopupMenuItem(value: "Pending", child: Text("Pending")),
              const PopupMenuItem(value: "Partial", child: Text("Partial Payment")),
            ],
          ),
        ],
      ),
      body: ValueListenableBuilder<List<Invoice>>(
        valueListenable: BusinessData().invoices,
        builder: (context, invoices, child) {
          if (invoices.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.description, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text("No documents yet",
                    style: TextStyle(color: Colors.grey, fontSize: 16)),
                  const SizedBox(height: 8),
                  const Text("Create your first invoice to get started",
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            );
          }
          final filtered = selectedFilter == "All" 
            ? invoices 
            : invoices.where((inv) => inv.status == selectedFilter).toList();
          return Column(
            children: [
              _buildSummaryCards(invoices),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("${filtered.length} Documents",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      )),
                    Text("Filter: $selectedFilter",
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      )),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    return _invoiceCard(filtered[index]);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
  Widget _buildSummaryCards(List<Invoice> invoices) {
    final total = invoices.fold(0.0, (sum, inv) => sum + inv.amount);
    final paid = invoices.fold(0.0, (sum, inv) => sum + inv.paid);
    final pending = total - paid;
    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: _summaryCard(
              "Total",
              "UGX ${_formatAmount(total)}",
              Icons.receipt_long,
              Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _summaryCard(
              "Received",
              "UGX ${_formatAmount(paid)}",
              Icons.check_circle,
              Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _summaryCard(
              "Pending",
              "UGX ${_formatAmount(pending)}",
              Icons.pending,
              Colors.orange,
            ),
          ),
        ],
      ),
    );
  }
  Widget _summaryCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(label,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                )),
            ],
          ),
        ],
      ),
    );
  }
  Widget _invoiceCard(Invoice invoice) {
    Color statusColor = invoice.status == "Paid" ? Colors.green :
                       invoice.status == "Partial" ? Colors.orange :
                       Colors.red;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.all(16),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.description, color: statusColor, size: 24),
        ),
        title: Text(invoice.id,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          )),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(invoice.customerName,
              style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 2),
            Text(_formatDate(invoice.date),
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
              )),
          ],
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(invoice.status,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                )),
            ),
            const SizedBox(height: 4),
            Text("UGX ${_formatAmount(invoice.amount)}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              )),
          ],
        ),
        children: [
          const Divider(),
          const SizedBox(height: 8),
          _detailRow("Items", invoice.items.length.toString()),
          const SizedBox(height: 8),
          _detailRow("Amount", "UGX ${_formatAmount(invoice.amount)}"),
          const SizedBox(height: 8),
          _detailRow("Paid", "UGX ${_formatAmount(invoice.paid)}"),
          const SizedBox(height: 8),
          _detailRow("Balance", "UGX ${_formatAmount(invoice.balance)}",
            valueColor: invoice.balance > 0 ? Colors.red : Colors.green),
          const SizedBox(height: 16),
          const Text("Items:",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
            )),
          const SizedBox(height: 8),
          ...invoice.items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(item.description,
                    style: const TextStyle(fontSize: 12)),
                ),
                Text("${item.quantity.toStringAsFixed(0)} × ${_formatAmount(item.rate)}",
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  )),
              ],
            ),
          )),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _downloadInvoice(invoice),
                  icon: const Icon(Icons.download, size: 16),
                  label: const Text("Download"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _shareInvoice(invoice),
                  icon: const Icon(Icons.share,color: Colors.white, size: 16),
                  label: const Text("Share",style: TextStyle(color: Colors.white),),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  Widget _detailRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 13,
          )),
        Text(value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: valueColor,
          )),
      ],
    );
  }
  String _formatAmount(double amount) {
    if (amount >= 1000000) {
      return "${(amount / 1000000).toStringAsFixed(1)}M";
    } else if (amount >= 1000) {
      return "${(amount / 1000).toStringAsFixed(0)}K";
    }
    return amount.toStringAsFixed(0);
  }
  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
  void _downloadInvoice(Invoice invoice) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${invoice.id} downloaded"),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
  void _shareInvoice(Invoice invoice) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Sharing ${invoice.id}..."),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}