import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../widgets/common.dart';
import '../langars/data/langar.dart';
import '../langars/data/langar_repository.dart';
import '../langars/presentation/langar_list_tile.dart';

class MySubmissionsScreen extends ConsumerWidget {
  const MySubmissionsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final items = ref.watch(mySubmissionsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.mySubmissions)),
      body: items.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => ErrorRetry(onRetry: () => ref.invalidate(mySubmissionsProvider)),
        data: (list) => list.isEmpty
            ? EmptyState(
                icon: Icons.add_location_alt_outlined,
                message: l.noSubmissions,
                action: FilledButton.tonal(onPressed: () => context.push('/add'), child: Text(l.addLangar)),
              )
            : ListView.separated(
                itemCount: list.length,
                separatorBuilder: (_, __) => const Divider(height: 1, indent: 88),
                itemBuilder: (_, i) => LangarListTile(
                  langar: list[i],
                  onTap: () => context.push('/langar/${list[i].id}'),
                  trailing: StatusChip(status: list[i].status),
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(onPressed: () => context.push('/add'), child: const Icon(Icons.add)),
    );
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});
  final LangarStatus status;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final (label, color) = switch (status) {
      LangarStatus.approved => (l.statusApproved, Colors.green),
      LangarStatus.rejected => (l.statusRejected, Theme.of(context).colorScheme.error),
      LangarStatus.pending => (l.statusPending, Colors.orange),
    };
    return Chip(
      label: Text(label, style: TextStyle(color: color, fontSize: 12)),
      side: BorderSide(color: color),
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
    );
  }
}
