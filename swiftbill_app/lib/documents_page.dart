// Updated documents_page.dart with fixes for const_with_non_const errors:
// - Removed 'const' from Row children lists where Expanded is used (lines around 563 and 579, and similar in dialog)
// - Added 'const' to TextStyle in the dialog for consistency

import 'package:flutter/material.dart';
import 'package:swiftbill_app/business_data.dart';
import 'package:swiftbill_app/download_utils.dart';

class DocumentsPage extends StatefulWidget {
  final String initialFilter;
  const DocumentsPage({super.key, this.initialFilter = "All"});
  @override
  State<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> {
  late String selectedFilter;
  String selectedType = "All";
  
  @override
  void initState() {
    super.initState();
    selectedFilter = widget.initialFilter;
  }
  
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
            onSelected: (value) => setState(() => selectedFilter = value),
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
                  const Text("No documents yet", style: TextStyle(color: Colors.grey, fontSize: 16)),
                  const SizedBox(height: 8),
                  const Text("Create your first invoice or receipt to get started",
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            );
          }
          
          List<Invoice> typeFiltered = invoices;
          if (selectedType == "Invoices") {
            typeFiltered = invoices.where((inv) => inv.id.startsWith('INV')).toList();
          } else if (selectedType == "Receipts") {
            typeFiltered = invoices.where((inv) => inv.id.startsWith('RCP')).toList();
          }
          
          List<Invoice> filtered = typeFiltered;
          if (selectedFilter == "Pending") {
            filtered = typeFiltered.where((inv) => inv.balance > 0).toList();
          } else if (selectedFilter != "All") {
            filtered = typeFiltered.where((inv) => inv.status == selectedFilter).toList();
          }
          
          return Column(
            children: [
              _buildSummaryCards(invoices),
              const SizedBox(height: 16),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
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
                    children: ["All", "Invoices", "Receipts"].map((type) {
                      bool isSelected = selectedType == type;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => selectedType = type),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF2563EB) : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                type,
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
                ),
              ),
              
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("${filtered.length} Document${filtered.length != 1 ? 's' : ''}",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getFilterColor(selectedFilter).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _getFilterColor(selectedFilter).withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_getFilterIcon(selectedFilter), size: 14, color: _getFilterColor(selectedFilter)),
                          const SizedBox(width: 6),
                          Text(selectedFilter,
                            style: TextStyle(
                              color: _getFilterColor(selectedFilter),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.filter_list_off, size: 48, color: Colors.grey.shade300),
                            const SizedBox(height: 12),
                            Text("No $selectedFilter ${selectedType.toLowerCase()} found",
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) => _invoiceCard(filtered[index]),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
  
  Color _getFilterColor(String filter) {
    switch (filter) {
      case "Paid": return Colors.green;
      case "Partial": return Colors.orange;
      case "Pending": return Colors.red;
      default: return const Color(0xFF2563EB);
    }
  }
  
  IconData _getFilterIcon(String filter) {
    switch (filter) {
      case "Paid": return Icons.check_circle;
      case "Partial": return Icons.hourglass_empty;
      case "Pending": return Icons.pending;
      default: return Icons.description;
    }
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
          Expanded(child: _summaryCard("Total", "UGX ${_formatAmount(total)}", Icons.receipt_long, Colors.blue)),
          const SizedBox(width: 12),
          Expanded(child: _summaryCard("Received", "UGX ${_formatAmount(paid)}", Icons.check_circle, Colors.green)),
          const SizedBox(width: 12),
          Expanded(child: _summaryCard("Pending", "UGX ${_formatAmount(pending)}", Icons.pending, Colors.orange)),
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                maxLines: 1, overflow: TextOverflow.ellipsis),
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _invoiceCard(Invoice invoice) {
    Color statusColor = invoice.status == "Paid" ? Colors.green :
                       invoice.status == "Partial" ? Colors.orange : Colors.red;
    bool isReceipt = invoice.id.startsWith('RCP');
    String documentType = isReceipt ? "Receipt" : "Invoice";
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.all(16),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(isReceipt ? Icons.receipt : Icons.description, color: statusColor, size: 24),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(invoice.id, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isReceipt ? Colors.purple.withOpacity(0.1) : const Color(0xFF2563EB).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(documentType,
                style: TextStyle(
                  color: isReceipt ? Colors.purple : const Color(0xFF2563EB),
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                )),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(invoice.customerName, style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 2),
            Text(_formatDate(invoice.date), style: const TextStyle(fontSize: 11, color: Colors.grey)),
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
                style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 4),
            Text("UGX ${_formatAmount(invoice.amount)}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
        children: [
          const Divider(),
          const SizedBox(height: 12),
          
          // Business Details
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.business, size: 16, color: Colors.blue.shade700),
                    const SizedBox(width: 8),
                    const Text("Business Details", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blue)),
                  ],
                ),
                const SizedBox(height: 8),
                ValueListenableBuilder<String>(
                  valueListenable: BusinessData().name,
                  builder: (context, businessName, _) => Text(businessName,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 4),
                ValueListenableBuilder<String>(
                  valueListenable: BusinessData().email,
                  builder: (context, businessEmail, _) => Text(businessEmail,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
                ),
                const SizedBox(height: 2),
                ValueListenableBuilder<String>(
                  valueListenable: BusinessData().address,
                  builder: (context, businessAddress, _) => Text(businessAddress,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Customer Details
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.person, size: 16, color: Colors.green.shade700),
                    const SizedBox(width: 8),
                    Text(isReceipt ? "Received From" : "Billed To",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.green)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(invoice.customerName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(invoice.customerEmail, style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          _detailRow("Document Type", documentType),
          const SizedBox(height: 8),
          _detailRow("Items", invoice.items.length.toString()),
          const SizedBox(height: 8),
          _detailRow("Total Amount", "UGX ${_formatAmount(invoice.amount)}"),
          const SizedBox(height: 8),
          _detailRow("Amount Paid", "UGX ${_formatAmount(invoice.paid)}", valueColor: Colors.green),
          
          if (invoice.balance > 0) ...[
            const SizedBox(height: 8),
            _detailRow("Balance Due", "UGX ${_formatAmount(invoice.balance)}", valueColor: Colors.red),
          ],
          
          if (invoice.id.startsWith('RCP') && invoice.paid > invoice.amount) ...[
            const SizedBox(height: 8),
            _detailRow("Change Due", "UGX ${_formatAmount(invoice.paid - invoice.amount)}", valueColor: Colors.orange),
          ],
          
          if (invoice.balance > 0 && invoice.paid > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.orange, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(isReceipt ? "Underpayment - Change Owed to Business" : "Partial Payment",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.orange)),
                        const SizedBox(height: 2),
                        Text("${((invoice.paid / invoice.amount) * 100).toStringAsFixed(1)}% paid",
                          style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          if (invoice.id.startsWith('RCP') && invoice.paid > invoice.amount) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Overpayment - Change Due to Customer",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blue)),
                        const SizedBox(height: 2),
                        Text("Return UGX ${_formatAmount(invoice.paid - invoice.amount)} to customer",
                          style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 16),
          const Text("Items:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 8),
          ...invoice.items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(item.description, style: const TextStyle(fontSize: 12))),
                Text("${item.quantity.toStringAsFixed(0)} × ${_formatAmount(item.rate)}",
                  style: const TextStyle(fontSize: 11, color: Colors.grey)),
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
                  style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.grey.shade300)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _shareInvoice(invoice),
                  icon: const Icon(Icons.share, color: Colors.white, size: 16),
                  label: const Text("Share", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB)),
                ),
              ),
            ],
          ),
          
