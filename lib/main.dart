import 'package:flutter/material.dart';
import 'package:gail_canteen/theme/app_theme.dart';
import 'screens/admin/admin_home_screen.dart';
import 'screens/initiator/initiator_home_screen.dart';
import 'screens/approver/approver_home_screen.dart';
import 'screens/hr/hr_home_screen.dart';

void main() {
  runApp(const GAILCanteenApp());
}

class GAILCanteenApp extends StatelessWidget {
  const GAILCanteenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GAIL Canteen Services',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      home: const RoleSelectionScreen(),
    );
  }
}

// ─── Role Selection / Login ──────────────────────────────────────────
class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 48),
                // GAIL badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'GAIL',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.primary,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Canteen\nServices.',
                  style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Select your role to continue',
                  style: TextStyle(
                      fontSize: 14, color: Colors.white.withValues(alpha: 0.65)),
                ),
                const SizedBox(height: 40),

                // Role cards
                _RoleCard(
                  icon: Icons.admin_panel_settings_outlined,
                  role: 'Admin',
                  description: 'Manage contractors, menus & reports',
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const AdminHomeScreen())),
                ),
                const SizedBox(height: 14),
                _RoleCard(
                  icon: Icons.person_outline,
                  role: 'Initiator',
                  description: 'Submit & track catering requests',
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const InitiatorHomeScreen())),
                ),
                const SizedBox(height: 14),
                _RoleCard(
                  icon: Icons.verified_outlined,
                  role: 'Approver',
                  description: 'Review & approve catering requests',
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const ApproverHomeScreen())),
                ),
                const SizedBox(height: 14),
                _RoleCard(
                  icon: Icons.how_to_reg_outlined,
                  role: 'HR',
                  description: 'Final approval & contractor dispatch',
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const HRHomeScreen())),
                ),

                const SizedBox(height: 40),
                Center(
                  child: Text(
                    'Jubilee Tower, Noida',
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.4),
                        letterSpacing: 0.5),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String role;
  final String description;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.role,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(role,
                      style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                  Text(description,
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.65))),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                size: 14, color: Colors.white.withValues(alpha: 0.6)),
          ],
        ),
      ),
    );
  }
}
