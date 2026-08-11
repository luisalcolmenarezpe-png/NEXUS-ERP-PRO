// lib/presentation/screens/financial_closure_screen.dart

import 'package:flutter/material.dart';

class FinancialClosureScreen extends StatefulWidget {
  const FinancialClosureScreen({Key? key}) : super(key: key);

  @override
  State<FinancialClosureScreen> createState() => _FinancialClosureScreenState();
}

class _FinancialClosureScreenState extends State<FinancialClosureScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cierre de Caja y Cuadre Financiero'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Cajero: Juan Pérez', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('Hora Apertura: 08:00 AM'),
                    Text('Saldo Inicial: Bs. 1,000.00 | \$ 100.00'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Desglose de Pagos', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Método')),
                  DataColumn(label: Text('Moneda')),
                  DataColumn(label: Text('Monto')),
                  DataColumn(label: Text('Tasa')),
                  DataColumn(label: Text('Equiv. Bs')),
                ],
                rows: const [
                  DataRow(cells: [
                    DataCell(Text('Efectivo')),
                    DataCell(Text('USD')),
                    DataCell(Text('\$ 50.00')),
                    DataCell(Text('36.00')),
                    DataCell(Text('Bs. 1,800.00')),
                  ]),
                  DataRow(cells: [
                    DataCell(Text('Pago Móvil')),
                    DataCell(Text('VES')),
                    DataCell(Text('Bs. 2,000.00')),
                    DataCell(Text('1.00')),
                    DataCell(Text('Bs. 2,000.00')),
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Cuadre de Caja', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _buildTextField('Efec. Esperado Bs', '3800.00')),
                const SizedBox(width: 16),
                Expanded(child: _buildTextField('Efec. Contado Bs', '3800.00')),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildTextField('Efec. Esperado \$', '150.00')),
                const SizedBox(width: 16),
                Expanded(child: _buildTextField('Efec. Contado \$', '140.00')),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Diferencia \$: FALTANTE \$10.00', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 24),
            Text('Impuestos y Retenciones', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text('Retención 0.76%: Bs. 28.88'),
            const Text('Aporte Salud 1.00%: Bs. 38.00'),
            const Text('Neto después de deducciones: Bs. 3733.12', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                padding: const EdgeInsets.symmetric(vertical: 20),
              ),
              onPressed: () {},
              child: const Text('CERRAR CAJA', style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {},
              child: const Text('Generar Reporte'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String initialValue) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
    );
  }
}
