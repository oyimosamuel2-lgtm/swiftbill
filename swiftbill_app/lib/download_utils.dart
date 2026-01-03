import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:swiftbill_app/business_data.dart';
import 'package:share_plus/share_plus.dart'; // Add this to pubspec.yaml

class DownloadUtils {
  
  // Request storage permission - simplified and more reliable
  static Future<bool> requestStoragePermission(BuildContext context) async {
    if (Platform.isAndroid) {
      try {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        final sdkInt = androidInfo.version.sdkInt;
        
        print('Android SDK: $sdkInt');
        
        if (sdkInt >= 33) {
          // Android 13+ (API 33+) - No storage permission needed for app-specific files
          print('Android 13+: No permission needed for app files');
          return true;
        } else if (sdkInt >= 30) {
          // Android 11-12 (API 30-32) - request manage external storage
          if (await Permission.manageExternalStorage.isGranted) {
            return true;
          }
          
          final status = await Permission.manageExternalStorage.request();
          
          if (status.isDenied || status.isPermanentlyDenied) {
            if (context.mounted) {
              _showPermissionDialog(context);
            }
            return false;
          }
          
          return status.isGranted;
        } else {
          // Android 10 and below
          if (await Permission.storage.isGranted) {
            return true;
          }
          
          final status = await Permission.storage.request();
          return status.isGranted;
        }
      } catch (e) {
        print('Error requesting permission: $e');
        return false;
      }
    }
    return true;
  }
  
  // Get download directory with multiple fallbacks
  static Future<String> getDownloadPath() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        final sdkInt = androidInfo.version.sdkInt;
        
        if (sdkInt >= 29) {
          // Android 10+ (API 29+): Use app-specific directory (no permission needed)
          final directory = await getExternalStorageDirectory();
          if (directory != null) {
            // Create Downloads folder in app directory
            final downloadDir = Directory('${directory.path}/Downloads');
            if (!await downloadDir.exists()) {
              await downloadDir.create(recursive: true);
            }
            print('Using app-specific directory: ${downloadDir.path}');
            return downloadDir.path;
          }
        }
        
        // Fallback: Try public Download directory (requires permission)
        final possiblePaths = [
          '/storage/emulated/0/Download',
          '/storage/emulated/0/Downloads',
          '/sdcard/Download',
          '/sdcard/Downloads',
        ];
        
        for (var path in possiblePaths) {
          final dir = Directory(path);
          if (await dir.exists()) {
            print('Using download path: $path');
            return path;
          }
        }
        
