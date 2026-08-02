import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';

class CreateRequestScreen extends StatefulWidget {
  const CreateRequestScreen({super.key});

  @override
  State<CreateRequestScreen> createState() => _CreateRequestScreenState();
}

class _CreateRequestScreenState extends State<CreateRequestScreen> {
  final _store = AppDataStore();
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // Section 1 – Venue & Catering
  String? _venue;
  String? _cateringType;

  // Section 2 – Meeting Details
  final _meetingCtrl = TextEditingController();
  final _presidingCtrl = TextEditingController();
  String _duration = '1-2 hrs';

  // Section 3 – Pax & Provisions
  int _hiTeaPax = 0;
  int _buffetPax = 0;
  int _mineralWater = 0;
  final List<TextEditingController> _packedItemCtrls = List.generate(4, (_) => TextEditingController());

  // Section 4 – Date & Time
  DateTime? _eventDate;
  final _hiTeaTimeCtrl = TextEditingController();
  final _buffetTimeCtrl = TextEditingController();

  // Section 5 – Approver
  String? _approver;

  final _venues = ['Cafeteria', '1st Floor', '2nd Floor', '4th Floor Conference Hall', 'Other'];
  final _cateringTypes = ['Regular Hi-Tea', 'Premium Hi-Tea', 'Buffet Indian Regular Lunch/Dinner', 'Buffet Premium Lunch/Dinner'];
  final _durations = ['1-2 hrs', '2-4 hrs', 'More than 4 hrs'];

  bool get _isHiTea => _cateringType?.contains('Hi-Tea') == true;
  bool get _isBuffet => _cateringType?.contains('Buffet') == true || _cateringType?.contains('Lunch') == true;

  List<String> get _menuForType {
    if (_cateringType == 'Regular Hi-Tea') return _store.menuItems[MenuCategory.hiTeaRegular]!.where((m) => m.isActive).map((m) => m.name).toList();
    if (_cateringType == 'Premium Hi-Tea') return _store.menuItems[MenuCategory.hiTeaPremium]!.where((m) => m.isActive).map((m) => m.name).toList();
    if (_cateringType == 'Buffet Indian Regular Lunch/Dinner') return _store.menuItems[MenuCategory.lunchBuffetRegular]!.where((m) => m.isActive).map((m) => m.name).toList();
    if (_cateringType == 'Buffet Premium Lunch/Dinner') return _store.menuItems[MenuCategory.lunchBuffetPremium]!.where((m) => m.isActive).map((m) => m.name).toList();
    return [];
  }

  String get _menuLabel {
    if (_cateringType == 'Regular Hi-Tea') return 'Hi-Tea Regular Menu';
    if (_cateringType == 'Premium Hi-Tea') return 'Hi-Tea Premium Menu';
    if (_cateringType?.contains('Regular') == true) return 'Buffet Regular Menu';
    return 'Buffet Premium Menu';
  }

