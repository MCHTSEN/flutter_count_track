import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PackingListService {
  Future<Uint8List> generatePackingListPdf(
    String orderCode,
    String customerName,
    List<Map<String, dynamic>> boxContents,
  ) async {
    final pdf = pw.Document();
    final DateFormat formatter = DateFormat('dd.MM.yyyy HH:mm');
    final String generatedDate = formatter.format(DateTime.now());

    final totalBoxes = boxContents.length;
    final totalItems = boxContents.fold<int>(
        0,
        (sum, box) =>
            sum +
            (box['contents'] as List<dynamic>).fold<int>(
                0, (itemSum, item) => itemSum + (item['quantity'] as int)));

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        header: (pw.Context context) {
          return _buildHeader(orderCode, customerName, generatedDate);
        },
        footer: (pw.Context context) {
          return _buildFooter(context);
        },
        build: (pw.Context context) {
          return [
            _buildSummary(totalBoxes, totalItems),
            pw.SizedBox(height: 20),
            ..._buildBoxTables(boxContents),
          ];
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildHeader(
      String orderCode, String customerName, String generatedDate) {
    return pw.Container(
      alignment: pw.Alignment.centerLeft,
      margin: const pw.EdgeInsets.only(bottom: 20.0),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('ÇEKİ LİSTESİ',
              style:
                  pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Sipariş Kodu: $orderCode'),
                  pw.Text('Müşteri: $customerName'),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('Oluşturma Tarihi:'),
                  pw.Text(generatedDate),
                ],
              ),
            ],
          ),
          pw.Divider(thickness: 2),
        ],
      ),
    );
  }

  pw.Widget _buildSummary(int totalBoxes, int totalItems) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          pw.Column(children: [
            pw.Text('Toplam Koli',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text('$totalBoxes'),
          ]),
          pw.Column(children: [
            pw.Text('Toplam Ürün Adedi',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text('$totalItems'),
          ]),
        ],
      ),
    );
  }

  List<pw.Widget> _buildBoxTables(List<Map<String, dynamic>> boxContents) {
    final List<pw.Widget> tables = [];
    for (final boxData in boxContents) {
      final boxNumber = boxData['boxNumber'] as int;
      final contents = boxData['contents'] as List<dynamic>;

      tables.add(
        pw.Container(
          margin: const pw.EdgeInsets.only(top: 20),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Koli #$boxNumber',
                  style: pw.TextStyle(
                      fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 5),
              pw.Table.fromTextArray(
                border: pw.TableBorder.all(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headerDecoration:
                    const pw.BoxDecoration(color: PdfColors.grey300),
                cellAlignment: pw.Alignment.centerLeft,
                cellPadding: const pw.EdgeInsets.all(5),
                headers: ['Ürün Kodu', 'Ürün Adı', 'Barkod', 'Miktar'],
                data: contents
                    .map((item) => [
                          item['productCode'] ?? '',
                          item['productName'] ?? '',
                          item['barcode'] ?? '',
                          item['quantity']?.toString() ?? '0',
                        ])
                    .toList(),
              ),
            ],
          ),
        ),
      );
    }
    return tables;
  }

  pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 20.0),
      child: pw.Text(
        'Sayfa ${context.pageNumber} / ${context.pagesCount}',
        style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey),
      ),
    );
  }
}
