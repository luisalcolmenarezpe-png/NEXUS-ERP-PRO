import 'package:flutter/material.dart';
import '../../core/accounting/accounting_engine.dart';

class POSScreen extends StatefulWidget {
  const POSScreen({Key? key}) : super(key: key);

  @override
  State<POSScreen> createState() => _POSScreenState();
}

class _POSScreenState extends State<POSScreen> {
  final AccountingEngine _accountingEngine = AccountingEngine();
  
  // Tasa de cambio de ejemplo (configurable globalmente)
  final double _exchangeRateVES = 36.50; 

  // Carrito de compras (Mock inicial para diseño)
  final List<Map<String, dynamic>> _cart = [
    {'name': 'Teclado Mecánico', 'priceUSD': 45.0, 'qty': 1},
    {'name': 'Mouse Inalámbrico', 'priceUSD': 15.0, 'qty': 2},
  ];

  double get _totalUSD => _cart.fold(0, (sum, item) => sum + (item['priceUSD'] * item['qty']));
  double get _totalVES => _totalUSD * _exchangeRateVES;

  // Controladores de pago
  final TextEditingController _usdController = TextEditingController();
  final TextEditingController _vesController = TextEditingController();

  double _paidUSD = 0.0;
  double _paidVES = 0.0;

  @override
  void initState() {
    super.initState();
    _usdController.addListener(_updatePayments);
    _vesController.addListener(_updatePayments);
  }

  void _updatePayments() {
    setState(() {
      _paidUSD = double.tryParse(_usdController.text) ?? 0.0;
      _paidVES = double.tryParse(_vesController.text) ?? 0.0;
    });
  }

  @override
  void dispose() {
    _usdController.dispose();
    _vesController.dispose();
    super.dispose();
  }

  void _processPayment() async {
    final totalPaidInUSD = _paidUSD + (_paidVES / _exchangeRateVES);
    
    // Validar que el pago cubra el total
    if ((totalPaidInUSD - _totalUSD) < -0.01) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fondos insuficientes. Complete el pago.', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red),
      );
      return;
    }

    try {
      final transactionId = 'POS_${DateTime.now().millisecondsSinceEpoch}';
      List<JournalEntryData> entries = [];
      
      // 1. Ingreso a Caja USD (Débito)
      if (_paidUSD > 0) {
        entries.add(JournalEntryData(
          accountId: '101', // Asumiendo '101' es Caja USD
          debit: _paidUSD,
          currency: 'USD',
          exchangeRate: 1.0,
        ));
      }

      // 2. Ingreso a Caja VES (Débito)
      if (_paidVES > 0) {
        entries.add(JournalEntryData(
          accountId: '102', // Asumiendo '102' es Caja VES
          debit: _paidVES,
          currency: 'VES',
          exchangeRate: _exchangeRateVES,
        ));
      }

      // 3. Reconocimiento de Ingreso por Ventas (Crédito)
      entries.add(JournalEntryData(
        accountId: '401', // Asumiendo '401' es Ingresos por Ventas
        credit: _totalUSD,
        currency: 'USD',
        exchangeRate: 1.0,
      ));

      // 4. Registrar en el Motor Contable
      await _accountingEngine.processTransaction(
        transactionId: transactionId,
        date: DateTime.now().toUtc().toIso8601String(),
        description: 'Venta POS - Pago Mixto',
        entries: entries,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Pago procesado exitosamente en partida doble.'), backgroundColor: Colors.green),
      );

      // Limpiar interfaz
      setState(() {
        _cart.clear();
        _usdController.clear();
        _vesController.clear();
      });

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error contable: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terminal Punto de Venta (POS)'),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      body: Row(
        children: [
          // PANEL IZQUIERDO: Lista de Productos
          Expanded(
            flex: 6,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Productos Seleccionados', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const Divider(),
                  Expanded(
                    child: _cart.isEmpty 
                      ? const Center(child: Text('El carrito está vacío.'))
                      : ListView.builder(
                          itemCount: _cart.length,
                          itemBuilder: (context, index) {
                            final item = _cart[index];
                            final subtotal = item['priceUSD'] * item['qty'];
                            return Card(
                              elevation: 1,
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              child: ListTile(
                                leading: const Icon(Icons.shopping_bag, color: Colors.teal),
                                title: Text(item['name']),
                                subtitle: Text('${item['qty']} x \$${item['priceUSD'].toStringAsFixed(2)}'),
                                trailing: Text('\$${subtotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              ),
                            );
                          },
                        ),
                  ),
                ],
              ),
            ),
          ),
          const VerticalDivider(width: 1, thickness: 1),
          
          // PANEL DERECHO: Pagos y Calculadora
          Expanded(
            flex: 4,
            child: Container(
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Resumen a Pagar', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  
                  // Totales
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.teal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.teal.withOpacity(0.5)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('TOTAL USD:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Text('\$${_totalUSD.toStringAsFixed(2)}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.tealAccent)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('TOTAL VES:', style: TextStyle(fontSize: 16, color: Colors.grey)),
                            Text('Bs ${_totalVES.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Calculadora de Pagos Mixtos
                  const Text('Método de Pago (Mixto)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _usdController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Pago en Divisas (USD)',
                      prefixIcon: Icon(Icons.monetization_on),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _vesController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Pago en Bolívares (VES)',
                      prefixIcon: Icon(Icons.account_balance_wallet),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const Spacer(),
                  
                  // Cálculo de Vuelto / Restante
                  _buildBalanceIndicator(),
                  const SizedBox(height: 16),
                  
                  // Botón Procesar
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _cart.isEmpty ? null : _processPayment,
                      child: const Text('PROCESAR PAGO', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceIndicator() {
    final totalPaidInUSD = _paidUSD + (_paidVES / _exchangeRateVES);
    final diff = totalPaidInUSD - _totalUSD;
    
    if (diff < 0) {
      return Text(
        'Faltan: \$${diff.abs().toStringAsFixed(2)}',
        style: const TextStyle(color: Colors.redAccent, fontSize: 18, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      );
    } else if (diff > 0) {
      return Text(
        'Vuelto (Cambio): \$${diff.toStringAsFixed(2)}',
        style: const TextStyle(color: Colors.orangeAccent, fontSize: 18, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      );
    }
    return const Text(
      'Pago exacto',
      style: TextStyle(color: Colors.greenAccent, fontSize: 18, fontWeight: FontWeight.bold),
      textAlign: TextAlign.center,
    );
  }
}
