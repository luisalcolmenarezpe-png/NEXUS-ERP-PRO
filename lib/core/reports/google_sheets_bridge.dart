// lib/core/reports/google_sheets_bridge.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'universal_report_engine.dart';

class GoogleSheetsBridge {
  /// Envía los datos tabulares del reporte directamente a Google Sheets via App Script / API
  static Future<bool> sendReportToGoogleSheets({
    required String googleScriptWebhookUrl,
    required ReportSheetData reportData,
    required String companyName,
  }) async {
    try {
      final List<String> headers = reportData.columns.map((c) => c.title).toList();
      final List<List<dynamic>> rowsPayload = [];

      for (var row in reportData.rows) {
        final List<dynamic> rowValues = reportData.columns.map((col) => row[col.key] ?? '').toList();
        rowsPayload.add(rowValues);
      }

      // Fila de Totales al final
      if (reportData.totalsRow != null) {
        final List<dynamic> totalValues = reportData.columns.map((col) => reportData.totalsRow![col.key] ?? '').toList();
        rowsPayload.add(totalValues);
      }

      final payload = {
        'company': companyName,
        'sheet_name': reportData.sheetName,
        'headers': headers,
        'rows': rowsPayload,
        'timestamp': DateTime.now().toIso8601String(),
      };

      final response = await http.post(
        Uri.parse(googleScriptWebhookUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}
