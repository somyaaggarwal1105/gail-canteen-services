import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';

class MISReportsScreen extends StatefulWidget {
  const MISReportsScreen({super.key});

  @override
  State<MISReportsScreen> createState() => _MISReportsScreenState();
}

class _MISReportsScreenState extends State<MISReportsScreen> {
  final _store = AppDataStore();
  DateTime? _fromDate;
  DateTime? _toDate;
  String _selectedDept = 'All';
  String _selectedApprover = 'All';

  final _departments = ['All', 'Marketing', 'Operations', 'Finance', 'HR'];

  List<CateringRequest> get _filtered {
    return _store.requests.where((r) {
      final deptMatch = _selectedDept == 'All' || r.department == _selectedDept;
      final approverMatch = _selectedApprover == 'All' || r.approverName.contains(_selectedApprover.split(' - ').first);
      final fromMatch = _fromDate == null || !r.eventDate.isBefore(_fromDate!);
      final toMatch = _toDate == null || !r.eventDate.isAfter(_toDate!);
      return deptMatch && approverMatch && fromMatch && toMatch;
    }).toList();
  }

  Future<void> _pickDate(bool isFrom) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2025),
      lastDate: DateTime(2027),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) { _fromDate = picked; } else { _toDate = picked; }
      });
    }
  }

  void _showExportSnack(String format) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exporting as $format... (Integration required)'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(label: 'OK', onPressed: () {}),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppTheme.primary : AppTheme.divider),
        ),
        child: Text(label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: selected ? Colors.white : AppTheme.textPrimary,
            )),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final requests = _filtered;
    final fmt = DateFormat('MMM d, y');

    return Scaffold(
      appBar: GAILAppBar(title: 'MIS Reports'),
      body: Column(
        children: [
          // Filters
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date range
                Row(
                  children: [
                    Expanded(
                      child: _DatePickerField(
                        label: 'From',
                        value: _fromDate != null ? fmt.format(_fromDate!) : null,
                        onTap: () => _pickDate(true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DatePickerField(
                        label: 'To',
                        value: _toDate != null ? fmt.format(_toDate!) : null,
                        onTap: () => _pickDate(false),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Department filter
                const Text('Department', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textSecondary, letterSpacing: 0.8)),
                const SizedBox(height: 6),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _departments
                        .map((d) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: _buildFilterChip(d, _selectedDept == d, () => setState(() => _selectedDept = d)),
                            ))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 12),
                // Export buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showExportSnack('Excel'),
                        icon: const Icon(Icons.table_chart_outlined, size: 16),
                        label: const Text('Export Excel'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          textStyle: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showExportSnack('PDF'),
                        icon: const Icon(Icons.picture_as_pdf_outlined, size: 16),
                        label: const Text('Export PDF'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          textStyle: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Quick Report Buttons
          Container(
            color: AppTheme.surface,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              children: [
                _QuickReportButton(label: 'Monthly report of consumption', onTap: () {}),
                const SizedBox(height: 8),
                _QuickReportButton(label: 'Cancelled requests report', onTap: () {}),
                const SizedBox(height: 8),
                _QuickReportButton(label: 'Purpose of meeting', onTap: () {}),
              ],
            ),
          ),

          const Divider(height: 1),

          // Results table
          Expanded(
            child: requests.isEmpty
                ? const EmptyState(
                    icon: Icons.bar_chart_outlined,
                    title: 'No data found',
                    message: 'Adjust filters to view reports.',
                  )
                : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Date-wise lunch/high tea requests (${requests.length})',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                          ),
                          const SizedBox(height: 8),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: _buildRequestsTable(requests),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Department-wise consumption',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                          ),
                          const SizedBox(height: 8),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: _buildDeptTable(requests),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestsTable(List<CateringRequest> requests) {
    final fmt = DateFormat('MMM d');
    return Table(
      border: TableBorder.all(color: AppTheme.divider, width: 1),
      defaultColumnWidth: const IntrinsicColumnWidth(),
      children: [
        TableRow(
          decoration: const BoxDecoration(color: AppTheme.primary),
          children: ['S.No', 'Requested By', 'Requested On', 'Event Type', 'Purpose', 'Event Date', 'Qty Ordered', 'Status']
              .map((h) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Text(h, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                  ))
              .toList(),
        ),
        ...requests.asMap().entries.map((e) {
          final i = e.key;
          final r = e.value;
          return TableRow(
            decoration: BoxDecoration(color: i.isEven ? Colors.white : AppTheme.surface),
            children: [
              '${i + 1}',
              r.initiatorName,
              fmt.format(r.initiatedOn),
              r.cateringType,
              r.natureOfMeeting.isEmpty ? '—' : r.natureOfMeeting,
              fmt.format(r.eventDate),
              '${r.hiTeaPax + r.buffetPax}',
              r.status.label,
            ]
                .map((v) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      child: Text(v, style: const TextStyle(fontSize: 12, color: AppTheme.textPrimary)),
                    ))
                .toList(),
          );
        }),
      ],
    );
  }

  Widget _buildDeptTable(List<CateringRequest> requests) {
    // Group by department
    final deptMap = <String, List<CateringRequest>>{};
    for (final r in requests) {
      deptMap.putIfAbsent(r.department, () => []).add(r);
    }

    return Table(
      border: TableBorder.all(color: AppTheme.divider, width: 1),
      defaultColumnWidth: const IntrinsicColumnWidth(),
      children: [
        TableRow(
          decoration: const BoxDecoration(color: AppTheme.primary),
          children: ['S.No', 'Department', 'Total Requests', 'Hi-Tea Pax', 'Buffet Pax', 'Status']
              .map((h) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Text(h, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                  ))
              .toList(),
        ),
        ...deptMap.entries.toList().asMap().entries.map((entry) {
          final i = entry.key;
          final dept = entry.value.key;
          final reqs = entry.value.value;
          final hiTea = reqs.fold(0, (s, r) => s + r.hiTeaPax);
          final buffet = reqs.fold(0, (s, r) => s + r.buffetPax);
          return TableRow(
            decoration: BoxDecoration(color: i.isEven ? Colors.white : AppTheme.surface),
            children: [
              '${i + 1}',
              dept,
              '${reqs.length}',
              '$hiTea',
              '$buffet',
              'Active',
            ]
                .map((v) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      child: Text(v, style: const TextStyle(fontSize: 12, color: AppTheme.textPrimary)),
                    ))
                .toList(),
          );
        }),
      ],
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final String label;
  final String? value;
  final VoidCallback onTap;

  const _DatePickerField({required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.divider),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined, size: 16, color: AppTheme.accent),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
                  Text(
                    value ?? 'Select',
                    style: TextStyle(
                      fontSize: 13,
                      color: value != null ? AppTheme.textPrimary : AppTheme.textSecondary,
                      fontWeight: value != null ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickReportButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickReportButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Row(
          children: [
            const Icon(Icons.description_outlined, size: 16, color: AppTheme.accent),
            const SizedBox(width: 10),
            Expanded(child: Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary))),
            const Icon(Icons.chevron_right, size: 18, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }
}
