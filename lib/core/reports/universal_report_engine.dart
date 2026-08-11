// lib/core/reports/universal_report_engine.dart

import 'dart:convert';

/// Estructura de una Hoja de Cálculo (Tab/Pestaña independiente)
class SheetColumn {
  final String title;
  final String key;
  final bool isNumeric;
  final bool isCurrency;

  SheetColumn({
    required this.title,
    required this.key,
    this.isNumeric = false,
    this.isCurrency = false,
  });
}

class ReportSheetData {
  final String sheetName;
  final List<SheetColumn> columns;
  final List<Map<String, dynamic>> rows;
  final Map<String, dynamic>? totalsRow;

  ReportSheetData({
    required this.sheetName,
    required this.columns,
    required this.rows,
    this.totalsRow,
  });
}

class UniversalReportEngine {
  // ═══════════════════════════════════════════════════════════════════
  // 1. LIBRO FISCAL DE VENTAS (SENIAT)
  // ═══════════════════════════════════════════════════════════════════
  static ReportSheetData buildSalesBookSheet(List<Map<String, dynamic>> salesData) {
    double totalExempt = 0, totalBase = 0, totalTax = 0, totalIgtf = 0, totalAmount = 0;

    for (var row in salesData) {
      totalExempt += (row['exempt'] as num?)?.toDouble() ?? 0.0;
      totalBase += (row['base'] as num?)?.toDouble() ?? 0.0;
      totalTax += (row['tax'] as num?)?.toDouble() ?? 0.0;
      totalIgtf += (row['igtf'] as num?)?.toDouble() ?? 0.0;
      totalAmount += (row['total'] as num?)?.toDouble() ?? 0.0;
    }

    return ReportSheetData(
      sheetName: 'Libro de Ventas SENIAT',
      columns: [
        SheetColumn(title: 'Nº Op', key: 'op_num'),
        SheetColumn(title: 'Fecha', key: 'date'),
        SheetColumn(title: 'RIF / C.I.', key: 'tax_id'),
        SheetColumn(title: 'Cliente / Razón Social', key: 'customer'),
        SheetColumn(title: 'Nº Factura', key: 'invoice_num'),
        SheetColumn(title: 'Nº Control', key: 'control_num'),
        SheetColumn(title: 'Monto Exento (Bs)', key: 'exempt', isNumeric: true, isCurrency: true),
        SheetColumn(title: 'Base Imponible (Bs)', key: 'base', isNumeric: true, isCurrency: true),
        SheetColumn(title: 'IVA 16% (Bs)', key: 'tax', isNumeric: true, isCurrency: true),
        SheetColumn(title: 'IGTF 3% (Bs)', key: 'igtf', isNumeric: true, isCurrency: true),
        SheetColumn(title: 'Total Facturado (Bs)', key: 'total', isNumeric: true, isCurrency: true),
      ],
      rows: salesData,
      totalsRow: {
        'op_num': 'TOTALES',
        'exempt': totalExempt,
        'base': totalBase,
        'tax': totalTax,
        'igtf': totalIgtf,
        'total': totalAmount,
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // 2. LIBRO FISCAL DE COMPRAS (SENIAT)
  // ═══════════════════════════════════════════════════════════════════
  static ReportSheetData buildPurchaseBookSheet(List<Map<String, dynamic>> purchaseData) {
    double totalExempt = 0, totalBase = 0, totalTax = 0, totalWithheld = 0, totalAmount = 0;

    for (var row in purchaseData) {
      totalExempt += (row['exempt'] as num?)?.toDouble() ?? 0.0;
      totalBase += (row['base'] as num?)?.toDouble() ?? 0.0;
      totalTax += (row['tax'] as num?)?.toDouble() ?? 0.0;
      totalWithheld += (row['iva_withheld'] as num?)?.toDouble() ?? 0.0;
      totalAmount += (row['total'] as num?)?.toDouble() ?? 0.0;
    }

    return ReportSheetData(
      sheetName: 'Libro de Compras SENIAT',
      columns: [
        SheetColumn(title: 'Nº Op', key: 'op_num'),
        SheetColumn(title: 'Fecha', key: 'date'),
        SheetColumn(title: 'RIF Proveedor', key: 'supplier_rif'),
        SheetColumn(title: 'Proveedor / Razón Social', key: 'supplier_name'),
        SheetColumn(title: 'Nº Factura Proveedor', key: 'supplier_invoice'),
        SheetColumn(title: 'Nº Control', key: 'control_num'),
        SheetColumn(title: 'Monto Exento (Bs)', key: 'exempt', isNumeric: true, isCurrency: true),
        SheetColumn(title: 'Base Imponible (Bs)', key: 'base', isNumeric: true, isCurrency: true),
        SheetColumn(title: 'IVA 16% Crédito Fiscal (Bs)', key: 'tax', isNumeric: true, isCurrency: true),
        SheetColumn(title: 'IVA Retenido 75% (Bs)', key: 'iva_withheld', isNumeric: true, isCurrency: true),
        SheetColumn(title: 'Total Compra (Bs)', key: 'total', isNumeric: true, isCurrency: true),
      ],
      rows: purchaseData,
      totalsRow: {
        'op_num': 'TOTALES',
        'exempt': totalExempt,
        'base': totalBase,
        'tax': totalTax,
        'iva_withheld': totalWithheld,
        'total': totalAmount,
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // 3. CONTROL DE INVENTARIO KARDEX (Inicial, Entradas, Salidas, Final)
  // ═══════════════════════════════════════════════════════════════════
  static ReportSheetData buildInventoryKardexSheet(List<Map<String, dynamic>> inventoryData) {
    double totalValueUsd = 0;

    for (var item in inventoryData) {
      final finalStock = ((item['initial_stock'] as num?)?.toDouble() ?? 0)
          + ((item['entries'] as num?)?.toDouble() ?? 0)
          - ((item['exits'] as num?)?.toDouble() ?? 0);
      item['final_stock'] = finalStock;

      final totalItemVal = finalStock * ((item['cost_usd'] as num?)?.toDouble() ?? 0);
      item['total_valuation_usd'] = totalItemVal;
      totalValueUsd += totalItemVal;
    }

    return ReportSheetData(
      sheetName: 'Kardex e Inventario Final',
      columns: [
        SheetColumn(title: 'Código / SKU', key: 'sku'),
        SheetColumn(title: 'Producto / Descripción', key: 'description'),
        SheetColumn(title: 'Ubicación Almacén', key: 'location'),
        SheetColumn(title: 'Inv. Inicial', key: 'initial_stock', isNumeric: true),
        SheetColumn(title: 'Entradas (Compras)', key: 'entries', isNumeric: true),
        SheetColumn(title: 'Salidas (Ventas)', key: 'exits', isNumeric: true),
        SheetColumn(title: 'INVENTARIO FINAL', key: 'final_stock', isNumeric: true),
        SheetColumn(title: 'Costo Unit. (\$)', key: 'cost_usd', isNumeric: true, isCurrency: true),
        SheetColumn(title: 'Precio Venta (\$)', key: 'price_usd', isNumeric: true, isCurrency: true),
        SheetColumn(title: 'Valoración Total (\$)', key: 'total_valuation_usd', isNumeric: true, isCurrency: true),
      ],
      rows: inventoryData,
      totalsRow: {
        'sku': 'RESUMEN VALORIZADO',
        'total_valuation_usd': totalValueUsd,
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // EXPORTACIÓN CSV (UTF-8 BOM para compatibilidad con Excel latino)
  // ═══════════════════════════════════════════════════════════════════

  /// Genera archivo CSV con codificación UTF-8 BOM compatible con Excel y caracteres latinos
  static String exportToCsv(ReportSheetData sheet) {
    final buffer = StringBuffer();

    // BOM (Byte Order Mark) para que Excel reconozca UTF-8 con acentos/ñ
    buffer.write('\uFEFF');

    // Encabezados
    buffer.writeln(sheet.columns.map((c) => '"${c.title}"').join(','));

    // Filas de datos
    for (var row in sheet.rows) {
      final line = sheet.columns.map((col) {
        final val = row[col.key] ?? '';
        if (col.isCurrency && val is num) {
          return '"${val.toStringAsFixed(2)}"';
        }
        return '"$val"';
      }).join(',');
      buffer.writeln(line);
    }

    // Fila de Totales
    if (sheet.totalsRow != null) {
      final line = sheet.columns.map((col) {
        final val = sheet.totalsRow![col.key] ?? '';
        if (col.isCurrency && val is num) {
          return '"${val.toStringAsFixed(2)}"';
        }
        return '"$val"';
      }).join(',');
      buffer.writeln(line);
    }

    return buffer.toString();
  }

  /// Genera bytes UTF-8 con BOM listos para escribir a disco
  static List<int> exportToCsvBytes(ReportSheetData sheet) {
    return utf8.encode(exportToCsv(sheet));
  }
}