        // If none exist, try to create the standard one
        final standardPath = '/storage/emulated/0/Download';
        final dir = Directory(standardPath);
        await dir.create(recursive: true);
        print('Created download path: $standardPath');
        return standardPath;
      }
    } catch (e) {
      print('Error getting download path: $e');
    }
    
    // Final fallback to app directory
    final appDir = await getApplicationDocumentsDirectory();
    print('Using app directory: ${appDir.path}');
    return appDir.path;
  }
  
  // Export invoice as PDF
  static Future<String?> exportInvoiceToPDF(Invoice invoice, BuildContext context) async {
    try {
      print('Starting PDF export for ${invoice.id}');
      
      // Request permission
      bool hasPermission = await requestStoragePermission(context);
      if (!hasPermission) {
        print('Permission denied');
        return null;
      }
      
      print('Permission granted');
      
      final pdf = pw.Document();
      
      // Get business data
      final businessName = BusinessData().name.value;
      final businessEmail = BusinessData().email.value;
      final businessAddress = BusinessData().address.value;
      
      // Create PDF content
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          businessName,
                          style: pw.TextStyle(
                            fontSize: 24,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 5),
                        pw.Text(businessEmail, style: const pw.TextStyle(fontSize: 12)),
                        pw.Text(businessAddress, style: const pw.TextStyle(fontSize: 12)),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          invoice.id.contains('INV') ? 'INVOICE' : 'RECEIPT',
                          style: pw.TextStyle(
                            fontSize: 28,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blue700,
                          ),
                        ),
                        pw.SizedBox(height: 5),
                        pw.Text(invoice.id, style: const pw.TextStyle(fontSize: 14)),
                        pw.Text(
                          'Date: ${invoice.date.day}/${invoice.date.month}/${invoice.date.year}',
                          style: const pw.TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 30),
                
                // Customer Info
                pw.Container(
                  padding: const pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey200,
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Bill To:',
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text(invoice.customerName, style: const pw.TextStyle(fontSize: 14)),
                      pw.Text(invoice.customerEmail, style: const pw.TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
                pw.SizedBox(height: 30),
                
                // Items Table
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey400),
                  children: [
                    // Header
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: PdfColors.blue700),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Description',
                              style: pw.TextStyle(
                                color: PdfColors.white,
                                fontWeight: pw.FontWeight.bold,
                              )),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Qty',
                              style: pw.TextStyle(
                                color: PdfColors.white,
                                fontWeight: pw.FontWeight.bold,
                              )),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Rate',
                              style: pw.TextStyle(
                                color: PdfColors.white,
                                fontWeight: pw.FontWeight.bold,
                              )),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Amount',
                              style: pw.TextStyle(
                                color: PdfColors.white,
                                fontWeight: pw.FontWeight.bold,
                              )),
                        ),
                      ],
                    ),
                    // Items
                    ...invoice.items.map((item) {
                      return pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(item.description),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(item.quantity.toStringAsFixed(0)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text('UGX ${item.rate.toStringAsFixed(0)}'),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text('UGX ${item.amount.toStringAsFixed(0)}'),
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                ),
                pw.SizedBox(height: 20),
                
                // Totals
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Container(
                    width: 250,
                    padding: const pw.EdgeInsets.all(15),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey400),
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
                    ),
                    child: pw.Column(
                      children: [
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('Subtotal:'),
                            pw.Text('UGX ${invoice.amount.toStringAsFixed(2)}'),
                          ],
                        ),
                        pw.SizedBox(height: 5),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('Paid:'),
                            pw.Text('UGX ${invoice.paid.toStringAsFixed(2)}',
                                style: const pw.TextStyle(color: PdfColors.green)),
                          ],
                        ),
                        pw.Divider(),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('Balance Due:',
                                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                            pw.Text('UGX ${invoice.balance.toStringAsFixed(2)}',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  color: invoice.balance > 0 ? PdfColors.red : PdfColors.green,
                                )),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                pw.Spacer(),
                
                // Footer
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: const pw.BoxDecoration(
                    color: PdfColors.grey200,
                    borderRadius: pw.BorderRadius.all(pw.Radius.circular(5)),
                  ),
                  child: pw.Center(
                    child: pw.Text(
                      'Generated by SwiftBill - ${DateTime.now().toString().split('.')[0]}',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );
      
      // Get download path
      final downloadPath = await getDownloadPath();
      final fileName = '${invoice.id}.pdf';
      final filePath = '$downloadPath/$fileName';
      
      print('Saving PDF to: $filePath');
      
      // Save file
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());
      
      print('PDF saved successfully: $filePath');
      print('File exists: ${await file.exists()}');
      print('File size: ${await file.length()} bytes');
      
      return filePath;
    } catch (e, stackTrace) {
      print('Error exporting PDF: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }
  
  // Export analytics report as Excel
  static Future<String?> exportAnalyticsToExcel(BuildContext context) async {
    try {
      print('Starting Excel export');
      
      bool hasPermission = await requestStoragePermission(context);
      if (!hasPermission) {
        print('Permission denied');
        return null;
      }
      
      print('Permission granted');
      
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Analytics Report'];
      
      // Add headers
      sheetObject.appendRow([
        TextCellValue('Invoice ID'),
        TextCellValue('Customer'),
        TextCellValue('Amount'),
        TextCellValue('Paid'),
        TextCellValue('Balance'),
        TextCellValue('Status'),
        TextCellValue('Date'),
      ]);
      
      // Add data
      for (var invoice in BusinessData().invoices.value) {
        sheetObject.appendRow([
          TextCellValue(invoice.id),
          TextCellValue(invoice.customerName),
          DoubleCellValue(invoice.amount),
          DoubleCellValue(invoice.paid),
          DoubleCellValue(invoice.balance),
          TextCellValue(invoice.status),
          TextCellValue(invoice.date.toString().split(' ')[0]),
        ]);
      }
      
      // Get download path
      final downloadPath = await getDownloadPath();
      final fileName = 'SwiftBill_Analytics_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      final filePath = '$downloadPath/$fileName';
      
      print('Saving Excel to: $filePath');
      
      // Save file
      var fileBytes = excel.save();
      if (fileBytes != null) {
        final file = File(filePath);
        await file.writeAsBytes(fileBytes);
        
        print('Excel saved successfully: $filePath');
        print('File exists: ${await file.exists()}');
        print('File size: ${await file.length()} bytes');
        
        return filePath;
      }
      
      return null;
    } catch (e, stackTrace) {
      print('Error exporting Excel: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }
  
  // FIXED: Share file using share_plus
  static Future<void> shareFile(String filePath, BuildContext context) async {
    try {
      final file = File(filePath);
      
      if (!await file.exists()) {
        print('File does not exist: $filePath');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('File not found. Please download it first.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
      
      print('Sharing file: $filePath');
      
      // Share the file using share_plus
      final result = await Share.shareXFiles(
        [XFile(filePath)],
        text: 'SwiftBill Document',
        subject: 'Document from SwiftBill',
      );
      
      print('Share result: ${result.status}');
      
      if (result.status == ShareResultStatus.success) {
        print('File shared successfully');
      } else if (result.status == ShareResultStatus.dismissed) {
        print('Share dismissed by user');
      }
    } catch (e, stackTrace) {
      print('Error sharing file: $e');
      print('Stack trace: $stackTrace');
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  // Show permission dialog
  static void _showPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Storage Permission Required"),
        content: const Text(
          "SwiftBill needs storage permission to save files.\n\n"
          "Please go to Settings > Apps > SwiftBill > Permissions and enable 'Files and media' or 'Storage'.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
            ),
            child: const Text("Open Settings"),
          ),
        ],
      ),
    );
  }
  
  // Show success message with file location and share option
  static void showDownloadSuccess(BuildContext context, String filePath) {
    if (!context.mounted) return;
    
    // Extract just the filename
    final fileName = filePath.split('/').last;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "File downloaded successfully!",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "📄 $fileName",
              style: const TextStyle(fontSize: 12, color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text(
              "📁 ${filePath.split('/').sublist(0, filePath.split('/').length - 1).join('/')}",
              style: const TextStyle(fontSize: 10, color: Colors.white70),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 6),
        action: SnackBarAction(
          label: "SHARE",
          textColor: Colors.white,
          onPressed: () {
            shareFile(filePath, context);
          },
        ),
      ),
    );
  }
}