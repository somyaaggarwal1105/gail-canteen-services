import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';

// ─── View All Requests ───────────────────────────────────────────────
class ViewRequestsScreen extends StatefulWidget {
  const ViewRequestsScreen({super.key});

  @override
  State<ViewRequestsScreen> createState() => _ViewRequestsScreenState();
}

class _ViewRequestsScreenState extends State<ViewRequestsScreen> {
  final _store = AppDataStore();
  String _filter = 'All';

  List<CateringRequest> get _filtered {
    final all = _store.requests.where((r) => r.initiatorName == 'Rajesh Kumar').toList()
      ..sort((a, b) => b.initiatedOn.compareTo(a.initiatedOn));
    if (_filter == 'All') return all;
    return all.where((r) => r.status.label.toLowerCase().contains(_filter.toLowerCase())).toList();
  }

  final _filters = ['All', 'Submitted', 'Approved', 'Rejected', 'Completed'];

  @override
  Widget build(BuildContext context) {
    final requests = _filtered;
    final fmt = DateFormat('yyyy-MM-dd');

    return Scaffold(
      appBar: GAILAppBar(title: 'My Requests'),
      body: Column(
        children: [
          // Filter chips
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters.map((f) {
                  final selected = _filter == f;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _filter = f),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: selected ? AppTheme.primary : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: selected ? AppTheme.primary : AppTheme.divider),
                        ),
                        child: Text(f,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: selected ? Colors.white : AppTheme.textPrimary,
                            )),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const Divider(height: 1),
          // List
          Expanded(
            child: requests.isEmpty
                ? const EmptyState(
                    icon: Icons.receipt_long_outlined,
                    title: 'No requests found',
                    message: 'Try a different filter.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      final r = requests[index];
                      return GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => RequestDetailScreen(request: r)),
                        ).then((_) => setState(() {})),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.divider),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(r.id, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
                                        const Spacer(),
                                        StatusBadge.fromStatus(r.status.label),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    Text(r.cateringType, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                                    Text('${r.venue} · ${fmt.format(r.eventDate)}', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        _InfoChip(label: '${r.hiTeaPax + r.buffetPax} Pax'),
                                        const SizedBox(width: 6),
                                        _InfoChip(label: r.duration),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text('Initiated: ${fmt.format(r.initiatedOn)}',
                                        style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios, size: 13, color: AppTheme.textSecondary),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  const _InfoChip({required this.label});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppTheme.chipBg,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.accent, fontWeight: FontWeight.w500)),
      );
}

// ─── Request Detail ──────────────────────────────────────────────────
class RequestDetailScreen extends StatefulWidget {
  final CateringRequest request;
  const RequestDetailScreen({super.key, required this.request});

  @override
  State<RequestDetailScreen> createState() => _RequestDetailScreenState();
}

class _RequestDetailScreenState extends State<RequestDetailScreen> {
  bool _acknowledged = false;
  int _rating = 0;
  bool _feedbackSaved = false;

  bool get _isCompleted => widget.request.status == RequestStatus.approvedByHR || widget.request.status == RequestStatus.completed;

