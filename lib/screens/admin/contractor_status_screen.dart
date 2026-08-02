import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';

// ─── Contractor Status (Admin — read-only) ─────────────────────────────
// Lets any GAIL staff member using the Admin console see, at a glance,
// exactly where each dispatched order stands in the kitchen — Pending,
// Received, Prepared, or Served — without needing the separate Contractor
// app. This screen is READ-ONLY: status is only ever changed by the
// contractor themselves (in the Contractor app), Admin just observes it.
//
// It reads the same `contractorStatus` / `contractorId` fields on
// CateringRequest that the Contractor app writes to — see models.dart.
class ContractorStatusScreen extends StatefulWidget {
  const ContractorStatusScreen({super.key});

  @override
  State<ContractorStatusScreen> createState() => _ContractorStatusScreenState();
}

class _ContractorStatusScreenState extends State<ContractorStatusScreen> {
  final _store = AppDataStore();
  String? _selectedContractorId; // null = All contractors

  List<CateringRequest> get _dispatchedOrders => _store.requests
      .where((r) => r.status == RequestStatus.approvedByHR || r.status == RequestStatus.completed)
      .where((r) => _selectedContractorId == null || r.contractorId == _selectedContractorId)
      .toList()
    ..sort((a, b) => b.eventDate.compareTo(a.eventDate));

  Contractor? _contractorFor(String id) {
    try {
      return _store.contractors.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final orders = _dispatchedOrders;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
              child: const Text('GAIL',
                  style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1)),
            ),
            const SizedBox(width: 10),
            const Text('Contractor Status', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter by contractor
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
            child: Row(
              children: [
                const Text('Contractor', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
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
                      child: DropdownButton<String?>(
                        value: _selectedContractorId,
                        isExpanded: true,
                        style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary),
                        items: [
                          const DropdownMenuItem<String?>(value: null, child: Text('All Contractors')),
                          ..._store.contractors.map((c) => DropdownMenuItem<String?>(value: c.id, child: Text(c.name))),
                        ],
                        onChanged: (v) => setState(() => _selectedContractorId = v),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                const Text('Dispatched Orders', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                const SizedBox(width: 8),
                Text('${orders.length} total', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
          ),

          Expanded(
            child: orders.isEmpty
                ? const EmptyState(
                    icon: Icons.soup_kitchen_outlined,
                    title: 'No dispatched orders',
                    message: 'Orders will appear here once HR gives final approval and they are sent to a contractor.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    itemCount: orders.length,
                    itemBuilder: (context, i) => _StatusCard(
                      request: orders[i],
                      contractor: _contractorFor(orders[i].contractorId),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final CateringRequest request;
  final Contractor? contractor;
  const _StatusCard({required this.request, required this.contractor});

  @override
  Widget build(BuildContext context) {
    final r = request;
    final fmt = DateFormat('yyyy-MM-dd');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.divider),
      ),
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
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                  ],
                ),
              ),
              _StatusPill(status: r.contractorStatus),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.storefront_outlined, size: 14, color: AppTheme.textSecondary),
              const SizedBox(width: 6),
              Text(contractor?.name ?? 'Unassigned',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
              const SizedBox(width: 16),
              Icon(Icons.place_outlined, size: 14, color: AppTheme.textSecondary),
              const SizedBox(width: 4),
              Text(r.venue, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.event_outlined, size: 14, color: AppTheme.textSecondary),
              const SizedBox(width: 6),
              Text(fmt.format(r.eventDate), style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              const SizedBox(width: 16),
              Icon(Icons.groups_outlined, size: 14, color: AppTheme.textSecondary),
              const SizedBox(width: 4),
              Text('${r.hiTeaPax > 0 ? r.hiTeaPax : r.buffetPax} pax', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            ],
          ),

          const SizedBox(height: 14),
          _StatusTimeline(current: r.contractorStatus),
        ],
      ),
    );
  }
}

// Small colored pill showing the current kitchen status.
class _StatusPill extends StatelessWidget {
  final ContractorOrderStatus status;
  const _StatusPill({required this.status});

  Color get _color {
    switch (status) {
      case ContractorOrderStatus.pending: return AppTheme.textSecondary;
      case ContractorOrderStatus.received: return AppTheme.warning;
      case ContractorOrderStatus.prepared: return AppTheme.accent;
      case ContractorOrderStatus.served: return AppTheme.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: _color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
      child: Text(
        status.label.toUpperCase(),
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _color, letterSpacing: 0.4),
      ),
    );
  }
}

// Horizontal step tracker: Received -> Prepared -> Served
class _StatusTimeline extends StatelessWidget {
  final ContractorOrderStatus current;
  const _StatusTimeline({required this.current});

  static const _steps = [
    ContractorOrderStatus.received,
    ContractorOrderStatus.prepared,
    ContractorOrderStatus.served,
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(_steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          final leftDone = current.index >= _steps[(i - 1) ~/ 2].index;
          return Expanded(
            child: Container(height: 2, color: leftDone ? AppTheme.success : AppTheme.divider),
          );
        }
        final step = _steps[i ~/ 2];
        final done = current.index >= step.index;
        return Column(
          children: [
            Icon(
              done ? Icons.check_circle : Icons.radio_button_unchecked,
              size: 18,
              color: done ? AppTheme.success : AppTheme.textSecondary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 4),
            Text(
              step.label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: done ? AppTheme.success : AppTheme.textSecondary,
              ),
            ),
          ],
        );
      }),
    );
  }
}
