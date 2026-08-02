import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import 'create_request_screen.dart';
import 'view_requests_screen.dart';

class InitiatorHomeScreen extends StatefulWidget {
  const InitiatorHomeScreen({super.key});

  @override
  State<InitiatorHomeScreen> createState() => _InitiatorHomeScreenState();
}

class _InitiatorHomeScreenState extends State<InitiatorHomeScreen> {
  final _store = AppDataStore();
  String _filterStatus = 'All';

  List<CateringRequest> get _recentRequests => _store.requests
      .where((r) => r.initiatorName == 'Rajesh Kumar')
      .toList()
    ..sort((a, b) => b.initiatedOn.compareTo(a.initiatedOn));

  int _countByStatus(RequestStatus status) =>
      _recentRequests.where((r) => r.status == status).length;

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('yyyy-MM-dd');
    final requests = _recentRequests;

    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                    child: const Text('GAIL',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppTheme.primary, letterSpacing: 1.5)),
                  ),
                  const Spacer(),
                  // Status filter dropdown
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<String>(
                      value: _filterStatus,
                      dropdownColor: AppTheme.primary,
                      style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500),
                      iconEnabledColor: Colors.white70,
                      underline: const SizedBox(),
                      items: ['All', 'Pending', 'Approved', 'Completed', 'Rejected']
                          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (v) => setState(() => _filterStatus = v ?? 'All'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.white70, size: 22),
                    onPressed: () => Navigator.pop(context),
                    tooltip: 'Logout',
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Hello, Rajesh.',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white)),
                  Text('Marketing · DGM',
                      style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.65))),
                ],
              ),
            ),

            // Main content
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Create button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const CreateRequestScreen()),
                            );
                            setState(() {});
                          },
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Create New Request'),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Stats grid
                      Row(
                        children: [
                          Expanded(child: _StatCard(label: 'Total', value: '${requests.length}', icon: Icons.receipt_long_outlined, color: AppTheme.accent)),
                          const SizedBox(width: 10),
                          Expanded(child: _StatCard(label: 'Pending', value: '${_countByStatus(RequestStatus.submitted)}', icon: Icons.pending_outlined, color: AppTheme.warning)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: _StatCard(label: 'Approved', value: '${_countByStatus(RequestStatus.approvedByHR)}', icon: Icons.check_circle_outline, color: AppTheme.success)),
                          const SizedBox(width: 10),
                          Expanded(child: _StatCard(label: 'Rejected', value: '${_countByStatus(RequestStatus.rejected)}', icon: Icons.cancel_outlined, color: AppTheme.error)),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Recent Requests
                      Row(
                        children: [
                          const Text('Recent Requests',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                          const Spacer(),
                          TextButton(
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const ViewRequestsScreen()),
                              );
                              setState(() {});
                            },
                            child: const Text('VIEW ALL →', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (requests.isEmpty)
                        const EmptyState(
                          icon: Icons.receipt_long_outlined,
                          title: 'No requests yet',
                          message: 'Create your first catering request.',
                        )
                      else
                        ...requests.take(3).map((r) => _RequestCard(request: r, onTap: () {})),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: color)),
              Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final CateringRequest request;
  final VoidCallback onTap;

  const _RequestCard({required this.request, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('yyyy-MM-dd');
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(request.id,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
              const Spacer(),
              StatusBadge.fromStatus(request.status.label),
            ],
          ),
          const SizedBox(height: 6),
          Text(request.cateringType,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          Text('${request.venue} · ${fmt.format(request.eventDate)}',
              style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
          const SizedBox(height: 6),
          Text('${request.hiTeaPax + request.buffetPax} Pax',
              style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Text(fmt.format(request.initiatedOn),
                style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
          ),
        ],
      ),
    );
  }
}