  @override
  Widget build(BuildContext context) {
    final r = widget.request;
    final fmt = DateFormat('yyyy-MM-dd');

    return Scaffold(
      appBar: GAILAppBar(title: r.id),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status + Workflow
            Row(
              children: [
                StatusBadge.fromStatus(r.status.label),
                const Spacer(),
                Text('By ${r.approverName.split(' - ').first}',
                    style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
              ],
            ),
            const SizedBox(height: 16),
            _WorkflowTracker(status: r.status),
            const SizedBox(height: 20),

            // Initiator Info
            _DetailSection(
              title: 'INITIATOR',
              children: [
                InfoRow(label: 'Name', value: r.initiatorName),
                InfoRow(label: 'Department', value: r.department),
                InfoRow(label: 'Initiated On', value: fmt.format(r.initiatedOn)),
              ],
            ),

            // Event Info
            _DetailSection(
              title: 'EVENT',
              children: [
                InfoRow(label: 'Venue', value: r.venue),
                InfoRow(label: 'Catering Type', value: r.cateringType),
                InfoRow(label: 'Date', value: fmt.format(r.eventDate)),
                if (r.hiTeaTime != null) InfoRow(label: 'Hi-Tea Time', value: r.hiTeaTime!),
                if (r.buffetTime != null) InfoRow(label: 'Buffet Time', value: r.buffetTime!),
                InfoRow(label: 'Duration', value: r.duration),
                if (r.natureOfMeeting.isNotEmpty) InfoRow(label: 'Nature of Meeting', value: r.natureOfMeeting),
                if (r.presidingOfficer.isNotEmpty) InfoRow(label: 'VIPs / Presiding Officer', value: r.presidingOfficer),
              ],
            ),

            // Pax & Provisions
            _DetailSection(
              title: 'PAX & PROVISIONS',
              children: [
                InfoRow(label: 'Hi-Tea Pax', value: r.hiTeaPax > 0 ? '${r.hiTeaPax}' : '—'),
                InfoRow(label: 'Buffet Pax', value: r.buffetPax > 0 ? '${r.buffetPax}' : '—'),
                InfoRow(label: 'Mineral Water', value: r.mineralWaterBottles > 0 ? '${r.mineralWaterBottles} bottles' : '—'),
                if (r.packedItems.isNotEmpty) InfoRow(label: 'Packed Items', value: r.packedItems.join(', ')),
              ],
            ),

            // Menu
            if (r.menuItems.isNotEmpty) ...[
              _DetailSection(
                title: '${r.cateringType.toUpperCase()} MENU',
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: r.menuItems.map((item) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppTheme.chipBg,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFBBD6F8)),
                      ),
                      child: Text(item, style: const TextStyle(fontSize: 12, color: AppTheme.accent, fontWeight: FontWeight.w500)),
                    )).toList(),
                  ),
                ],
              ),
            ],

            // Approver Route
            _DetailSection(
              title: 'APPROVER ROUTE',
              children: [
                InfoRow(label: 'Approver', value: r.approverName),
              ],
            ),

            // Rejection remarks
            if (r.status == RequestStatus.rejected && r.rejectionRemarks != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFFCDD2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Rejection Remarks', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.error, letterSpacing: 0.5)),
                    const SizedBox(height: 6),
                    Text(r.rejectionRemarks!, style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary)),
                  ],
                ),
              ),

            // Feedback/Acknowledgement for completed orders
            if (_isCompleted && !_feedbackSaved) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.divider),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('ACKNOWLEDGEMENT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textSecondary, letterSpacing: 0.8)),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: _acknowledged,
                          onChanged: (v) => setState(() => _acknowledged = v ?? false),
                          activeColor: AppTheme.accent,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            '"I acknowledge that the catering services against this requisition have been received satisfactorily and the order has been completed as per requirement."',
                            style: TextStyle(fontSize: 12, color: AppTheme.textPrimary, fontStyle: FontStyle.italic),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Star rating
                    Row(
                      children: List.generate(5, (i) {
                        return GestureDetector(
                          onTap: () => setState(() => _rating = i + 1),
                          child: Icon(
                            i < _rating ? Icons.star : Icons.star_border,
                            color: i < _rating ? const Color(0xFFFFC107) : AppTheme.textSecondary,
                            size: 28,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _acknowledged
                                ? () {
                                    setState(() {
                                      _feedbackSaved = true;
                                      widget.request.status = RequestStatus.completed;
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Acknowledgement saved. Thank you!'),
                                        behavior: SnackBarBehavior.floating,
                                        backgroundColor: AppTheme.success,
                                      ),
                                    );
                                  }
                                : null,
                            child: const Text('Save'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],

            if (_feedbackSaved)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFA5D6A7)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: AppTheme.success, size: 20),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text('Order acknowledged and feedback submitted.', style: TextStyle(fontSize: 13, color: AppTheme.success, fontWeight: FontWeight.w500)),
                    ),
                    Row(
                      children: List.generate(5, (i) => Icon(
                        i < _rating ? Icons.star : Icons.star_border,
                        color: i < _rating ? const Color(0xFFFFC107) : AppTheme.textSecondary,
                        size: 16,
                      )),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _DetailSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.textSecondary, letterSpacing: 1.2)),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

// ─── Workflow Tracker ────────────────────────────────────────────────
class _WorkflowTracker extends StatelessWidget {
  final RequestStatus status;
  const _WorkflowTracker({required this.status});

  int get _currentStep {
    switch (status) {
      case RequestStatus.submitted: return 0;
      case RequestStatus.approvedByApprover: return 1;
      case RequestStatus.approvedByHR: return 2;
      case RequestStatus.completed: return 3;
      case RequestStatus.rejected: return -1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final steps = ['Submitted', 'Approver', 'HR', 'Contractor'];
    final current = _currentStep;
    final isRejected = status == RequestStatus.rejected;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            // Connector line
            final stepIndex = i ~/ 2;
            final isCompleted = !isRejected && current > stepIndex;
            return Expanded(
              child: Container(
                height: 2,
                color: isCompleted ? AppTheme.success : AppTheme.divider,
              ),
            );
          }
          final stepIndex = i ~/ 2;
          final isCompleted = !isRejected && current >= stepIndex;
          final isActive = !isRejected && current == stepIndex;
          return Column(
            children: [
              Container(
                width: 28, height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isRejected && stepIndex == 0
                      ? AppTheme.error
                      : isCompleted
                          ? AppTheme.success
                          : Colors.white,
                  border: Border.all(
                    color: isCompleted ? AppTheme.success : AppTheme.divider,
                    width: 2,
                  ),
                ),
                child: Icon(
                  isCompleted || (isRejected && stepIndex == 0) ? Icons.check : Icons.circle,
                  size: 12,
                  color: isCompleted ? Colors.white : (isRejected && stepIndex == 0 ? Colors.white : AppTheme.divider),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                steps[stepIndex],
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.normal,
                  color: isCompleted ? AppTheme.success : AppTheme.textSecondary,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
