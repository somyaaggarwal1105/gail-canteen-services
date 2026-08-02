import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// ─── Status Badge ────────────────────────────────────────────────────
class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color bgColor;

  const StatusBadge({super.key, required this.label, required this.color, required this.bgColor});

  factory StatusBadge.fromStatus(String status) {
    switch (status.toLowerCase()) {
      case 'submitted':
        return const StatusBadge(label: 'Submitted', color: Color(0xFF1565C0), bgColor: Color(0xFFE3F2FD));
      case 'approved by approver':
        return const StatusBadge(label: 'Approved by Approver', color: Color(0xFF2E7D32), bgColor: Color(0xFFE8F5E9));
      case 'approved by hr':
        return const StatusBadge(label: 'Approved by HR', color: Color(0xFF1B5E20), bgColor: Color(0xFFC8E6C9));
      case 'rejected':
        return const StatusBadge(label: 'Rejected', color: Color(0xFFC62828), bgColor: Color(0xFFFFEBEE));
      case 'completed':
        return const StatusBadge(label: 'Completed', color: Color(0xFF4A148C), bgColor: Color(0xFFF3E5F5));
      default:
        return const StatusBadge(label: 'Unknown', color: AppTheme.textSecondary, bgColor: AppTheme.surface);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }
}

// ─── Section Header ──────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const SectionHeader({super.key, required this.title, this.subtitle, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              if (subtitle != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(subtitle!, style: Theme.of(context).textTheme.bodyMedium),
                ),
            ]),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

// ─── Info Row ────────────────────────────────────────────────────────
class InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const InfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.textPrimary))),
        ],
      ),
    );
  }
}

// ─── Empty State ─────────────────────────────────────────────────────
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const EmptyState({super.key, required this.icon, required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 56, color: AppTheme.textSecondary.withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(message, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

// ─── Confirm Dialog ──────────────────────────────────────────────────
Future<bool?> showConfirmDialog(BuildContext context, {required String title, required String message, String confirmLabel = 'Confirm', Color? confirmColor}) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: ElevatedButton.styleFrom(backgroundColor: confirmColor ?? AppTheme.primary),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
}

// ─── GAIL App Bar Logo ───────────────────────────────────────────────
class GAILAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBack;

  const GAILAppBar({super.key, required this.title, this.actions, this.showBack = true});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
        ],
      ),
      leading: showBack && Navigator.canPop(context)
          ? IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 18), onPressed: () => Navigator.pop(context))
          : null,
      actions: actions,
    );
  }
}
