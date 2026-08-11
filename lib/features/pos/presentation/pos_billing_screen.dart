// lib/features/pos/presentation/pos_billing_screen.dart

import 'package:flutter/material.dart';
import '../../../core/fiscal/venezuelan_compliance_engine.dart';
import '../../../core/accounting/fx_currency_engine.dart';
import '../../../core/security/audit_logger.dart';
import '../../../core/utils/tax_engine.dart';

class PosBillingScreen extends StatefulWidget {
  const PosBillingScreen({Key? key}) : super(key: key);

  @override
  State<PosBillingScreen> createState() => _PosBillingScreenState();
}

class _PosBillingScreenState extends State<PosBillingScreen> {
  final TextEditingController _rifController = TextEditingController();
  final TextEditingController _amountUsdController = TextEditingController();
  
  double _bcvExchangeRate = 36.50; // Ejemplo Tasa BCV
  bool _isRifValid = true;
  bool _payInDivisa = false; // Manejo de IGTF

  double _subtotalVes = 0.0;
  double _taxVes = 0.0;
  double _igtfVes = 0.0;
  double _totalVes = 0.0;

  void _calculateBill() {
    final amountUsd = double.tryParse(_amountUsdController.text) ?? 0.0;
    
    // 1. Motor Multimoneda
    final subtotalInVes = FxCurrencyEngine.convertToFieldCurrency(
      foreignAmount: amountUsd, 
      bcvRate: _bcvExchangeRate
    );

    // 2. Motor de Impuestos (IVA 16%)
    final taxInVes = TaxEngine.calculateVAT(subtotalInVes, 0.16);

    // 3. Cumplimiento Legal (IGTF 3% si paga en divisas)
    double igtfInVes = 0.0;
    if (_payInDivisa) {
      final igtfUsd = VenezuelanComplianceEngine.calculateIgtf(
        amountInForeignCurrency: amountUsd
      );
      igtfInVes = igtfUsd * _bcvExchangeRate;
    }

    setState(() {
      _subtotalVes = subtotalInVes;
      _taxVes = taxInVes;
      _igtfVes = igtfInVes;
      _totalVes = subtotalInVes + taxInVes + igtfInVes;
    });
  }

  void _processPayment() {
    // Validar RIF según Ley SENIAT
    final isValid = VenezuelanComplianceEngine.isValidRif(_rifController.text);
    setState(() => _isRifValid = isValid);

    if (!isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('RIF Inválido según norma SENIAT (Ej: J123456789)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Registrar Evento Inmutable en Auditoría Hash
    final logger = AuditLogger();
    final auditEntry = logger.createLogEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: 'CASHIER_01',
      action: AuditAction.login, // Transacción completada
      details: 'Factura procesada Total VES: $_totalVes | RIF: ${_rifController.text}',
      previousHash: 'GENESIS_HASH_00000000000000000000',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Factura procesada con éxito. Hash Audit: ${auditEntry.currentHash.substring(0, 10)}...'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ERP POS Pro - Cobro Fiscal & Multimoneda'),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // RIF / Cédula Cliente
            TextField(
              controller: _rifController,
              decoration: InputDecoration(
                labelText: 'RIF / Cédula Cliente',
                errorText: _isRifValid ? null : 'Estructura RIF errónea',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // Monto de Venta en Divisa
            TextField(
              controller: _amountUsdController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Monto Total (\$ USD)',
                suffixText: 'Tasa BCV: $_bcvExchangeRate VES',
                border: const OutlineInputBorder(),
              ),
              onChanged: (_) => _calculateBill(),
            ),
            const SizedBox(height: 12),

            // Checkbox Pago Divisa (IGTF)
            SwitchListTile(
              title: const Text('Aplica Pago en Divisas / Divisa Efectivo (IGTF 3%)'),
              value: _payInDivisa,
              onChanged: (val) {
                setState(() => _payInDivisa = val);
                _calculateBill();
              },
            ),
            const Divider(),

            // Desglose Fiscal
            Text('Subtotal: Bs. ${_subtotalVes.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16)),
            Text('IVA (16%): Bs. ${_taxVes.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16)),
            Text('IGTF (3%): Bs. ${_igtfVes.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, color: Colors.orange)),
            const SizedBox(height: 8),
            Text(
              'TOTAL A PAGAR: Bs. ${_totalVes.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            const Spacer(),

            // Botón de Procesar
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
                onPressed: _processPayment,
                child: const Text('PROCESAR COBRO FISCAL', style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
