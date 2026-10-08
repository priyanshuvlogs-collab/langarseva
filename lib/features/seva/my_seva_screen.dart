import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../widgets/common.dart';
import 'seva_repository.dart';
import 'seva_section.dart';

class MySevaScreen extends ConsumerWidget {
  const MySevaScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final slots = ref.watch(mySevaProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.mySeva)),
      body: slots.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => ErrorRetry(onRetry: () => ref.invalidate(mySevaProvider)),
        data: (items) => items.isEmpty
            ? EmptyState(icon: Icons.volunteer_activism_outlined, message: l.noSeva)
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [for (final s in items) SevaSlotCard(slot: s, joined: true, showLangar: true)],
              ),
      ),
    );
  }
}
