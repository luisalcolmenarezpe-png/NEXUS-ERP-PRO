/// features/admin/presentation/admin_dashboard_screen.dart
/// Panel de administración web para visualizar métricas globales, inventario y mermas en tiempo real
import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel Gerencial - ERP Cloud'),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumen General del Negocio',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _buildMetricCard(
                  title: 'Ventas Totales Hoy',
                  value: '\$1,420.00',
                  icon: Icons.attach_money,
                  color: Colors.green,
                ),
                const SizedBox(width: 16),
                _buildMetricCard(
                  title: 'Mermas / Desperdicios',
                  value: '14.5 Kg',
                  icon: Icons.warning_amber_rounded,
                  color: Colors.orange,
                ),
                const SizedBox(width: 16),
                _buildMetricCard(
                  title: 'Margen Promedio',
                  value: '28.5%',
                  icon: Icons.trending_up,
                  color: Colors.blue,
                ),
              ],
            ),
            const SizedBox(height: 30),
            const Text(
              'Últimas Transacciones Sincronizadas',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListView.builder(
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.receipt_long),
                      ),
                      title: Text('Transacción #100${index + 1} - Registro de Entrada'),
                      subtitle: Text('Sincronizado vía móvil • Hace ${index + 5} minutos'),
                      trailing: const Text(
                        '\$120.00',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          border: Border.all(color: color.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(title, style: TextStyle(color: Colors.grey.shade700, fontSize: 14)),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}