  List<String> get _approverOptions => _store.hrApprovers.map((a) => '${a.employeeName} - ${a.designation} (${a.department})').toList();

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _eventDate = picked);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields'), behavior: SnackBarBehavior.floating, backgroundColor: AppTheme.error),
      );
      return;
    }

    if (_venue == null || _cateringType == null || _eventDate == null || _approver == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Venue, Catering Type, Date, and Approver are required'), behavior: SnackBarBehavior.floating, backgroundColor: AppTheme.error),
      );
      return;
    }

    final reqId = _store.nextRequestId;
    _store.incrementCounter();

    final req = CateringRequest(
      id: reqId,
      initiatorName: 'Rajesh Kumar',
      department: 'Marketing',
      initiatedOn: DateTime.now(),
      venue: _venue!,
      cateringType: _cateringType!,
      menuItems: _menuForType,
      natureOfMeeting: _meetingCtrl.text.trim(),
      presidingOfficer: _presidingCtrl.text.trim(),
      duration: _duration,
      hiTeaPax: _hiTeaPax,
      buffetPax: _buffetPax,
      mineralWaterBottles: _mineralWater,
      packedItems: _packedItemCtrls.map((c) => c.text.trim()).where((s) => s.isNotEmpty).toList(),
      eventDate: _eventDate!,
      hiTeaTime: _hiTeaTimeCtrl.text.trim().isEmpty ? null : _hiTeaTimeCtrl.text.trim(),
      buffetTime: _buffetTimeCtrl.text.trim().isEmpty ? null : _buffetTimeCtrl.text.trim(),
      approverName: _approver!,
      status: RequestStatus.submitted,
    );

    _store.requests.insert(0, req);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        icon: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppTheme.success.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: const Icon(Icons.check_circle, color: AppTheme.success, size: 36),
        ),
        title: const Text('Request Submitted!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Your request $reqId has been submitted and sent to the approver.'),
            const SizedBox(height: 8),
            Text('Status: Submitted', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              child: const Text('Done'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({required int number, required String title, required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Container(
                  width: 24, height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                  child: Text('$number', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
                const SizedBox(width: 10),
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 0.5)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
          ),
        ],
      ),
    );
  }

  Widget _label(String text, {bool required = false}) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          children: [
            Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textSecondary, letterSpacing: 0.8)),
            if (required) const Text(' *', style: TextStyle(color: AppTheme.error, fontSize: 12)),
          ],
        ),
      );

  Widget _paxCounter(String label, int value, ValueChanged<int> onChanged) {
    return Row(
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary)),
        const Spacer(),
        IconButton(
          onPressed: value > 0 ? () => onChanged(value - 1) : null,
          icon: const Icon(Icons.remove_circle_outline, size: 22),
          color: AppTheme.accent,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
        SizedBox(
          width: 40,
          child: Text('$value', textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
        ),
        IconButton(
          onPressed: () => onChanged(value + 1),
          icon: const Icon(Icons.add_circle_outline, size: 22),
          color: AppTheme.accent,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('yyyy-MM-dd');

    return Scaffold(
      appBar: GAILAppBar(title: 'New Request'),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text('Catering requisition form', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
              ),

              // Section 1 – Venue & Catering
              _sectionCard(
                number: 1,
                title: 'VENUE & CATERING',
                children: [
                  _label('VENUE', required: true),
                  DropdownButtonFormField<String>(
                    value: _venue,
                    decoration: const InputDecoration(hintText: 'Select venue'),
                    items: _venues.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                    onChanged: (v) => setState(() => _venue = v),
                    validator: (v) => v == null ? 'Venue is required' : null,
                  ),
                  const SizedBox(height: 12),
                  _label('TYPE OF CATERING', required: true),
                  DropdownButtonFormField<String>(
                    value: _cateringType,
                    decoration: const InputDecoration(hintText: 'Select type'),
                    items: _cateringTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                    onChanged: (v) => setState(() => _cateringType = v),
                    validator: (v) => v == null ? 'Catering type is required' : null,
                  ),
                  // Menu preview
                  if (_cateringType != null && _menuForType.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.chipBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFBBD6F8)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_menuLabel,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.accent, letterSpacing: 0.5)),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: _menuForType.map((item) => Chip(
                              label: Text(item, style: const TextStyle(fontSize: 11)),
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            )).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),

              // Section 2 – Meeting Details
              _sectionCard(
                number: 2,
                title: 'MEETING DETAILS',
                children: [
                  _label('NATURE OF MEETING / EVENT'),
                  TextFormField(
                    controller: _meetingCtrl,
                    decoration: const InputDecoration(hintText: 'e.g. Quarterly review meeting...'),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  _label('PRESIDING OFFICER / VIPs'),
                  TextFormField(
                    controller: _presidingCtrl,
                    decoration: const InputDecoration(hintText: 'e.g. CFO, External Auditors'),
                  ),
                  const SizedBox(height: 12),
                  _label('DURATION OF MEETING'),
                  DropdownButtonFormField<String>(
                    value: _duration,
                    items: _durations.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                    onChanged: (v) => setState(() => _duration = v ?? _duration),
                    decoration: const InputDecoration(),
                  ),
                ],
              ),

              // Section 3 – Pax & Provisions
              _sectionCard(
                number: 3,
                title: 'PAX & PROVISIONS',
                children: [
                  if (_isHiTea) ...[
                    _paxCounter('HIGH TEA (NOS.)', _hiTeaPax, (v) => setState(() => _hiTeaPax = v)),
                    const Divider(),
                  ],
                  if (_isBuffet) ...[
                    _paxCounter('BUFFET LUNCH (NOS.)', _buffetPax, (v) => setState(() => _buffetPax = v)),
                    const Divider(),
                  ],
                  _paxCounter('MINERAL WATER (250ML BOTTLES)', _mineralWater, (v) => setState(() => _mineralWater = v)),
                  const SizedBox(height: 12),
                  _label('OTHER PACKED ITEMS / SNACKS'),
                  ...List.generate(4, (i) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: TextFormField(
                      controller: _packedItemCtrls[i],
                      decoration: InputDecoration(hintText: 'Item ${i + 1}'),
                    ),
                  )),
                ],
              ),

              // Section 4 – Date & Time
              _sectionCard(
                number: 4,
                title: 'DATE & TIME',
                children: [
                  _label('DATE (YYYY-MM-DD)', required: true),
                  GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        border: Border.all(color: _eventDate == null ? AppTheme.divider : AppTheme.accent),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today_outlined, size: 16, color: _eventDate != null ? AppTheme.accent : AppTheme.textSecondary),
                          const SizedBox(width: 10),
                          Text(
                            _eventDate != null ? dateFmt.format(_eventDate!) : 'Select date',
                            style: TextStyle(
                              fontSize: 14,
                              color: _eventDate != null ? AppTheme.textPrimary : AppTheme.textSecondary,
                              fontWeight: _eventDate != null ? FontWeight.w500 : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (_isHiTea) ...[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label('TIME – HI-TEA'),
                              TextFormField(
                                controller: _hiTeaTimeCtrl,
                                decoration: const InputDecoration(hintText: 'HH:MM'),
                                keyboardType: TextInputType.datetime,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      if (_isBuffet)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label('TIME – BUFFET'),
                              TextFormField(
                                controller: _buffetTimeCtrl,
                                decoration: const InputDecoration(hintText: 'HH:MM'),
                                keyboardType: TextInputType.datetime,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),

              // Section 5 – Approver Route
              _sectionCard(
                number: 5,
                title: 'APPROVER ROUTE',
                children: [
                  _label('SELECT APPROVER – GM AND ABOVE', required: true),
                  DropdownButtonFormField<String>(
                    value: _approver,
                    decoration: const InputDecoration(hintText: 'Select an option'),
                    items: _approverOptions.map((a) => DropdownMenuItem(value: a, child: Text(a, style: const TextStyle(fontSize: 13)))).toList(),
                    onChanged: (v) => setState(() => _approver = v),
                    validator: (v) => v == null ? 'Approver is required' : null,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFFE082)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Rules:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.warning)),
                        const SizedBox(height: 4),
                        ...[
                          'Approver selection is mandatory',
                          'Must be GM and above rank',
                          'If HOD below GM, CGM/ED must be selected',
                        ].map((r) => Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('• ', style: TextStyle(fontSize: 11, color: AppTheme.warning)),
                                  Expanded(child: Text(r, style: const TextStyle(fontSize: 11, color: AppTheme.textPrimary))),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),
                ],
              ),

              // Booking notes
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.chipBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFBBD6F8)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Important Notes', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.accent, letterSpacing: 0.5)),
                    const SizedBox(height: 6),
                    ...[
                      'Booking time to be as per office timings and restricted till 07:00 PM.',
                      'Same day catering requisition may be open for 4 hrs before.',
                      'Booking will not be accepted through app in case of urgency.',
                    ].map((n) => Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('→ ', style: TextStyle(fontSize: 11, color: AppTheme.accent, fontWeight: FontWeight.w700)),
                              Expanded(child: Text(n, style: const TextStyle(fontSize: 11, color: AppTheme.textPrimary))),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  child: const Text('Submit Request'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _meetingCtrl.dispose();
    _presidingCtrl.dispose();
    _hiTeaTimeCtrl.dispose();
    _buffetTimeCtrl.dispose();
    for (final c in _packedItemCtrls) { c.dispose(); }
    _scrollController.dispose();
    super.dispose();
  }
}
