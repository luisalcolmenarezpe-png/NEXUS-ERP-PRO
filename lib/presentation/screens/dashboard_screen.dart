// lib/presentation/screens/dashboard_screen.dart

import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Control ERP'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildKpiCard('Ventas del Día (Bs)', 'Bs. 12,500.00', Icons.point_of_sale, Colors.green),
                _buildKpiCard('Ganancia Neta (USD)', '\$ 450.00', Icons.attach_money, Colors.green),
                _buildKpiCard('Productos en Stock', '1,240', Icons.inventory_2, Colors.blue),
                _buildKpiCard('Alertas Activas', '3', Icons.warning, Colors.amber),
              ],
            ),
            const SizedBox(height: 24),
            Text('Alertas Contables', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildAlertItem('Faltante de Caja detectado en Turno 1 (Bs. 50.00)', true),
                _buildAlertItem('Producto "Harina Pan" bajo stock mínimo', false),
                _buildAlertItem('Margen SUNDDE excedido en "Queso Amarillo"', false),
              ],
            ),
            const SizedBox(height: 24),
            Text('Resumen Semanal', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Día')),
                  DataColumn(label: Text('Ventas')),
                  DataColumn(label: Text('Gastos')),
                  DataColumn(label: Text('Ganancia')),
                ],
                rows: const [
                  DataRow(cells: [
                    DataCell(Text('Lunes')),
                    DataCell(Text('\$ 500')),
                    DataCell(Text('\$ 100')),
                    DataCell(Text('\$ 400')),
                  ]),
                  DataRow(cells: [
                    DataCell(Text('Martes')),
                    DataCell(Text('\$ 600')),
                    DataCell(Text('\$ 120')),
                    DataCell(Text('\$ 480')),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 18, color: color, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertItem(String message, bool isCritical) {
    return Card(
      color: isCritical ? Colors.red.shade100 : Colors.amber.shade100,
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        leading: Icon(Icons.warning_amber_rounded, color: isCritical ? Colors.red : Colors.amber.shade800),
        title: Text(message, style: TextStyle(color: isCritical ? Colors.red.shade900 : Colors.amber.shade900)),
      ),
    );
  }
}
