import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../domain/entities/invoice_entity.dart';
import 'package:intl/intl.dart';

class InvoicePDFService {
  static Future<void> generateAndPrint(InvoiceEntity invoice) async {
    final pdf = pw.Document();

    pw.MemoryImage? logoImage;
    try {
      final logoData = await rootBundle.load('assets/sheba_erp.png');
      logoImage = pw.MemoryImage(logoData.buffer.asUint8List());
    } catch (e) {
      // Ignore if logo fails to load
    }

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
                      if (logoImage != null)
                        pw.Image(logoImage, width: 60, height: 60),
                      pw.Text(
                        "AmarPay Billing",
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text("Your Trusted Payment Gateway"),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        "INVOICE",
                        style: pw.TextStyle(
                          fontSize: 30,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue,
                        ),
                      ),
                      pw.Text("#${invoice.invoiceNumber}"),
                      pw.Text(
                        "Date: ${DateFormat('MMM dd, yyyy').format(invoice.createdAt)}",
                      ),
                      pw.Text(
                        "Due: ${DateFormat('MMM dd, yyyy').format(invoice.dueDate)}",
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 40),

              // Customer Info
              pw.Row(
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        "Bill To:",
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text(invoice.customerName ?? "Valued Customer"),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),

              // Items Table
              pw.TableHelper.fromTextArray(
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.blue),
                cellAlignment: pw.Alignment.centerLeft,
                headers: ['Description', 'Qty', 'Unit Price', 'Total'],
                data: invoice.items.map((item) {
                  return [
                    item.description,
                    item.quantity.toString(),
                    "৳${item.unitPrice}",
                    "৳${item.total}",
                  ];
                }).toList(),
              ),
              pw.SizedBox(height: 30),

              // Totals
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text("Shipping: ৳${invoice.shippingCharge}"),
                      pw.Divider(color: PdfColors.grey),
                      pw.Text(
                        "Grand Total: ৳${invoice.totalAmount}",
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 50),
              pw.Center(
                child: pw.Text(
                  "Thank you for choosing AmarPay!",
                  style: pw.TextStyle(color: PdfColors.grey),
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
}
