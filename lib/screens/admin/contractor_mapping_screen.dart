import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';

class ContractorMappingScreen extends StatefulWidget {
  const ContractorMappingScreen({super.key});

  @override
  State<ContractorMappingScreen> createState() => _ContractorMappingScreenState();
}

class _ContractorMappingScreenState extends State<ContractorMappingScreen> {
  final _store = AppDataStore();

  void _showContractorDialog({Contractor? contractor}) {
    final nameCtrl = TextEditingController(text: contractor?.name ?? '');
    final emailCtrl = TextEditingController(text: contractor?.email ?? '');
    final contactCtrl = TextEditingController(text: contractor?.contactName ?? '');
    final remarksCtrl = TextEditingController(text: contractor?.remarks ?? '');
    final formKey = GlobalKey<FormState>();
    final isEdit = contractor != null;
    final dateFmt = DateFormat('dd MMM yyyy');

    DateTime? startDate = contractor?.contractStartDate;
    DateTime? endDate = contractor?.contractEndDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          Future<void> pickStartDate() async {
            final picked = await showDatePicker(
              context: ctx,
              initialDate: startDate ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2100),
            );
            if (picked != null) {
              setSheetState(() {
                startDate = picked;
                // Keep end date sensible if it's now before the new start date.
                if (endDate != null && endDate!.isBefore(picked)) endDate = null;
              });
            }
          }

