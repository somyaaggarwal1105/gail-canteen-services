import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import 'contractor_login_screen.dart';

// ─── Contractor Home — Today's Service ────────────────────────────────
// Reads/writes the same AppDataStore singleton used by Admin, Initiator,
// Approver, and HR — because this file lives in the SAME Flutter package
// as those screens (see lib/main_contractor.dart for this app's separate
// entry point). It is not reachable from lib/main.dart's role picker.
class ContractorHomeScreen extends StatefulWidget {
  final Contractor contractor;
  const ContractorHomeScreen({super.key, required this.contractor});

  @override
  State<ContractorHomeScreen> createState() => _ContractorHomeScreenState();
}

enum _StatusFilter { all, active, pending, served }

extension on _StatusFilter {
  String get label {
    switch (this) {
      case _StatusFilter.all: return 'All';
      case _StatusFilter.active: return 'Active';
      case _StatusFilter.pending: return 'Pending';
      case _StatusFilter.served: return 'Served';
    }
  }
}

class _ContractorHomeScreenState extends State<ContractorHomeScreen> {
  final _store = AppDataStore();
  _StatusFilter _filter = _StatusFilter.all;

  List<CateringRequest> get _myOrders => _store.requests
      .where((r) =>
          r.contractorId == widget.contractor.id &&
          (r.status == RequestStatus.approvedByHR || r.status == RequestStatus.completed))
      .toList()
    ..sort((a, b) => a.eventDate.compareTo(b.eventDate));

  List<CateringRequest> get _filtered {
    switch (_filter) {
      case _StatusFilter.all:
        return _myOrders;
      case _StatusFilter.active:
        return _myOrders.where((r) => r.contractorStatus != ContractorOrderStatus.served).toList();
      case _StatusFilter.pending:
        return _myOrders.where((r) => r.contractorStatus == ContractorOrderStatus.pending).toList();
      case _StatusFilter.served:
        return _myOrders.where((r) => r.contractorStatus == ContractorOrderStatus.served).toList();
    }
  }