          if (invoice.balance > 0) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showEditPaymentDialog(invoice),
                icon: const Icon(Icons.payments, color: Colors.white, size: 16),
                label: const Text("Update Payment", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _detailRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        Text(value, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: valueColor)),
      ],
    );
  }
  
  String _formatAmount(double amount) {
    if (amount >= 1000000) return "${(amount / 1000000).toStringAsFixed(1)}M";
    if (amount >= 1000) return "${(amount / 1000).toStringAsFixed(0)}K";
    return amount.toStringAsFixed(0);
  }
  
  String _formatDate(DateTime date) => "${date.day}/${date.month}/${date.year}";
  
  Future<void> _downloadInvoice(Invoice invoice) async {
    final path = await DownloadUtils.exportInvoiceToPDF(invoice, context);
    if (path != null) {
      DownloadUtils.showDownloadSuccess(context, path);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Failed to download document"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }
  
  Future<void> _shareInvoice(Invoice invoice) async {
    final path = await DownloadUtils.exportInvoiceToPDF(invoice, context);
    if (path != null) {
      await DownloadUtils.shareFile(path, context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Failed to generate document for sharing"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }
  
  void _showEditPaymentDialog(Invoice invoice) {
    final paymentController = TextEditingController(
      text: invoice.paid > 0 ? invoice.paid.toStringAsFixed(0) : '',
    );
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.payments, color: Colors.green),
            ),
            const SizedBox(width: 12),
            const Expanded(child: Text("Update Payment", style: TextStyle(fontSize: 18))),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Document:", style: TextStyle(fontSize: 12)),
                      Text(invoice.id, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Total Amount:", style: TextStyle(fontSize: 12)),
                      Text("UGX ${invoice.amount.toStringAsFixed(0)}", 
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Balance Due:", style: TextStyle(fontSize: 12)),
                      Text("UGX ${invoice.balance.toStringAsFixed(0)}", 
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.red)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text("Enter Total Amount Paid:",
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: paymentController,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                labelText: "Amount Paid (UGX)",
                hintText: "0",
                prefixIcon: const Icon(Icons.money, color: Colors.green),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.green, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 16, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Enter the total cumulative amount paid, not just the new payment.",
                      style: const TextStyle(fontSize: 11, color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              final newPaid = double.tryParse(paymentController.text) ?? 0.0;
              
              if (newPaid < 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Amount cannot be negative"), backgroundColor: Colors.red),
                );
                return;
              }
              
              BusinessData().updateInvoicePayment(invoice.id, newPaid);
              Navigator.pop(context);
              
              String message;
              if (newPaid >= invoice.amount) {
                message = "Payment updated! Invoice is now fully paid.";
              } else if (newPaid > invoice.paid) {
                message = "Payment updated! Remaining balance: UGX ${(invoice.amount - newPaid).toStringAsFixed(0)}";
              } else {
                message = "Payment updated successfully!";
              }
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(child: Text(message)),
                    ],
                  ),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Update Payment", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}