          Future<void> pickEndDate() async {
            final picked = await showDatePicker(
              context: ctx,
              initialDate: endDate ?? (startDate ?? DateTime.now()).add(const Duration(days: 365)),
              firstDate: startDate ?? DateTime(2020),
              lastDate: DateTime(2100),
            );
            if (picked != null) setSheetState(() => endDate = picked);
          }

          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: Container(
                            width: 40, height: 4,
                            margin: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(color: AppTheme.divider, borderRadius: BorderRadius.circular(2))),
                      ),
                      Row(
                        children: [
                          Text(isEdit ? 'Edit Contractor' : 'Add Contractor',
                              style: Theme.of(context).textTheme.headlineSmall),
                          const Spacer(),
                          IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildLabel('NAME'),
                      TextFormField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(hintText: 'Contractor Name'),
                        validator: (v) => v == null || v.isEmpty ? 'Name is required' : null,
                      ),
                      const SizedBox(height: 12),
                      _buildLabel('EMAIL'),
                      TextFormField(
                        controller: emailCtrl,
                        decoration: const InputDecoration(hintText: 'vendor@example.com'),
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Email is required';
                          if (!v.contains('@')) return 'Enter valid email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildLabel('CONTACT DETAILS'),
                      TextFormField(
                        controller: contactCtrl,
                        decoration: const InputDecoration(hintText: 'Contact person name'),
                      ),
                      const SizedBox(height: 12),
                      _buildLabel('CONTRACT VALIDITY'),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: pickStartDate,
                              borderRadius: BorderRadius.circular(8),
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  hintText: 'Start date',
                                  prefixIcon: Icon(Icons.event_outlined, size: 18),
                                ),
                                child: Text(
                                  startDate != null ? dateFmt.format(startDate!) : 'Start date',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: startDate != null ? AppTheme.textPrimary : AppTheme.textSecondary.withValues(alpha: 0.6),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: InkWell(
                              onTap: pickEndDate,
                              borderRadius: BorderRadius.circular(8),
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  hintText: 'End date',
                                  prefixIcon: Icon(Icons.event_busy_outlined, size: 18),
                                ),
                                child: Text(
                                  endDate != null ? dateFmt.format(endDate!) : 'End date',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: endDate != null ? AppTheme.textPrimary : AppTheme.textSecondary.withValues(alpha: 0.6),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (startDate != null && endDate != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          'Valid for ${_formatDuration(startDate!, endDate!)}',
                          style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary, fontStyle: FontStyle.italic),
                        ),
                      ],
                      const SizedBox(height: 12),
                      _buildLabel('REMARKS'),
                      TextFormField(
                        controller: remarksCtrl,
                        decoration: const InputDecoration(hintText: 'Optional notes'),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                if (!formKey.currentState!.validate()) return;
                                if (startDate != null && endDate != null && endDate!.isBefore(startDate!)) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('End date must be after start date'),
                                      backgroundColor: AppTheme.error,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                  return;
                                }
                                setState(() {
                                  if (isEdit) {
                                    contractor!.name = nameCtrl.text.trim();
                                    contractor.email = emailCtrl.text.trim();
                                    contractor.contactName = contactCtrl.text.trim();
                                    contractor.remarks = remarksCtrl.text.trim();
                                    contractor.contractStartDate = startDate;
                                    contractor.contractEndDate = endDate;
                                  } else {
                                    _store.contractors.add(Contractor(
                                      id: 'c${DateTime.now().millisecondsSinceEpoch}',
                                      name: nameCtrl.text.trim(),
                                      email: emailCtrl.text.trim(),
                                      contactName: contactCtrl.text.trim(),
                                      remarks: remarksCtrl.text.trim(),
                                      contractStartDate: startDate,
                                      contractEndDate: endDate,
                                    ));
                                  }
                                });
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(isEdit ? 'Contractor updated' : 'Contractor added'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              child: const Text('Save'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDuration(DateTime start, DateTime end) {
    final days = end.difference(start).inDays;
    if (days >= 365) {
      final years = (days / 365).floor();
      final remMonths = ((days % 365) / 30).round();
      return remMonths > 0 ? '$years yr $remMonths mo' : '$years yr';
    }
    if (days >= 30) {
      final months = (days / 30).round();
      return '$months mo';
    }
    return '$days days';
  }

  Widget _buildLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textSecondary, letterSpacing: 1)),
      );

  Future<void> _deleteContractor(Contractor c) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete Contractor',
      message: 'Are you sure you want to delete "${c.name}"? This action cannot be undone.',
      confirmLabel: 'Delete',
      confirmColor: AppTheme.error,
    );
    if (confirmed == true) {
      setState(() => _store.contractors.remove(c));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contractor deleted'), behavior: SnackBarBehavior.floating),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GAILAppBar(
        title: 'Contractor Mapping',
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showContractorDialog(),
            tooltip: 'Add Contractor',
          ),
        ],
      ),
      body: _store.contractors.isEmpty
          ? const EmptyState(
              icon: Icons.people_outline,
              title: 'No contractors yet',
              message: 'Tap + to add your first contractor.',
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                  child: Text(
                    '${_store.contractors.length} mapped',
                    style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showContractorDialog(),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Contractor'),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                    itemCount: _store.contractors.length,
                    itemBuilder: (context, index) {
                      final c = _store.contractors[index];
                      return _ContractorCard(
                        contractor: c,
                        onEdit: () => _showContractorDialog(contractor: c),
                        onDelete: () => _deleteContractor(c),
                        onToggle: () => setState(() => c.isActive = !c.isActive),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

class _ContractorCard extends StatelessWidget {
  final Contractor contractor;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggle;

  const _ContractorCard({
    required this.contractor,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd MMM yyyy');
    final hasValidity = contractor.contractStartDate != null && contractor.contractEndDate != null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(contractor.name,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                          ),
                          if (contractor.isExpired) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(color: const Color(0xFFFDECEA), borderRadius: BorderRadius.circular(20)),
                              child: const Text('EXPIRED',
                                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppTheme.error, letterSpacing: 0.3)),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(contractor.email,
                          style: const TextStyle(fontSize: 12, color: AppTheme.accent)),
                      if (hasValidity) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.event_outlined, size: 13,
                                color: contractor.isExpired ? AppTheme.error : AppTheme.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              '${dateFmt.format(contractor.contractStartDate!)} – ${dateFmt.format(contractor.contractEndDate!)}',
                              style: TextStyle(
                                fontSize: 11,
                                color: contractor.isExpired ? AppTheme.error : AppTheme.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (contractor.remarks.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(contractor.remarks,
                            style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                      ],
                    ],
                  ),
                ),
                Switch(
                  value: contractor.isActive,
                  onChanged: (_) => onToggle(),
                  activeThumbColor: AppTheme.success,
                  activeTrackColor: AppTheme.success.withValues(alpha: 0.4),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(),
            Row(
              children: [
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 15),
                  label: const Text('Edit'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.accent,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline, size: 15),
                  label: const Text('Delete'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.error,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
