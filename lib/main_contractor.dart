import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/contractor/contractor_login_screen.dart';

// ─── GAIL Canteen — Contractor App (separate entry point) ─────────────
// Build/run this app on its own with:
//   flutter run -t lib/main_contractor.dart
//   flutter build apk -t lib/main_contractor.dart
//
// It compiles to a completely separate binary from lib/main.dart (the
// Admin/Initiator/Approver/HR app) — different launch screen, no shared
// navigation, installable on its own on the contractor's device. Both
// entry points live in this one package and both import the same
// lib/models/models.dart (same AppDataStore), lib/theme, and
// lib/widgets — so the two apps stay connected through shared code and
// data structures without either one surfacing the other's screens.
void main() {
  runApp(const ContractorApp());
}

class ContractorApp extends StatelessWidget {
  const ContractorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GAIL Canteen — Contractor',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const ContractorLoginScreen(),
    );
  }
}
