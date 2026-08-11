// lib/features/pos/presentation/digital_receipt_engine.dart

class DigitalReceiptEngine {
  /// Genera un formato de texto plano formateado para envío por WhatsApp/Telegram
  String generateMessagingReceipt({
    required String storeName,
    required String invoiceNumber,
    required String customerName,
    required List<Map<String, dynamic>> items,
    required double subtotal,
    required double taxAmount,
    required double total,
    required String currencySymbol,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('🧾 *COMPROBANTE DIGITAL DE COMPRA*');
    buffer.writeln('*$storeName*');
    buffer.writeln('Factura N°: #$invoiceNumber');
    buffer.writeln('Cliente: $customerName');
    buffer.writeln('--------------------------------');

    for (var item in items) {
      final qty = item['qty'] ?? 1;
      final name = item['name'] ?? 'Producto';
      final price = (item['price'] as num?)?.toDouble() ?? 0.0;
      buffer.writeln('$qty x $name - $currencySymbol ${price.toStringAsFixed(2)}');
    }

    buffer.writeln('--------------------------------');
    buffer.writeln('Subtotal: $currencySymbol ${subtotal.toStringAsFixed(2)}');
    buffer.writeln('IVA / Impuestos: $currencySymbol ${taxAmount.toStringAsFixed(2)}');
    buffer.writeln('*TOTAL A PAGAR: $currencySymbol ${total.toStringAsFixed(2)}*');
    buffer.writeln('--------------------------------');
    buffer.writeln('¡Gracias por su compra!');

    return buffer.toString();
  }

  /// Construye la cadena de texto estructurada para el código QR fiscal
  String generateQrPayload({
    required String companyRif,
    required String invoiceNumber,
    required double totalAmount,
    required String timestamp,
    required String digitalSignatureHash,
  }) {
    final shortHash = digitalSignatureHash.length >= 8 
        ? digitalSignatureHash.substring(0, 8) 
        : digitalSignatureHash;

    return 'RIF:$companyRif|FAC:$invoiceNumber|TOT:${totalAmount.toStringAsFixed(2)}|FECHA:$timestamp|HASH:$shortHash';
  }
}
