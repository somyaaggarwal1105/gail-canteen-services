import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';

class ApproverHomeScreen extends StatefulWidget {
  const ApproverHomeScreen({super.key});

  @override
  State<ApproverHomeScreen> createState() => _ApproverHomeScreenState();
}

class _ApproverHomeScreenState extends State<ApproverHomeScreen> {
  final _store = AppDataStore();
  final String approverName = 'Anil Verma';
  int? _expandedIndex;

  List<CateringRequest> get _requests => _store.requests
      .where((r) => r.approverName.contains('Anil Verma'))
      .toList()
    ..sort((a, b) => b.initiatedOn.compareTo(a.initiatedOn));

  int get _pendingCount =>
      _requests.where((r) => r.status == RequestStatus.submitted).length;

  void _approveRequest(CateringRequest request) {
    setState(() {
      request.status = RequestStatus.approvedByApprover;
      _expandedIndex = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Request approved and sent to HR.'),
        backgroundColor: Colors.green[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  void _rejectRequest(CateringRequest request) {
    final remarksCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Reject Request',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        content: TextField(
          controller: remarksCtrl,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Enter remarks (mandatory)',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.all(12),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              if (remarksCtrl.text.trim().isEmpty) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(
                    content: Text('Remarks are mandatory for rejection.'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              Navigator.pop(ctx);
              setState(() {
                request.status = RequestStatus.rejected;
                request.rejectionRemarks = remarksCtrl.text.trim();
                _expandedIndex = null;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Request rejected.'),
                  backgroundColor: Colors.red[700],
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              );
            },
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final requests = _requests;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: Column(
        children: [
          // Top bar
          Container(
            color: AppTheme.primary,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 10,
              left: 18,
              right: 8,
              bottom: 14,
            ),
            child: Row(
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
                  icon: const Icon(Icons.logout, color: Colors.white70, size: 20),
                  onPressed: () => Navigator.pop(context),
                  tooltip: 'Logout',
                ),
              ],
            ),
          ),

          // Header
          Container(
            color: AppTheme.primary,
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Pending Reviews',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text('Canteen Services — Approver Module',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13)),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: _pendingCount > 0
                              ? AppTheme.error
                              : Colors.white.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text('$_pendingCount',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(approverName,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 2),
                          Text('AWAITING YOUR ACTION',
                              style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontSize: 11,
                                  letterSpacing: 1)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // List header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: const Row(
              children: [
                SizedBox(
                  width: 90,
                  child: Text('S.NO',
                      style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                          letterSpacing: 0.8,
                          fontWeight: FontWeight.w700)),
                ),
                Expanded(
                  child: Text('INITIATOR',
                      style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                          letterSpacing: 0.8,
                          fontWeight: FontWeight.w700)),
                ),
                Text('STATUS',
                    style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                        letterSpacing: 0.8,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          const Divider(height: 1),

          // Request list
          Expanded(
            child: requests.isEmpty
                ? const EmptyState(
                    icon: Icons.inbox_outlined,
                    title: 'No requests',
                    message: 'No catering requests assigned to you.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(14),
                    itemCount: requests.length,
                    itemBuilder: (context, i) => _ApproverRequestCard(
                      index: i,
                      request: requests[i],
                      isExpanded: _expandedIndex == i,
                      onTap: () => setState(() {
                        _expandedIndex = _expandedIndex == i ? null : i;
                      }),
                      onApprove: () => _approveRequest(requests[i]),
                      onReject: () => _rejectRequest(requests[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ─── Request Card ─────────────────────────────────────────────────────────────

class _ApproverRequestCard extends StatelessWidget {
  final int index;
  final CateringRequest request;
  final bool isExpanded;
  final VoidCallback onTap;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _ApproverRequestCard({
    required this.index,
    required this.request,
    required this.isExpanded,
    required this.onTap,
    required this.onApprove,
    required this.onReject,
  });

  Color get _statusColor {
    switch (request.status) {
      case RequestStatus.approvedByApprover:
      case RequestStatus.approvedByHR:
        return AppTheme.success;
      case RequestStatus.rejected:
        return AppTheme.error;
      default:
        return AppTheme.warning;
    }
  }

  Color get _statusBg {
    switch (request.status) {
      case RequestStatus.approvedByApprover:
      case RequestStatus.approvedByHR:
        return const Color(0xFFE8F5E9);
      case RequestStatus.rejected:
        return const Color(0xFFFFEBEE);
      default:
        return const Color(0xFFFFF3E0);
    }
  }

  String get _statusLabel {
    switch (request.status) {
      case RequestStatus.approvedByApprover:
        return 'Approved';
      case RequestStatus.approvedByHR:
        return 'Approved by HR';
      case RequestStatus.rejected:
        return 'Rejected';
      default:
        return 'Submitted';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: isExpanded
                ? const BorderRadius.vertical(top: Radius.circular(10))
                : BorderRadius.circular(10),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              child: Row(
                children: [
                  SizedBox(
                    width: 90,
                    child: Text(request.id,
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary)),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(request.initiatorName,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.textPrimary)),
                        const SizedBox(height: 2),
                        Text('${request.initiatedOn.toString().substring(0, 10)} · ${request.cateringType}',
                            style: const TextStyle(
                                fontSize: 11, color: AppTheme.textSecondary)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _statusBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(_statusLabel,
                        style: TextStyle(
                            fontSize: 11,
                            color: _statusColor,
                            fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 6),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.keyboard_arrow_down,
                        color: AppTheme.textSecondary, size: 18),
                  ),
                ],
              ),
            ),
          ),

          // Expanded detail panel
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _ApproverDetailPanel(
              request: request,
              onApprove: onApprove,
              onReject: onReject,
            ),
            crossFadeState:
                isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}

// ─── Detail Panel ─────────────────────────────────────────────────────────────

class _ApproverDetailPanel extends StatelessWidget {
  final CateringRequest request;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _ApproverDetailPanel({
    required this.request,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final r = request;
    final isPending = r.status == RequestStatus.submitted;
    final fmt = r.eventDate.toString().substring(0, 10);

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(top: BorderSide(color: AppTheme.divider)),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Request ${r.id}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              StatusBadge.fromStatus(r.status.label),
            ],
          ),
          const SizedBox(height: 12),

          // Detail grid
          _grid([
            _Entry('Initiator', r.initiatorName),
            _Entry('Department', r.department),
            _Entry('Initiated On', r.initiatedOn.toString().substring(0, 10)),
            _Entry('Venue', r.venue),
            _Entry('Type', r.cateringType),
            _Entry('Event Date', fmt),
            if (r.hiTeaTime != null) _Entry('Hi-Tea Time', r.hiTeaTime!),
            _Entry('Duration', r.duration),
            _Entry('Meeting', r.natureOfMeeting.isEmpty ? '—' : r.natureOfMeeting),
            _Entry('VIPs', r.presidingOfficer.isEmpty ? '—' : r.presidingOfficer),
            _Entry('Hi-Tea Pax', r.hiTeaPax > 0 ? '${r.hiTeaPax}' : '—'),
            _Entry('Buffet Pax', r.buffetPax > 0 ? '${r.buffetPax}' : '—'),
            _Entry('Water (250ml)', r.mineralWaterBottles > 0 ? '${r.mineralWaterBottles}' : '—'),
          ]),

          if (r.menuItems.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text('MENU ITEMS',
                style: TextStyle(
                    fontSize: 10,
                    color: AppTheme.textSecondary,
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: r.menuItems
                  .map((item) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.chipBg,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFFBBD6F8)),
                        ),
                        child: Text(item,
                            style: const TextStyle(
                                fontSize: 12, color: AppTheme.accent, fontWeight: FontWeight.w500)),
                      ))
                  .toList(),
            ),
          ],

          if (r.rejectionRemarks != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFFCDD2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Rejection Remarks',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.error,
                          letterSpacing: 0.6)),
                  const SizedBox(height: 4),
                  Text(r.rejectionRemarks!,
                      style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary)),
                ],
              ),
            ),
          ],

          if (isPending) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.success,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    onPressed: onApprove,
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Approve',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.error,
                      side: const BorderSide(color: AppTheme.error),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: onReject,
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text('Reject',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _grid(List<_Entry> entries) {
    final rows = <Widget>[];
    for (var i = 0; i < entries.length; i += 2) {
      rows.add(Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Expanded(child: _cell(entries[i])),
            if (i + 1 < entries.length)
              Expanded(child: _cell(entries[i + 1]))
            else
              const Expanded(child: SizedBox()),
          ],
        ),
      ));
    }
    return Column(children: rows);
  }

  Widget _cell(_Entry e) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(e.label.toUpperCase(),
              style: const TextStyle(
                  fontSize: 10,
                  color: AppTheme.textSecondary,
                  letterSpacing: 0.6)),
          const SizedBox(height: 2),
          Text(e.value,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary)),
        ],
      );
}

class _Entry {
  final String label;
  final String value;
  const _Entry(this.label, this.value);
}