  int get _approvedCount => _myOrders.length;

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const ContractorLoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final orders = _filtered;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
              child: const Text('GAIL',
                  style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1)),
            ),
            const SizedBox(width: 10),
            const Text('Canteen · Contractor', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_outlined, color: Colors.white), onPressed: () {}),
          IconButton(icon: const Icon(Icons.logout, color: Colors.white, size: 20), onPressed: _logout),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            color: AppTheme.primary,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Today's\nService.",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white, height: 1.1)),
                const SizedBox(height: 6),
                Text(widget.contractor.name,
                    style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.7))),
              ],
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Row(
              children: [
                const Text('Status', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.divider),
                      borderRadius: BorderRadius.circular(6),
                      color: Colors.white,
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<_StatusFilter>(
                        value: _filter,
                        isExpanded: true,
                        style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary),
                        items: _StatusFilter.values
                            .map((f) => DropdownMenuItem(value: f, child: Text(f.label)))
                            .toList(),
                        onChanged: (v) => setState(() => _filter = v ?? _StatusFilter.all),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                const Text('Active Orders', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                const SizedBox(width: 8),
                Text('$_approvedCount approved · ${widget.contractor.name}',
                    style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
          ),
          Expanded(
            child: orders.isEmpty
                ? const EmptyState(
                    icon: Icons.restaurant_menu_outlined,
                    title: 'No orders here',
                    message: 'Orders approved by HR will appear here for service.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                    itemCount: orders.length,
                    itemBuilder: (context, i) => _OrderCard(
                      request: orders[i],
                      onStatusChanged: () => setState(() {}),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final CateringRequest request;
  final VoidCallback onStatusChanged;
  const _OrderCard({required this.request, required this.onStatusChanged});

  void _advance(BuildContext context, ContractorOrderStatus target) {
    request.contractorStatus = target;
    onStatusChanged();
    String message;
    switch (target) {
      case ContractorOrderStatus.received:
        message = 'Order marked as Received.';
        break;
      case ContractorOrderStatus.prepared:
        message = 'Order marked as Prepared.';
        break;
      case ContractorOrderStatus.served:
        message = 'Order Served — sent to Initiator for acknowledgement.';
        break;
      case ContractorOrderStatus.pending:
        message = 'Order reset to Pending.';
        break;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppTheme.success, behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = request;
    final fmt = DateFormat('yyyy-MM-dd');
    final isHiTea = r.cateringType.toLowerCase().contains('hi-tea');

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ORDER ${r.id}',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textSecondary, letterSpacing: 0.5)),
                      const SizedBox(height: 2),
                      Text(r.cateringType,
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(20)),
                  child: const Text('APPROVED BY HR',
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppTheme.success, letterSpacing: 0.3)),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 12),

            _infoRow('VENUE', r.venue),
            _infoRow('DATE', fmt.format(r.eventDate)),
            _infoRow(isHiTea ? 'HI-TEA TIME' : 'BUFFET TIME', (isHiTea ? r.hiTeaTime : r.buffetTime) ?? '—'),
            _infoRow('PAX', '${isHiTea ? r.hiTeaPax : r.buffetPax}'),
            _infoRow('WATER (250ML)', r.mineralWaterBottles > 0 ? '${r.mineralWaterBottles}' : '—'),
            if (r.presidingOfficer.isNotEmpty) _infoRow('VIPS', r.presidingOfficer),

            const SizedBox(height: 12),
            const Text('MENU REQUIRED',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.textSecondary, letterSpacing: 1)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: r.menuItems
                  .map((m) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(color: AppTheme.chipBg, borderRadius: BorderRadius.circular(6)),
                        child: Text(m, style: const TextStyle(fontSize: 11, color: AppTheme.accent, fontWeight: FontWeight.w500)),
                      ))
                  .toList(),
            ),

            if (r.contractorInstructions.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text('INSTRUCTIONS',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.textSecondary, letterSpacing: 1)),
              const SizedBox(height: 6),
              Text(r.contractorInstructions,
                  style: const TextStyle(fontSize: 12, color: AppTheme.textPrimary, fontStyle: FontStyle.italic)),
            ],

            const SizedBox(height: 16),
            const Text('ACKNOWLEDGEMENT',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.textSecondary, letterSpacing: 1)),
            const SizedBox(height: 8),
            Row(
              children: [
                _ackAction(
                  context,
                  label: 'Received',
                  icon: Icons.inventory_2_outlined,
                  done: r.contractorStatus.index >= ContractorOrderStatus.received.index,
                  enabled: r.contractorStatus == ContractorOrderStatus.pending,
                  onTap: () => _advance(context, ContractorOrderStatus.received),
                ),
                const SizedBox(width: 8),
                _ackAction(
                  context,
                  label: 'Prepared',
                  icon: Icons.soup_kitchen,
                  done: r.contractorStatus.index >= ContractorOrderStatus.prepared.index,
                  enabled: r.contractorStatus == ContractorOrderStatus.received,
                  onTap: () => _advance(context, ContractorOrderStatus.prepared),
                ),
                const SizedBox(width: 8),
                _ackAction(
                  context,
                  label: 'Served',
                  icon: Icons.check_circle_outline,
                  done: r.contractorStatus == ContractorOrderStatus.served,
                  enabled: r.contractorStatus == ContractorOrderStatus.prepared,
                  onTap: () => _advance(context, ContractorOrderStatus.served),
                ),
              ],
            ),

            if (r.contractorStatus == ContractorOrderStatus.served) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(8)),
                child: const Center(
                  child: Text('Served · awaiting initiator acknowledgement',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.success)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 120, child: Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary))),
            Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary))),
          ],
        ),
      );

  Widget _ackAction(
    BuildContext context, {
    required String label,
    required IconData icon,
    required bool done,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    final color = done ? AppTheme.success : (enabled ? AppTheme.accent : AppTheme.textSecondary.withValues(alpha: 0.4));
    return Expanded(
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: done ? const Color(0xFFE8F5E9) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: done ? AppTheme.success : AppTheme.divider),
          ),
          child: Column(
            children: [
              Icon(done ? Icons.check_circle : icon, size: 18, color: color),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}
