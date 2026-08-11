/// features/inventory/presentation/waste_entry_screen.dart
/// Interfaz móvil optimizada para operarios de campo (botones grandes y diseño intuitivo)
import 'package:flutter/material.dart';
import '../../core/database/db_helper.dart';

class WasteEntryScreen extends StatefulWidget {
  const WasteEntryScreen({Key? key}) : super(key: key);

  @override
  State<WasteEntryScreen> createState() => _WasteEntryScreenState();
}

class _WasteEntryScreenState extends State<WasteEntryScreen> {
  final _controller = TextEditingController();
  String selectedProduct = 'Tomate / Verduras';
  bool _isLoading = false;

  // Lista rápida de productos de ejemplo (dinámica en el sistema real)
  final List<String> products = ['Tomate / Verduras', 'Papa Nacional', 'Cebolla Blanca', 'Repollo'];

  Future<void> _submitWaste() async {
    if (_controller.text.isEmpty) return;
    setState(() => _isLoading = true);

    try {
      final double quantity = double.tryParse(_controller.text) ?? 0.0;
      
      // Registrar la transacción de merma asegurando el cifrado y encadenamiento local
      await DBHelper.instance.insertSecureTransaction(
        id: 'WASTE_${DateTime.now().millisecondsSinceEpoch}',
        type: 'WASTE',
        totalAmount: quantity,
        data: {
          'product': selectedProduct,
          'waste_quantity': quantity,
          'unit': 'Kg',
          'registered_by': 'Operario de Campo'
        },
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Merma registrada exitosamente sin conexión!'),
          backgroundColor: Colors.green,
        ),
      );
      _controller.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro Rápido de Mermas'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Seleccione el producto afectado:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: selectedProduct,
              items: products.map((p) => DropdownMenuItem(value: p, child: Text(p, style: const TextStyle(fontSize: 16)))).toList(),
              onChanged: (val) => setState(() => selectedProduct = val!),
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
              ),
            ),
            const SizedBox(height: 25),
            const Text(
              'Peso o cantidad de desperdicio (Kg):',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: '0.00',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.scale, size: 30),
              ),
            ),
            const Spacer(),
            SizedBox(
              height: 60,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _submitWaste,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.check_circle, size: 28),
                label: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Registrar Merma', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
