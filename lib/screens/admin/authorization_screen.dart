import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';

class AuthorizationScreen extends StatefulWidget {
  const AuthorizationScreen({super.key});

  @override
  State<AuthorizationScreen> createState() => _AuthorizationScreenState();
}

class _AuthorizationScreenState extends State<AuthorizationScreen> {
  final _store = AppDataStore();

  // Simulate employee lookup
  final _employeeDatabase = {
    'EMP-101': HRApprover(id: 'new1', employeeName: 'Priya Mathur', cpfNumber: 'CPF-10091', designation: 'Executive Director', department: 'Finance'),
    'EMP-102': HRApprover(id: 'new2', employeeName: 'Ramesh Nair', cpfNumber: 'CPF-10067', designation: 'General Manager', department: 'HR'),
  };

  String? _selectedEmployeeId;
  HRApprover? _selectedEmployee;

  void _onEmployeeSelect(String? id) {
    setState(() {
      _selectedEmployeeId = id;
      _selectedEmployee = id != null ? _employeeDatabase[id] : null;
    });
  }

  void _addApprover() {
    if (_selectedEmployee == null) return;
    if (_store.hrApprovers.any((a) => a.id == _selectedEmployee!.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This employee is already an HR Approver'), behavior: SnackBarBehavior.floating),
      );
      return;
    }
    setState(() {
      _store.hrApprovers.add(_selectedEmployee!);
      _selectedEmployeeId = null;
      _selectedEmployee = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_selectedEmployee?.employeeName ?? "Approver"} added as HR Approver'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _removeApprover(HRApprover approver) async {
    if (_store.hrApprovers.length <= 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Minimum 2 HR Approvers required'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppTheme.warning,
        ),
      );
      return;
    }
    final confirmed = await showConfirmDialog(
      context,
      title: 'Remove Approver',
      message: 'Remove ${approver.employeeName} as HR Approver?',
      confirmLabel: 'Remove',
      confirmColor: AppTheme.error,
    );
    if (confirmed == true) {
      setState(() => _store.hrApprovers.remove(approver));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GAILAppBar(title: 'Authorization'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFFE082)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Color(0xFFF57F17), size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'At least 2 authorised HR approvers are required for requisition.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: const Color(0xFF5D4037)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Add HR Approver form
            const SectionHeader(title: 'Add HR Approver', subtitle: 'Select employee from directory'),
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
                  const _FieldLabel('EMPLOYEE NAME'),
                  DropdownButtonFormField<String>(
                    value: _selectedEmployeeId,
                    decoration: const InputDecoration(hintText: 'Select'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Select employee')),
                      ..._employeeDatabase.entries.map((e) => DropdownMenuItem(
                            value: e.key,
                            child: Text(e.value.employeeName),
                          )),
                    ],
                    onChanged: _onEmployeeSelect,
                  ),
                  if (_selectedEmployee != null) ...[
                    const SizedBox(height: 16),
                    // Auto-populated fields
                    _AutoPopulatedField(label: 'CPF NUMBER & NAME', value: '${_selectedEmployee!.cpfNumber} – ${_selectedEmployee!.employeeName}'),
                    const SizedBox(height: 8),
                    _AutoPopulatedField(label: 'DESIGNATION', value: _selectedEmployee!.designation),
                    const SizedBox(height: 8),
                    _AutoPopulatedField(label: 'DEPARTMENT', value: _selectedEmployee!.department),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Spacer(),
                        Text('Auto populated fields', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 10, fontStyle: FontStyle.italic)),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_back, size: 12, color: AppTheme.textSecondary),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _selectedEmployee != null ? _addApprover : null,
                      child: const Text('Add HR Approver'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Approver HR List
            SectionHeader(
              title: 'Approver HR',
              subtitle: '${_store.hrApprovers.length} authorised approvers',
            ),
            ..._store.hrApprovers.asMap().entries.map((entry) {
              final i = entry.key;
              final approver = entry.value;
              return _ApproverRow(
                index: i + 1,
                approver: approver,
                onRemove: () => _removeApprover(approver),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.textSecondary, letterSpacing: 1)),
      );
}

class _AutoPopulatedField extends StatelessWidget {
  final String label;
  final String value;
  const _AutoPopulatedField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.textSecondary, letterSpacing: 0.8)),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.divider),
          ),
          child: Text(value, style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary)),
        ),
      ],
    );
  }
}

class _ApproverRow extends StatelessWidget {
  final int index;
  final HRApprover approver;
  final VoidCallback onRemove;

  const _ApproverRow({required this.index, required this.approver, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppTheme.chipBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('$index',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.accent)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(approver.employeeName,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                Text('${approver.designation} · ${approver.department}',
                    style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                Text(approver.cpfNumber,
                    style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, color: AppTheme.error, size: 20),
            onPressed: onRemove,
            tooltip: 'Remove',
          ),
        ],
      ),
    );
  }
}
