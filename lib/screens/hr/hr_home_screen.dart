import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';

class HRHomeScreen extends StatefulWidget {
  const HRHomeScreen({super.key});

  @override
  State<HRHomeScreen> createState() => _HRHomeScreenState();
}

class _HRHomeScreenState extends State<HRHomeScreen> {
  final _store = AppDataStore();
  RequestStatus? _selectedFilter;

  // HR sees all requests that have been approved by Approver or further
  List<CateringRequest> get _allRequests => _store.requests
      .where((r) =>
          r.status == RequestStatus.approvedByApprover ||
          r.status == RequestStatus.approvedByHR ||
          r.status == RequestStatus.rejected ||
          r.status == RequestStatus.completed)
      .toList()
    ..sort((a, b) => b.initiatedOn.compareTo(a.initiatedOn));

  List<CateringRequest> get _filteredRequests {
    if (_selectedFilter == null) return _allRequests;
    return _allRequests.where((r) => r.status == _selectedFilter).toList();
  }

  int get _pendingCount =>
      _allRequests.where((r) => r.status == RequestStatus.approvedByApprover).length;

  void _openDetail(CateringRequest req) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => HRRequestDetailSheet(
        request: req,
        onApprove: () {
          setState(() => req.status = RequestStatus.approvedByHR);
        },
        onReject: (remarks) {
          setState(() {
            req.status = RequestStatus.rejected;
            req.rejectionRemarks = remarks;
          });
        },
      ),
    );
  }

  Widget _statusChip(RequestStatus status) {
    Color bg;
    Color fg;
    String label;
    switch (status) {
      case RequestStatus.approvedByApprover:
        bg = const Color(0xFFFFF3E0);
        fg = AppTheme.warning;
        label = 'Approved by Approver';
        break;
      case RequestStatus.approvedByHR:
        bg = const Color(0xFFE8F5E9);
        fg = AppTheme.success;
        label = 'Approved by HR';
        break;
      case RequestStatus.rejected:
        bg = const Color(0xFFFFEBEE);
        fg = AppTheme.error;
        label = 'Rejected';
        break;
      default:
        bg = AppTheme.chipBg;
        fg = AppTheme.accent;
        label = status.label;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: fg),
          overflow: TextOverflow.ellipsis),
    );
  }

  @override
  Widget build(BuildContext context) {
    final requests = _filteredRequests;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text('GAIL',
                  style: TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      letterSpacing: 1)),
            ),
            const SizedBox(width: 10),
            const Text('HR Module',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600, fontSize: 17)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header card
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('HR Approvals',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary)),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                    children: [
                      TextSpan(
                        text: '$_pendingCount pending',
                        style: const TextStyle(
                            color: AppTheme.warning, fontWeight: FontWeight.w600),
                      ),
                      const TextSpan(text: ' · Neha Gupta'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Status filter
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Row(
              children: [
                const Text('Status',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary)),
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
                      child: DropdownButton<RequestStatus?>(
                        value: _selectedFilter,
                        isExpanded: true,
                        hint: const Text('All Statuses',
                            style: TextStyle(fontSize: 13)),
                        style: const TextStyle(
                            fontSize: 13, color: AppTheme.textPrimary),
                        items: [
                          const DropdownMenuItem(
                              value: null, child: Text('All Statuses')),
                          DropdownMenuItem(
                            value: RequestStatus.approvedByApprover,
                            child: Text('Approved by Approver',
                                style: TextStyle(
                                    fontSize: 13, color: AppTheme.warning)),
                          ),
                          DropdownMenuItem(
                            value: RequestStatus.approvedByHR,
                            child: Text('Approved by HR',
                                style: TextStyle(
                                    fontSize: 13, color: AppTheme.success)),
                          ),
                          DropdownMenuItem(
                            value: RequestStatus.rejected,
                            child: Text('Rejected',
                                style: TextStyle(
                                    fontSize: 13, color: AppTheme.error)),
                          ),
                        ],
                        onChanged: (val) =>
                            setState(() => _selectedFilter = val),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Table header
          Container(
            color: AppTheme.primary,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: const Row(
              children: [
                SizedBox(
                  width: 80,
                  child: Text('S.NO',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12)),
                ),
                Expanded(
                  child: Text('INITIATOR',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12)),
                ),
                SizedBox(
                  width: 150,
                  child: Text('STATUS',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12)),
                ),
              ],
            ),
          ),

          // Request list
          Expanded(
            child: requests.isEmpty
                ? const EmptyState(
                    icon: Icons.how_to_reg_outlined,
                    title: 'No requests',
                    message: 'No requests pending HR approval.',
                  )
                : ListView.builder(
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      final req = requests[index];
                      final isEven = index % 2 == 0;
                      return InkWell(
                        onTap: () => _openDetail(req),
                        child: Container(
                          color: isEven ? Colors.white : const Color(0xFFF7F9FC),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 80,
                                child: Text(req.id,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                        color: AppTheme.accent)),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(req.initiatorName,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                            color: AppTheme.textPrimary)),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${req.initiatedOn.toString().substring(0, 10)}  ${req.cateringType}',
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: AppTheme.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 150,
                                child: _statusChip(req.status),
                              ),
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

// ─── HR Request Detail Bottom Sheet ──────────────────────────────────────────

class HRRequestDetailSheet extends StatefulWidget {
  final CateringRequest request;
  final VoidCallback onApprove;
  final ValueChanged<String> onReject;

  const HRRequestDetailSheet({
    super.key,
    required this.request,
    required this.onApprove,
    required this.onReject,
  });

  @override
  State<HRRequestDetailSheet> createState() => _HRRequestDetailSheetState();
}

class _HRRequestDetailSheetState extends State<HRRequestDetailSheet> {
  bool _isApproved = false;
  bool _showRejectForm = false;
  final TextEditingController _remarkCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _isApproved = widget.request.status == RequestStatus.approvedByHR;
  }

  @override
  void dispose() {
    _remarkCtrl.dispose();
    super.dispose();
  }

  bool get _isPending =>
      widget.request.status == RequestStatus.approvedByApprover;

  @override
  Widget build(BuildContext context) {
    final r = widget.request;
    final screenH = MediaQuery.of(context).size.height;
    final fmt = r.eventDate.toString().substring(0, 10);

    return Container(
      height: screenH * 0.90,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 10),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Sheet header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Text(r.id,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 20, color: AppTheme.textSecondary),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.chipBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      r.status.label.toUpperCase(),
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.accent,
                          letterSpacing: 0.5),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Initiator
                  _sectionLabel('INITIATOR'),
                  _row('Name', r.initiatorName),
                  _row('Department', r.department),
                  _row('Initiated On', r.initiatedOn.toString().substring(0, 10)),

                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),

                  // Event
                  _sectionLabel('EVENT'),
                  _row('Venue', r.venue),
                  _row('Type', r.cateringType),
                  _row('Date', fmt),
                  if (r.hiTeaTime != null) _row('Hi-Tea Time', r.hiTeaTime!),
                  if (r.buffetTime != null) _row('Buffet Time', r.buffetTime!),
                  _row('Duration', r.duration),

                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),

                  // Meeting
                  _sectionLabel('MEETING'),
                  if (r.natureOfMeeting.isNotEmpty)
                    _row('Nature', r.natureOfMeeting),
                  if (r.presidingOfficer.isNotEmpty)
                    _row('VIPs', r.presidingOfficer),

                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),

                  // Quantities
                  _sectionLabel('PAX & PROVISIONS'),
                  _row('Hi-Tea Pax', r.hiTeaPax > 0 ? '${r.hiTeaPax}' : '—'),
                  _row('Buffet Pax', r.buffetPax > 0 ? '${r.buffetPax}' : '—'),
                  _row('Mineral Water',
                      r.mineralWaterBottles > 0 ? '${r.mineralWaterBottles} bottles' : '—'),
                  if (r.packedItems.isNotEmpty)
                    _row('Packed Items', r.packedItems.join(', ')),

                  if (r.menuItems.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 12),
                    _sectionLabel('MENU'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: r.menuItems
                          .map((item) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppTheme.chipBg,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: const Color(0xFFBBCCEE)),
                                ),
                                child: Text(item,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.accent,
                                        fontWeight: FontWeight.w500)),
                              ))
                          .toList(),
                    ),
                  ],

                  // Approver route
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),
                  _sectionLabel('APPROVER ROUTE'),
                  _row('Approver', r.approverName),

                  // Rejection remarks (read)
                  if (r.rejectionRemarks != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
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
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.error)),
                          const SizedBox(height: 4),
                          Text(r.rejectionRemarks!,
                              style: const TextStyle(
                                  fontSize: 13, color: AppTheme.textPrimary)),
                        ],
                      ),
                    ),
                  ],

                  // Reject form
                  if (_showRejectForm) ...[
                    const SizedBox(height: 20),
                    const Text('Rejection Remarks *',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.error)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _remarkCtrl,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Enter remarks (mandatory)',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: AppTheme.error),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Action buttons
          if (_isApproved)
            _successBanner('Request Approved by HR', AppTheme.success, Icons.check_circle)
          else if (r.status == RequestStatus.rejected)
            _successBanner('Request Rejected', AppTheme.error, Icons.cancel)
          else if (_isPending && !_showRejectForm)
            _actionButtons()
          else if (_isPending && _showRejectForm)
            _rejectConfirmButtons(),
        ],
      ),
    );
  }

  Widget _actionButtons() => Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppTheme.divider)),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => setState(() => _showRejectForm = true),
                icon: const Icon(Icons.close, size: 18, color: AppTheme.error),
                label: const Text('Reject',
                    style: TextStyle(
                        color: AppTheme.error, fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.error),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() => _isApproved = true);
                  widget.onApprove();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Request approved by HR and sent to Contractor.'),
                      backgroundColor: AppTheme.success,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.check, size: 18, color: Colors.white),
                label: const Text('Final Approve',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B5E20),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ),
      );

  Widget _rejectConfirmButtons() => Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppTheme.divider)),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _showRejectForm = false),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  if (_remarkCtrl.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Remarks are mandatory for rejection.'),
                        backgroundColor: AppTheme.error,
                      ),
                    );
                    return;
                  }
                  widget.onReject(_remarkCtrl.text.trim());
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Request rejected and sent to initiator.'),
                      backgroundColor: AppTheme.error,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.error,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Confirm Reject',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      );

  Widget _successBanner(String message, Color color, IconData icon) => Container(
        width: double.infinity,
        color: color.withValues(alpha: 0.1),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(message,
                style: TextStyle(
                    color: color, fontWeight: FontWeight.w700, fontSize: 14)),
          ],
        ),
      );

  Widget _sectionLabel(String label) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(label,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppTheme.textSecondary,
                letterSpacing: 0.8)),
      );

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 120,
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 13, color: AppTheme.textSecondary)),
            ),
            Expanded(
              child: Text(value,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary)),
            ),
          ],
        ),
      );
}
