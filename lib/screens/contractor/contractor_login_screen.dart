import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';
import 'contractor_home_screen.dart';

// ─── Contractor Login ───────────────────────────────────────────────
// This screen is the ROOT of the Contractor app (see lib/main_contractor.dart).
// It is never pushed to from lib/main.dart's role picker — the Contractor
// module is a separate compiled app that happens to live in this same
// codebase/package, sharing models.dart, theme, and AppDataStore directly
// with the Admin/Initiator/Approver/HR app.
//
// Per spec: "Contractor Shall login externally through his portal using
// his email as ID and OTP sent to it."
class ContractorLoginScreen extends StatefulWidget {
  const ContractorLoginScreen({super.key});

  @override
  State<ContractorLoginScreen> createState() => _ContractorLoginScreenState();
}

class _ContractorLoginScreenState extends State<ContractorLoginScreen> {
  final _emailCtrl = TextEditingController(text: 'royal@caterers.in');
  final _otpCtrl = TextEditingController();
  final _store = AppDataStore();

  bool _otpSent = false;
  bool _obscure = true;

  void _sendOtp() {
    final exists = _store.contractors.any((c) =>
        c.email.toLowerCase() == _emailCtrl.text.trim().toLowerCase());
    setState(() => _otpSent = exists);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(exists ? 'OTP sent to registered email.' : 'Email not recognized as a mapped contractor.'),
        backgroundColor: exists ? AppTheme.success : AppTheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _signIn() {
    Contractor? contractor;
    try {
      contractor = _store.contractors.firstWhere(
        (c) => c.email.toLowerCase() == _emailCtrl.text.trim().toLowerCase(),
      );
    } catch (_) {
      contractor = null;
    }
    if (contractor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not verify. Check email/OTP and try again.'),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => ContractorHomeScreen(contractor: contractor!)),
    );
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _otpCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 48),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'GAIL',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.primary,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'JUBILEE TOWER · NOIDA',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                    color: Colors.white.withValues(alpha: 0.55),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Canteen\nServices.',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Contractor Portal',
                  style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.6)),
                ),
                const SizedBox(height: 28),

                // Login card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.storefront_outlined, size: 16, color: Colors.white),
                            SizedBox(width: 6),
                            Text(
                              'Contractor',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      _fieldLabel('EMAIL'),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          hintText: 'you@company.in',
                          prefixIcon: Icon(Icons.mail_outline, size: 18),
                        ),
                        onChanged: (_) => setState(() => _otpSent = false),
                      ),
                      const SizedBox(height: 16),

                      _fieldLabel('OTP'),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _otpCtrl,
                        obscureText: _obscure,
                        keyboardType: TextInputType.number,
                        enabled: _otpSent,
                        decoration: InputDecoration(
                          hintText: _otpSent ? 'Enter OTP sent to email' : 'Send OTP first',
                          prefixIcon: const Icon(Icons.lock_outline, size: 18),
                          suffixIcon: IconButton(
                            icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 18),
                            onPressed: () => setState(() => _obscure = !_obscure),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _sendOtp,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            _otpSent ? 'Resend OTP' : 'Send OTP to email',
                            style: const TextStyle(fontSize: 12, color: AppTheme.accent, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _otpSent ? _signIn : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            disabledBackgroundColor: Colors.black.withValues(alpha: 0.3),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Sign In', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward, size: 16, color: Colors.white),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    'External portal · secured with email OTP',
                    style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.45)),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppTheme.textSecondary,
          letterSpacing: 0.8,
        ),
      );
}
