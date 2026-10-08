import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/supabase_client.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/common.dart';
import '../langars/data/langar.dart';
import 'seva_repository.dart';

class SevaSection extends ConsumerWidget {
  const SevaSection({super.key, required this.langar, this.canManage = false});
  final Langar langar;
  final bool canManage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final slots = ref.watch(sevaSlotsProvider(langar.id));
    final mine = ref.watch(mySlotIdsProvider).valueOrNull ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(l.sevaTitle, style: theme.textTheme.titleMedium)),
            if (canManage)
              TextButton.icon(
                onPressed: () => showCreateSlotDialog(context, ref, langar.id),
                icon: const Icon(Icons.add, size: 18),
                label: Text(l.sevaCreateSlot),
              ),
          ],
        ),
        const SizedBox(height: 8),
        slots.when(
          loading: () => const LinearProgressIndicator(),
          error: (_, __) => ErrorRetry(onRetry: () => ref.invalidate(sevaSlotsProvider(langar.id))),
          data: (items) => items.isEmpty
              ? Text(l.sevaNoSlots, style: TextStyle(color: theme.colorScheme.outline))
              : Column(children: [for (final s in items) SevaSlotCard(slot: s, joined: mine.contains(s.id))]),
        ),
      ],
    );
  }
}

class SevaSlotCard extends ConsumerWidget {
  const SevaSlotCard({super.key, required this.slot, required this.joined, this.showLangar = false});
  final SevaSlot slot;
  final bool joined;
  final bool showLangar;

  Future<void> _toggle(BuildContext context, WidgetRef ref) async {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      context.push('/login?next=${Uri.encodeComponent('/langar/${slot.langarId}')}');
      return;
    }
    final l = AppLocalizations.of(context);
    final repo = ref.read(sevaRepositoryProvider);
    try {
      if (joined) {
        await repo.leave(user.id, slot.id);
      } else {
        await repo.join(user.id, slot.id);
        if (context.mounted) showSnack(context, l.sevaJoined);
      }
      ref.invalidate(mySlotIdsProvider);
      ref.invalidate(mySevaProvider);
      ref.invalidate(sevaSlotsProvider(slot.langarId));
    } catch (_) {
      if (context.mounted) showSnack(context, l.errorGeneric);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final date = DateFormat.MMMEd(locale).format(slot.startsAt);
    final time = '${DateFormat.jm(locale).format(slot.startsAt)} – ${DateFormat.jm(locale).format(slot.endsAt)}';
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showLangar && slot.langarName != null)
                    Text(slot.langarName!, style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.primary)),
                  Text(slot.title, style: theme.textTheme.titleSmall),
                  const SizedBox(height: 2),
                  Text('$date · $time', style: theme.textTheme.bodySmall),
                  if (slot.description?.isNotEmpty ?? false) Text(slot.description!, style: theme.textTheme.bodySmall),
                  const SizedBox(height: 4),
                  Text(
                    '${l.volunteersJoined(slot.joined)} · ${l.sevaSpots(slot.spotsLeft)}',
                    style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            joined
                ? OutlinedButton(onPressed: () => _toggle(context, ref), child: Text(l.sevaLeave))
                : FilledButton.tonal(
                    onPressed: slot.isFull ? null : () => _toggle(context, ref),
                    child: Text(slot.isFull ? l.sevaFull : l.sevaJoin),
                  ),
          ],
        ),
      ),
    );
  }
}

Future<void> showCreateSlotDialog(BuildContext context, WidgetRef ref, String langarId) async {
  final l = AppLocalizations.of(context);
  final title = TextEditingController();
  final capacity = TextEditingController(text: '10');
  var start = DateTime.now().add(const Duration(days: 1)).copyWith(hour: 9, minute: 0, second: 0, millisecond: 0, microsecond: 0);
  var end = start.add(const Duration(hours: 3));

  Future<DateTime?> pick(BuildContext ctx, DateTime initial) async {
    final d = await showDatePicker(context: ctx, initialDate: initial, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
    if (d == null || !ctx.mounted) return null;
    final t = await showTimePicker(context: ctx, initialTime: TimeOfDay.fromDateTime(initial));
    if (t == null) return null;
    return DateTime(d.year, d.month, d.day, t.hour, t.minute);
  }

  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) {
        final locale = Localizations.localeOf(ctx).toString();
        final fmt = DateFormat.MMMEd(locale).add_jm();
        return AlertDialog(
          title: Text(l.sevaCreateSlot),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: title, decoration: InputDecoration(labelText: l.slotTitle), onChanged: (_) => setState(() {})),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l.startsAt),
                  subtitle: Text(fmt.format(start)),
                  trailing: const Icon(Icons.edit_calendar_outlined),
                  onTap: () async {
                    final v = await pick(ctx, start);
                    if (v != null) setState(() { start = v; if (!end.isAfter(start)) end = start.add(const Duration(hours: 2)); });
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l.endsAt),
                  subtitle: Text(fmt.format(end)),
                  trailing: const Icon(Icons.edit_calendar_outlined),
                  onTap: () async {
                    final v = await pick(ctx, end);
                    if (v != null && v.isAfter(start)) setState(() => end = v);
                  },
                ),
                TextField(controller: capacity, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: l.capacity)),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.cancel)),
            FilledButton(onPressed: title.text.trim().isEmpty ? null : () => Navigator.pop(ctx, true), child: Text(l.save)),
          ],
        );
      },
    ),
  );
  final titleText = title.text.trim();
  final capacityValue = int.tryParse(capacity.text) ?? 10;
  title.dispose();
  capacity.dispose();
  if (ok != true) return;
  try {
    await ref.read(sevaRepositoryProvider).createSlot(
          langarId: langarId,
          title: titleText,
          startsAt: start,
          endsAt: end,
          capacity: capacityValue,
        );
    ref.invalidate(sevaSlotsProvider(langarId));
    if (context.mounted) showSnack(context, l.createdSlot);
  } catch (_) {
    if (context.mounted) showSnack(context, l.errorGeneric);
  }
}
