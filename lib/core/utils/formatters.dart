class AppFormatters {
  /// Redondea a 2 decimales y devuelve formato Dólar (USD)
  static String formatUSD(double amount) {
    return '\$ ${amount.toStringAsFixed(2)}';
  }

  /// Redondea a 2 decimales y devuelve formato Bolívar (VES)
  /// Utiliza la coma ',' como separador decimal para adaptarse al estándar venezolano.
  static String formatVES(double amount) {
    String fixedAmount = amount.toStringAsFixed(2);
    // Reemplaza el punto decimal por una coma
    fixedAmount = fixedAmount.replaceAll('.', ',');
    return 'Bs. $fixedAmount';
  }

  /// Formatea un objeto DateTime a DD/MM/AAAA
  static String formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }

  /// Formatea un objeto DateTime a HH:MM (formato 24h)
  static String formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Combina formato de Fecha y Hora (DD/MM/AAAA - HH:MM)
  /// Ideal para facturas del POS o bitácoras de auditoría (Gobernanza)
  static String formatDateTime(DateTime date) {
    return '${formatDate(date)} ${formatTime(date)}';
  }

  /// Utilidad que lee un string ISO8601 (como se guardan en SQLite),
  /// lo convierte a la zona horaria local y devuelve el formato legible.
  static String formatDbDate(String isoString) {
    try {
      final date = DateTime.parse(isoString).toLocal();
      return formatDateTime(date);
    } catch (e) {
      // Fallback seguro por si la cadena está malformada
      return isoString;
    }
  }
}
