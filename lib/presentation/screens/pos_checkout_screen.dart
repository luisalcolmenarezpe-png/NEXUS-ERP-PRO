// lib/presentation/screens/pos_checkout_screen.dart

import 'package:flutter/material.dart';

class PosCheckoutScreen extends StatefulWidget {
  const PosCheckoutScreen({Key? key}) : super(key: key);

  @override
  State<PosCheckoutScreen> createState() => _PosCheckoutScreenState();
}

class _PosCheckoutScreenState extends State<PosCheckoutScreen> {
  bool _applyIgtf = false;
  String _ivaRate = 'General 16%';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terminal Punto de Venta'),
      ),
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Escanear Código de Barras o SKU...',
                      prefixIcon: const Icon(Icons.qr_code_scanner),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: 3,
                      itemBuilder: (context, index) {
                        return Card(
                          child: ListTile(
                            title: Text('Producto de Prueba ${index + 1}'),
                            subtitle: Text('Precio unitario: \$10.00'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(icon: const Icon(Icons.remove), onPressed: () {}),
                                const Text('1'),
                                IconButton(icon: const Icon(Icons.add), onPressed: () {}),
                                IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () {}),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'RIF / C.I. Cliente',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _ivaRate,
                    items: ['General 16%', 'Reducido 8%', 'Exento'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (v) => setState(() => _ivaRate = v!),
                    decoration: const InputDecoration(labelText: 'Tasa IVA'),
                  ),
                  CheckboxListTile(
                    title: const Text('Pago en Divisas (Aplica IGTF 3%)'),
                    value: _applyIgtf,
                    onChanged: (v) => setState(() => _applyIgtf = v ?? false),
                    contentPadding: EdgeInsets.zero,
                  ),
                  const Spacer(),
                  const Divider(),
                  _buildTotalRow('Subtotal', '\$ 30.00'),
                  _buildTotalRow('IVA 16%', '\$ 4.80'),
                  if (_applyIgtf) _buildTotalRow('IGTF 3%', '\$ 0.90'),
                  const Divider(thickness: 2),
                  _buildTotalRow('TOTAL USD', _applyIgtf ? '\$ 35.70' : '\$ 34.80', isBold: true),
                  _buildTotalRow('TOTAL BS', _applyIgtf ? 'Bs. 1285.20' : 'Bs. 1252.80', isBold: true),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildPaymentBtn('Efectivo USD'),
                      _buildPaymentBtn('Pago Móvil'),
                      _buildPaymentBtn('Punto de Venta'),
                      _buildPaymentBtn('Zelle'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                    ),
                    onPressed: () {},
                    child: const Text('COBRAR', style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: isBold ? 18 : 16, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(fontSize: isBold ? 18 : 16, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  Widget _buildPaymentBtn(String label) {
    return OutlinedButton(
      onPressed: () {},
      child: Text(label),
    );
  }
}
