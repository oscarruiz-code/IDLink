import 'package:flutter/material.dart';

// Screens
import '../Screens/login_screen.dart';
import '../Screens/register_screen.dart';
import '../Screens/dashboard_screen.dart';
import '../Screens/qr_scanner_screen.dart';
import '../Screens/access_management_screen.dart';

final Map<String, Widget Function(BuildContext)> appRoutes = {
  '/login': (_) => const LoginScreen(),
  '/register': (_) => const RegisterScreen(),
  '/dashboard': (_) => const DashboardScreen(),
  '/qr_scanner': (_) => const QRScannerScreen(),
  '/access_management': (_) => const AccessManagementScreen(),
};