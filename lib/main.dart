/// main.dart
/// Punto de entrada principal de la aplicación ERP/POS Híbrida
/// Inicialización de Supabase + Enrutamiento dinámico + Tema adaptativo
import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Core Auth
import 'core/auth/role_manager.dart';
import 'core/auth/role_guard_widget.dart';

// Feature Screens (Legacy)
import 'features/admin/presentation/admin_dashboard_screen.dart';
import 'features/inventory/presentation/waste_entry_screen.dart';
import 'features/pos/presentation/pos_billing_screen.dart';

// Presentation Screens (New Production Modules)
import 'presentation/screens/dashboard_screen.dart';
import 'presentation/screens/pos_checkout_screen.dart';
import 'presentation/screens/inventory_management_screen.dart';
import 'presentation/screens/financial_closure_screen.dart';

/// Credenciales de producción Supabase
const String _supabaseUrl = 'https://splpsibhteqjgjxvyseb.supabase.co';
const String _supabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNwbHBzaWJodGVxamdqeHZ5c2ViIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODU0NTQ0MDIsImV4cCI6MjEwMTAzMDQwMn0.Q9-rfJDWob_R2f0DZ3km3BZazjcKPtKrIGg63Tz_ZmE';

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // 1. Manejador Global de Errores UI de Flutter
    FlutterError.onError = (FlutterErrorDetails details) {
      developer.log('FlutterError Interceptado', error: details.exception, stackTrace: details.stack);
      // Aquí se registraría en la auditoría local para análisis posterior.
    };

    // 2. Manejador Global de Errores Asíncronos y Nativos
    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      developer.log('Platform Error Interceptado', error: error, stackTrace: stack);
      // Evita el crash reportando que fue manejado.
      return true; 
    };

    // Inicialización de Supabase Cloud Backend
    await Supabase.initialize(
      url: _supabaseUrl,
      anonKey: _supabaseAnonKey,
    );

    runApp(const MainErpApp());
  }, (error, stack) {
    developer.log('ZonedGuarded Error Interceptado', error: error, stackTrace: stack);
  });
}

/// Acceso global al cliente Supabase
final supabase = Supabase.instance.client;

class MainErpApp extends StatefulWidget {
  const MainErpApp({Key? key}) : super(key: key);

  @override
  State<MainErpApp> createState() => _MainErpAppState();
}

class _MainErpAppState extends State<MainErpApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nexus ERP Pro • Producción',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,

      // Tema Claro (High-Contrast Professional)
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF1A237E), // Indigo profundo
        brightness: Brightness.light,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 2,
        ),
        cardTheme: CardTheme(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
        ),
      ),

      // Tema Oscuro (Modo Nocturno Gerencial)
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF1A237E),
        brightness: Brightness.dark,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 2,
        ),
        cardTheme: CardTheme(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
        ),
      ),

      // Enrutamiento por Nombre
      initialRoute: '/',
      routes: {
        '/': (context) => RootNavigationScreen(onToggleTheme: _toggleTheme),
        '/dashboard': (context) => const DashboardScreen(),
        '/pos': (context) => const PosCheckoutScreen(),
        '/inventory': (context) => const InventoryManagementScreen(),
        '/closure': (context) => const FinancialClosureScreen(),
      },
    );
  }
}

/// Pantalla raíz con navegación inferior de 5 módulos
class RootNavigationScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  const RootNavigationScreen({Key? key, required this.onToggleTheme})
      : super(key: key);

  @override
  State<RootNavigationScreen> createState() => _RootNavigationScreenState();
}

class _RootNavigationScreenState extends State<RootNavigationScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens = [
    const DashboardScreen(),
    const PosCheckoutScreen(),
    const InventoryManagementScreen(),
    const FinancialClosureScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Nexus ERP Pro • ${RoleManager.currentRole.name.toUpperCase()}'),
        actions: [
          // Toggle Tema Claro/Oscuro
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: widget.onToggleTheme,
            tooltip: 'Cambiar Tema Claro/Oscuro',
          ),
          // Selector dinámico de roles (solo para desarrollo/pruebas)
          PopupMenuButton<UserRole>(
            icon: const Icon(Icons.supervised_user_circle, size: 28),
            tooltip: 'Cambiar Rol de Prueba',
            onSelected: (UserRole selectedRole) {
              setState(() {
                RoleManager.setRole(selectedRole);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text('Rol cambiado a: ${selectedRole.name.toUpperCase()}'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: UserRole.admin,
                child: Text('👑 Administrador (Acceso Total)'),
              ),
              PopupMenuItem(
                value: UserRole.cashier,
                child: Text('💳 Cajero (POS y Facturación)'),
              ),
              PopupMenuItem(
                value: UserRole.fieldOperator,
                child: Text('🚜 Operario (Mermas de Campo)'),
              ),
            ],
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) =>
            setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.point_of_sale_outlined),
            selectedIcon: Icon(Icons.point_of_sale_rounded),
            label: 'Caja POS',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2_rounded),
            label: 'Inventario',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet_rounded),
            label: 'Cierre',
          ),
        ],
      ),
    );
  }
}
