import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../widgets/common.dart';
import '../auth/auth_controller.dart';
import '../langars/data/langar.dart';
import '../langars/data/langar_repository.dart';
import '../langars/presentation/home_screen.dart';
import '../langars/presentation/langar_list_tile.dart';

class AdminScreen extends ConsumerWidget {
  const AdminScreen({super.key});

  Future<void> _decide(BuildContext context, WidgetRef ref, Langar x, LangarStatus status) async {
    final l = AppLocalizations.of(context);
    String? reason;
    if (status == LangarStatus.rejected) {
      final ctrl = TextEditingController();
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l.reject),
          content: TextField(controller: ctrl, decoration: InputDecoration(labelText: l.rejectReason), maxLines: 2),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.cancel)),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l.reject)),
          ],
        ),
      );
      if (ok != true) return;
      reason = ctrl.text.trim().isEmpty ? null : ctrl.text.trim();
    }
    try {
      await ref.read(langarRepositoryProvider).setStatus(x.id, status, reason: reason);
      ref.invalidate(pendingLangarsProvider);
      ref.invalidate(nearbyLangarsProvider);
    } catch (_) {
      if (context.mounted) showSnack(context, l.errorGeneric);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    if (!ref.watch(isAdminProvider)) {
      return Scaffold(appBar: AppBar(title: Text(l.admin)), body: EmptyState(icon: Icons.lock_outline, message: l.loginRequired));
    }
    final pending = ref.watch(pendingLangarsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.pendingApprovals)),
      body: pending.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => ErrorRetry(onRetry: () => ref.invalidate(pendingLangarsProvider)),
        data: (items) => items.isEmpty
            ? EmptyState(icon: Icons.check_circle_outline, message: l.noPending)
            : ListView.builder(
                itemCount: items.length,
                itemBuilder: (_, i) {
                  final x = items[i];
                  return Card(
                    margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                    child: Column(
                      children: [
                        LangarListTile(langar: x, onTap: () => context.push('/langar/${x.id}'), trailing: const SizedBox.shrink()),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                          child: Row(
                            children: [
                              Expanded(child: OutlinedButton.icon(onPressed: () => _decide(context, ref, x, LangarStatus.rejected), icon: const Icon(Icons.close), label: Text(l.reject))),
                              const SizedBox(width: 8),
                              Expanded(child: FilledButton.icon(onPressed: () => _decide(context, ref, x, LangarStatus.approved), icon: const Icon(Icons.check), label: Text(l.approve))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
