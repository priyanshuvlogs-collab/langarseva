import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/supabase_client.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/common.dart';
import 'auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key, this.next});
  final String? next;
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phone = TextEditingController(text: '+91');
  final _otp = TextEditingController();
  bool _otpSent = false;
  bool _busy = false;

  @override
  void dispose() {
    _phone.dispose();
    _otp.dispose();
    super.dispose();
  }

  String get _normalizedPhone => _phone.text.replaceAll(RegExp(r'[\s\-()]'), '');

  Future<void> _run(Future<void> Function() fn) async {
    final l = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      await fn();
    } on AuthException catch (e) {
      if (mounted) showSnack(context, e.message);
    } catch (_) {
      if (mounted) showSnack(context, l.errorGeneric);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _done() {
    if (!mounted) return;
    final next = widget.next;
    if (context.canPop()) {
      // Login was pushed on top of the page that needed it: just return there.
      context.pop();
      return;
    }
    // Arrived via redirect (deep link or cold start): rebuild a stack of Home -> next.
    context.go('/');
    if (next != null && next.isNotEmpty && next != '/') context.push(next);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final auth = ref.read(authControllerProvider);
    final validPhone = RegExp(r'^\+\d{8,15}$').hasMatch(_normalizedPhone);

    return Scaffold(
      appBar: AppBar(title: Text(l.login)),
      body: AbsorbPointer(
        absorbing: _busy,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Icon(Icons.volunteer_activism, size: 64, color: theme.colorScheme.primary),
            const SizedBox(height: 12),
            Text(l.loginSubtitle, textAlign: TextAlign.center, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 32),
            TextField(
              controller: _phone,
              enabled: !_otpSent,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(labelText: l.phoneNumber, hintText: l.phoneHint, prefixIcon: const Icon(Icons.phone)),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            if (_otpSent) ...[
              TextField(
                controller: _otp,
                keyboardType: TextInputType.number,
                maxLength: 6,
                autofocus: true,
                decoration: InputDecoration(labelText: l.enterOtp, prefixIcon: const Icon(Icons.sms_outlined), counterText: ''),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _otp.text.length == 6
                    ? () => _run(() async {
                          await auth.verifyOtp(_normalizedPhone, _otp.text);
                          _done();
                        })
                    : null,
                child: _busy ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2)) : Text(l.verify),
              ),
              TextButton(onPressed: () => setState(() => _otpSent = false), child: Text(l.cancel)),
            ] else
              FilledButton(
                onPressed: validPhone
                    ? () => _run(() async {
                          await auth.sendOtp(_normalizedPhone);
                          if (!context.mounted) return;
                          setState(() => _otpSent = true);
                          showSnack(context, l.otpSent(_normalizedPhone));
                        })
                    : null,
                child: _busy ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2)) : Text(l.sendOtp),
              ),
            if (!validPhone && _phone.text.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(l.invalidPhone, style: TextStyle(color: theme.colorScheme.error, fontSize: 12)),
              ),
            const SizedBox(height: 24),
            Row(children: [
              const Expanded(child: Divider()),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text(l.or)),
              const Expanded(child: Divider()),
            ]),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => _run(() async {
                await auth.signInWithGoogle();
                if (ref.read(currentUserProvider) != null) _done();
              }),
              icon: const Icon(Icons.g_mobiledata, size: 28),
              label: Text(l.continueWithGoogle),
              style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            ),
            if (Platform.isIOS) ...[
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () => _run(() async {
                  await auth.signInWithApple();
                  _done();
                }),
                icon: const Icon(Icons.apple),
                label: Text(l.continueWithApple),
                style: FilledButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
