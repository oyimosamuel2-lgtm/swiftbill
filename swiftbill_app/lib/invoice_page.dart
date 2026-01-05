import 'package:flutter/material.dart';
import 'package:swiftbill_app/business_data.dart';

class InvoicePage extends StatefulWidget {
  const InvoicePage({super.key});
  @override
  State<InvoicePage> createState() => _InvoicePageState();
}

class _InvoicePageState extends State<InvoicePage> {
  final _formKey = GlobalKey<FormState>();
  bool isInvoice = true;
  String selectedCurrency = 'UGX (USh)';
  final _customerNameController = TextEditingController();
  final _customerEmailController = TextEditingController();
  final _customerAddressController = TextEditingController();
  final _notesController = TextEditingController();
  List<TextEditingController> descControllers = [];
  List<TextEditingController> qtyControllers = [];
  List<TextEditingController> rateControllers = [];
  List<double> amounts = [];
  TextEditingController paidController = TextEditingController(text: '0');
  final _paymentMethodController = TextEditingController(text: 'Cash');
  double total = 0.0;
  double paid = 0.0;
  double due = 0.0;
  bool isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _addLineItem();
    paidController.addListener(_updateTotal);
  }
  
  void _addLineItem() {
    setState(() {
      descControllers.add(TextEditingController(text: ''));
      qtyControllers.add(TextEditingController(text: '1'));
      rateControllers.add(TextEditingController(text: '0'));
      amounts.add(0.0);
    });
  }
  
  void _removeLineItem(int index) {
    setState(() {
      descControllers[index].dispose();
      qtyControllers[index].dispose();
      rateControllers[index].dispose();
      descControllers.removeAt(index);
      qtyControllers.removeAt(index);
      rateControllers.removeAt(index);
      amounts.removeAt(index);
      _updateTotal();
    });
  }
  
  void _updateAmount(int index) {
    double qty = double.tryParse(qtyControllers[index].text) ?? 0.0;
    double rate = double.tryParse(rateControllers[index].text) ?? 0.0;
    amounts[index] = qty * rate;
    _updateTotal();
  }
  
  void _updateTotal() {
    total = amounts.fold(0.0, (sum, item) => sum + item);
    paid = double.tryParse(paidController.text) ?? 0.0;
    due = total - paid;
    setState(() {});
  }
  
  @override
  void dispose() {
    _customerNameController.dispose();
    _customerEmailController.dispose();
    _customerAddressController.dispose();
    _notesController.dispose();
    _paymentMethodController.dispose();
    for (var controller in descControllers) {
      controller.dispose();
    }
    for (var controller in qtyControllers) {
      controller.dispose();
    }
    for (var controller in rateControllers) {
      controller.dispose();
    }
    paidController.dispose();
    super.dispose();
  }
  
  void _showPreview() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          String currencyPrefix = selectedCurrency.split(' ')[0] == 'UGX' ? 'USh' : '\$';
          String invoiceId = isInvoice 
              ? "INV-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}"
              : "RCP-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}";
          
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isInvoice ? const Color(0xFF2563EB) : Colors.green.shade600,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isInvoice ? Icons.visibility : Icons.receipt_long,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          isInvoice ? "Invoice Preview" : "Receipt Preview",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(20),
                    children: [
                      // Business Details
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Colors.blue.shade50, Colors.purple.shade50],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue.withOpacity(0.2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.business, color: Colors.blue.shade700, size: 20),
                                const SizedBox(width: 8),
                                const Text(
                                  "FROM",
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ValueListenableBuilder<String>(
                              valueListenable: BusinessData().name,
                              builder: (context, name, _) => Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            ValueListenableBuilder<String>(
                              valueListenable: BusinessData().email,
                              builder: (context, email, _) => Text(
                                email,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                            const SizedBox(height: 2),
                            ValueListenableBuilder<String>(
                              valueListenable: BusinessData().address,
                              builder: (context, address, _) => Text(
                                address,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Document Info
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isInvoice ? "INVOICE #" : "RECEIPT #",
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    invoiceId,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "DATE",
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Customer Details
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Colors.green.shade50, Colors.teal.shade50],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green.withOpacity(0.2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.person, color: Colors.green.shade700, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  isInvoice ? "BILL TO" : "RECEIVED FROM",
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _customerNameController.text.isEmpty 
                                  ? "Customer Name" 
                                  : _customerNameController.text,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _customerEmailController.text.isEmpty 
                                  ? "customer@email.com" 
                                  : _customerEmailController.text,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            if (_customerAddressController.text.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                _customerAddressController.text,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Items Table
                      const Text(
                        "ITEMS",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12),
                                ),
                              ),
                              child: Row(
                                children: const [
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      "Description",
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      "Qty",
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      "Rate",
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      "Amount",
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ...List.generate(descControllers.length, (index) {
                              if (descControllers[index].text.isEmpty) {
                                return const SizedBox.shrink();
                              }
                              return Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border(
                                    top: BorderSide(color: Colors.grey.shade300),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        descControllers[index].text,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        qtyControllers[index].text,
                                        style: const TextStyle(fontSize: 12),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        "$currencyPrefix${rateControllers[index].text}",
                                        style: const TextStyle(fontSize: 12),
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        "$currencyPrefix${amounts[index].toStringAsFixed(0)}",
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Payment Details
                      if (!isInvoice && _paymentMethodController.text.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Payment Method:",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                _paymentMethodController.text,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      
                      // Totals
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isInvoice ? Colors.blue.shade50 : Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isInvoice 
                                ? Colors.blue.withOpacity(0.3)
                                : Colors.green.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Subtotal:",
                                  style: TextStyle(fontSize: 14)),
                                Text("$currencyPrefix${total.toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  )),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  isInvoice ? "Amount Paid:" : "Amount Received:",
                                  style: const TextStyle(fontSize: 14),
                                ),
                                Text("$currencyPrefix${paid.toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green,
                                  )),
                              ],
                            ),
                            const Divider(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  due > 0 
                                      ? "Balance Due:" 
                                      : (paid > total ? "Change Due:" : "Balance:"),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "$currencyPrefix${due.abs().toStringAsFixed(2)}",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: due > 0 
                                        ? Colors.red 
                                        : (due < 0 ? Colors.orange : Colors.green),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      // Notes
                      if (_notesController.text.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Notes:",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _notesController.text,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                      
                      const SizedBox(height: 30),
                      
                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                side: BorderSide(color: Colors.grey.shade400),
                              ),
                              child: const Text("Edit"),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _saveInvoice();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isInvoice 
                                    ? const Color(0xFF2563EB) 
                                    : Colors.green.shade600,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.check, color: Colors.white, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    isInvoice ? "Save Invoice" : "Save Receipt",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    String currencyPrefix = selectedCurrency.split(' ')[0] == 'UGX' ? 'USh' : '\$';
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isInvoice ? "Create Invoice" : "Create Receipt",
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton.icon(
            onPressed: _showPreview,
            icon: const Icon(Icons.visibility, size: 18),
            label: const Text("Preview"),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF2563EB),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey, fontSize: 14)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderCard(),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
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
                      children: [
                        _toggleButton("Invoice", isInvoice),
                        _toggleButton("Receipt", !isInvoice),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
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
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedCurrency,
                        items: ['UGX (USh)', 'USD (\$)'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value, style: const TextStyle(fontSize: 13)),
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => selectedCurrency = val!),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _inputLabel(isInvoice ? "INVOICE #" : "RECEIPT #"),
              _whiteTextField(
                isInvoice 
                    ? "INV-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}"
                    : "RCP-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}",
                enabled: false,
              ),
              const SizedBox(height: 16),
              _inputLabel("DATE"),
              _whiteTextField("${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}", enabled: false),
              const SizedBox(height: 24),
              Text(
                isInvoice ? "BILL TO" : "RECEIVED FROM",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              _inputLabel("CUSTOMER NAME *"),
              _whiteTextField("Customer Name", controller: _customerNameController),
              const SizedBox(height: 12),
              _inputLabel("CUSTOMER EMAIL *"),
              _whiteTextField("customer@email.com", controller: _customerEmailController),
              const SizedBox(height: 12),
              _inputLabel("CUSTOMER ADDRESS"),
              _whiteTextField("Customer Address", controller: _customerAddressController, maxLines: 2),
              
              if (!isInvoice) ...[
                const SizedBox(height: 12),
                _inputLabel("PAYMENT METHOD *"),
                Container(
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
                  child: DropdownButtonFormField<String>(
                    value: _paymentMethodController.text,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    items: ['Cash', 'Bank Transfer', 'Mobile Money', 'Credit Card', 'Cheque', 'Other']
                        .map((method) => DropdownMenuItem(
                              value: method,
                              child: Text(method, style: const TextStyle(fontSize: 14)),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _paymentMethodController.text = value!;
                      });
                    },
                  ),
                ),
              ],
              
              const SizedBox(height: 24),
              const Text("LINE ITEMS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              Container(
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
                  children: [
                    Row(
                      children: const [
                        Expanded(flex: 3, child: Text("DESCRIPTION", style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold))),
                        Expanded(child: Text("QTY", style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold))),
                        Expanded(child: Text("RATE", style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold))),
                        Expanded(child: Text("AMOUNT", style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold))),
                        SizedBox(width: 30),
                      ],
                    ),
                    const Divider(),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: descControllers.length,
                      itemBuilder: (context, index) {
                        qtyControllers[index].addListener(() => _updateAmount(index));
                        rateControllers[index].addListener(() => _updateAmount(index));
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: TextField(
                                  controller: descControllers[index],
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "Item description",
                                    hintStyle: TextStyle(color: Colors.grey, fontSize: 12),
                                  ),
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                              Expanded(
                                child: TextField(
                                  controller: qtyControllers[index],
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(border: InputBorder.none),
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                              Expanded(
                                child: TextField(
                                  controller: rateControllers[index],
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(border: InputBorder.none),
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  '$currencyPrefix${amounts[index].toStringAsFixed(0)}',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ),
                              IconButton(
                                onPressed: descControllers.length > 1 ? () => _removeLineItem(index) : null,
                                icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 18),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    TextButton.icon(
                      onPressed: _addLineItem,
                      icon: const Icon(Icons.add_circle, color: Color(0xFF2563EB), size: 18),
                      label: const Text("Add Line Item", style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              if (isInvoice) ...[
                _inputLabel("AMOUNT PAID"),
                _coloredTextField(Colors.green.shade50, paidController, currencyPrefix),
              ] else ...[
                _inputLabel("TOTAL AMOUNT RECEIVED *"),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade200, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: paidController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: '$currencyPrefix 0',
                      prefixIcon: Icon(Icons.check_circle, color: Colors.green.shade700),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.green.shade50,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green.shade900),
                  ),
                ),
              ],
              
              const SizedBox(height: 24),
              _inputLabel(isInvoice ? "ADDITIONAL NOTES" : "PAYMENT NOTES"),
              _whiteTextField(
                isInvoice 
                    ? "Bank details, payment terms, etc."
                    : "Thank you for your payment",
                controller: _notesController,
                maxLines: 3,
              ),
              
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isInvoice ? Colors.white : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: isInvoice ? null : Border.all(color: Colors.green.shade200, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    if (isInvoice) ...[
                      _summaryRow("Subtotal", '$currencyPrefix${total.toStringAsFixed(2)}'),
                      const SizedBox(height: 12),
                      _summaryRow("Paid", '$currencyPrefix${paid.toStringAsFixed(2)}', color: Colors.green),
                      const Divider(height: 24),
                      _summaryRow("Balance Due", '$currencyPrefix${due.toStringAsFixed(2)}', isBold: true, fontSize: 18, color: due > 0 ? Colors.red : Colors.green),
                    ] else ...[
                      Row(
                        children: [
                          Icon(Icons.verified, color: Colors.green.shade700, size: 24),
                          const SizedBox(width: 12),
                          const Text(
                            "PAYMENT RECEIVED",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Colors.grey,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _summaryRow("Total Amount", '$currencyPrefix${total.toStringAsFixed(2)}'),
                      const SizedBox(height: 12),
                      _summaryRow("Amount Paid", '$currencyPrefix${paid.toStringAsFixed(2)}', color: Colors.green.shade700, isBold: true, fontSize: 18),
                      if (paid < total) ...[
                        const Divider(height: 24),
                        _summaryRow("Balance Due", '$currencyPrefix${(total - paid).toStringAsFixed(2)}', color: Colors.red, isBold: true),
                      ],
                      if (paid > total) ...[
                        const Divider(height: 24),
                        _summaryRow("Change Due", '$currencyPrefix${(paid - total).toStringAsFixed(2)}', color: Colors.orange, isBold: true),
                      ],
                    ],
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: isLoading ? null : _saveInvoice,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isInvoice ? const Color(0xFF2563EB) : Colors.green.shade600,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isInvoice ? Icons.receipt_long : Icons.check_circle_outline,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            isInvoice ? "Save & Generate Invoice" : "Save & Generate Receipt",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isInvoice 
              ? [Colors.blue.shade50, Colors.purple.shade50]
              : [Colors.green.shade50, Colors.teal.shade50],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isInvoice ? Colors.blue.withOpacity(0.2) : Colors.green.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isInvoice ? Icons.receipt_long : Icons.check_circle,
              color: isInvoice ? const Color(0xFF2563EB) : Colors.green.shade700,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isInvoice
                  ? "Create professional invoices with automatic calculations and save them to your records."
                  : "Generate receipts for completed payments with all transaction details.",
              style: const TextStyle(fontSize: 12, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _toggleButton(String text, bool active) {
    return GestureDetector(
      onTap: () => setState(() => isInvoice = (text == "Invoice")),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF2563EB) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: active ? Colors.white : Colors.grey,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
  
  Widget _inputLabel(String label) => Padding(
    padding: const EdgeInsets.only(bottom: 8, left: 4),
    child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
  );
  
  Widget _whiteTextField(String hint, {TextEditingController? controller, int maxLines = 1, bool enabled = true}) {
    return Container(
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
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        enabled: enabled,
        style: TextStyle(fontSize: 14, color: enabled ? Colors.black : Colors.grey),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
  
  Widget _coloredTextField(Color color, TextEditingController controller, String currencyPrefix) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          hintText: '$currencyPrefix 0',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: color,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
  
  Widget _summaryRow(String label, String value, {bool isBold = false, Color color = Colors.black, double fontSize = 14}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: fontSize)),
        Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.w600, fontSize: fontSize, color: color)),
      ],
    );
  }
  
  void _saveInvoice() async {
    if (_customerNameController.text.isEmpty || _customerEmailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill in customer details"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (total == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please add at least one item"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (!isInvoice && paid == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter the amount received"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() => isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    
    List<InvoiceItem> items = [];
    for (int i = 0; i < descControllers.length; i++) {
      if (descControllers[i].text.isNotEmpty) {
        items.add(InvoiceItem(
          description: descControllers[i].text,
          quantity: double.tryParse(qtyControllers[i].text) ?? 1.0,
          rate: double.tryParse(rateControllers[i].text) ?? 0.0,
        ));
      }
    }
    
    final prefix = isInvoice ? "INV" : "RCP";
    
    String status;
    if (isInvoice) {
      if (paid >= total) {
        status = "Paid";
      } else if (paid > 0) {
        status = "Partial";
      } else {
        status = "Pending";
      }
    } else {
      if (paid >= total) {
        status = "Paid";
      } else if (paid > 0) {
        status = "Partial";
      } else {
        status = "Pending";
      }
    }
    
    final invoice = Invoice(
      id: "$prefix-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}",
      customerName: _customerNameController.text,
      customerEmail: _customerEmailController.text,
      amount: total,
      paid: paid,
      date: DateTime.now(),
      status: status,
      items: items,
    );
    
    BusinessData().addInvoice(invoice);
    setState(() => isLoading = false);
    
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isInvoice 
                      ? "Invoice created successfully!" 
                      : "Receipt generated successfully!",
                ),
              ),
            ],
          ),
          backgroundColor: isInvoice ? Colors.green : Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}