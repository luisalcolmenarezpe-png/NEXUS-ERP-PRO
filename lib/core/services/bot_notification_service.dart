/// core/services/bot_notification_service.dart
/// Servicio para el envío de alertas de seguridad y reportes diarios a Telegram / WhatsApp Bot API
import 'dart:convert';
import 'package:http/http.dart' as http;

class BotNotificationService {
  final String telegramBotToken;
  final String telegramChatId;

  BotNotificationService({
    required this.telegramBotToken,
    required this.telegramChatId,
  });

  /// Envía una alerta crítica de Auditoría Fantasma en tiempo real al teléfono del dueño
  Future<bool> sendSecurityAlert({
    required String cashierName,
    required String actionType,
    required String details,
  }) async {
    final alertMessage = '''
🚨 *ALERTA DE SEGURIDAD - AUDITORÍA FANTASMA*
📅 *Hora:* ${DateTime.now().toIso8601String().substring(11, 19)}
👤 *Cajero:* $cashierName
⚠️ *Acción:* $actionType
📝 *Detalles:* $details
''';

    return await _sendTelegramMessage(alertMessage);
  }

  /// Envía el resumen ejecutivo al cierre del día
  Future<bool> sendDailySummary(String formattedSummary) async {
    return await _sendTelegramMessage(formattedSummary);
  }

  /// Método privado para ejecutar la llamada a la API de Telegram Bot
  Future<bool> _sendTelegramMessage(String message) async {
    try {
      final url = Uri.parse('https://api.telegram.org/bot$telegramBotToken/sendMessage');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'chat_id': telegramChatId,
          'text': message,
          'parse_mode': 'Markdown',
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      // Manejo transparente en caso de fallo de red
      return false;
    }
  }
}
