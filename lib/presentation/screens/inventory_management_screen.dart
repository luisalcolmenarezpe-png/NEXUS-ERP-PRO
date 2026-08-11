// lib/presentation/screens/inventory_management_screen.dart

import 'package:flutter/material.dart';

class InventoryManagementScreen extends StatefulWidget {
  const InventoryManagementScreen({Key? key}) : super(key: key);

  @override
  State<InventoryManagementScreen> createState() => _InventoryManagementScreenState();
}

class _InventoryManagementScreenState extends State<InventoryManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _verticalFilter = 'Retail';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Inventario'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Stock Actual'),
            Tab(text: 'Movimientos Kardex'),
            Tab(text: 'Alertas de Reorden'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const Text('Filtro de Rubro: '),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _verticalFilter,
                  items: ['Retail', 'Ropa', 'Ferretería', 'Supermercado'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (v) => setState(() => _verticalFilter = v!),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildStockTab(),
                _buildKardexTab(),
                _buildAlertsTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showMovementDialog(context),
        label: const Text('Registrar Movimiento'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStockTab() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('SKU')),
          DataColumn(label: Text('Producto')),
          DataColumn(label: Text('Stock Actual')),
          DataColumn(label: Text('Mín')),
          DataColumn(label: Text('Máx')),
          DataColumn(label: Text('Ubicación')),
          DataColumn(label: Text('Costo USD')),
          DataColumn(label: Text('Precio USD')),
        ],
        rows: [
          const DataRow(cells: [
            DataCell(Text('SKU001')),
            DataCell(Text('Harina Pan')),
            DataCell(Text('150')),
            DataCell(Text('50')),
            DataCell(Text('500')),
            DataCell(Text('P-01, E-02')),
            DataCell(Text('\$0.80')),
            DataCell(Text('\$1.20')),
          ]),
          DataRow(
            color: MaterialStateProperty.resolveWith<Color?>((states) => Colors.red.shade100),
            cells: const [
              DataCell(Text('SKU002')),
              DataCell(Text('Aceite Vatel')),
              DataCell(Text('5')),
              DataCell(Text('20')),
              DataCell(Text('200')),
              DataCell(Text('P-02, E-01')),
              DataCell(Text('\$1.50')),
              DataCell(Text('\$2.00')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKardexTab() {
    return ListView(
      children: const [
        ListTile(
          leading: Icon(Icons.arrow_upward, color: Colors.green),
          title: Text('Entrada por Compra (SKU001)'),
          subtitle: Text('Cantidad: +100 | Fecha: 2023-10-25 10:00 AM'),
          trailing: Text('Factura 123'),
        ),
        ListTile(
          leading: Icon(Icons.delete, color: Colors.red),
          title: Text('Merma por Daño (SKU002)'),
          subtitle: Text('Cantidad: -2 | Razón: Envase Roto'),
          trailing: Text('Evidencia adjunta'),
        ),
      ],
    );
  }

  Widget _buildAlertsTab() {
    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.warning, color: Colors.red),
          title: const Text('Aceite Vatel (SKU002)'),
          subtitle: const Text('Stock: 5 | Punto Reorden: 20'),
          trailing: ElevatedButton(onPressed: () {}, child: const Text('Generar Orden')),
        ),
      ],
    );
  }

  void _showMovementDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Registrar Movimiento de Inventario'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              items: ['Entrada', 'Salida', 'Merma'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) {},
              decoration: const InputDecoration(labelText: 'Tipo de Movimiento'),
            ),
            const SizedBox(height: 8),
            TextFormField(decoration: const InputDecoration(labelText: 'Producto (SKU)')),
            const SizedBox(height: 8),
            TextFormField(decoration: const InputDecoration(labelText: 'Cantidad'), keyboardType: TextInputType.number),
            const SizedBox(height: 8),
            TextFormField(decoration: const InputDecoration(labelText: 'Razón')),
            const SizedBox(height: 8),
            CheckboxListTile(
              title: const Text('Adjuntar Evidencia (Foto)'),
              value: false,
              onChanged: (v) {},
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Guardar')),
        ],
      ),
    );
  }
}
