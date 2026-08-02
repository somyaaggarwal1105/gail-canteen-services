import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'contractor_mapping_screen.dart';
import 'menu_management_screen.dart';
import 'mis_reports_screen.dart';
import 'authorization_screen.dart';
import 'contractor_status_screen.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      const _AdminMenuItem(
        icon: Icons.people_outline,
        title: 'Contractor Mapping',
        subtitle: 'Manage catering vendors',
        screen: ContractorMappingScreen(),
      ),
      const _AdminMenuItem(
        icon: Icons.menu_book_outlined,
        title: 'Menu Management',
        subtitle: 'Configure Hi-Tea & Lunch menus',
        screen: MenuManagementScreen(),
      ),
      const _AdminMenuItem(
        icon: Icons.bar_chart_outlined,
        title: 'MIS Reports',
        subtitle: 'View & export reports',
        screen: MISReportsScreen(),
      ),
      const _AdminMenuItem(
        icon: Icons.verified_user_outlined,
        title: 'Authorization',
        subtitle: 'Manage HR approvers',
        screen: AuthorizationScreen(),
      ),
      const _AdminMenuItem(
        icon: Icons.soup_kitchen_outlined,
        title: 'Contractor Status',
        subtitle: 'Track kitchen order status',
        screen: ContractorStatusScreen(),
      ),
    ];

    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('GAIL',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.primary,
                                letterSpacing: 1.5)),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.logout, color: Colors.white70, size: 22),
                        onPressed: () => Navigator.pop(context),
                        tooltip: 'Logout',
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text('Admin Console',
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text('Master data & MIS',
                      style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.65))),
                ],
              ),
            ),

            // Menu List
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _AdminMenuTile(item: item);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminMenuItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget screen;
  const _AdminMenuItem({required this.icon, required this.title, required this.subtitle, required this.screen});
}

class _AdminMenuTile extends StatelessWidget {
  final _AdminMenuItem item;
  const _AdminMenuTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => item.screen)),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.chipBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(item.icon, color: AppTheme.accent, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                  const SizedBox(height: 2),
                  Text(item.subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }
}
