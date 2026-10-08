import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/env.dart';
import '../../../core/open_now.dart';
import '../../../core/supabase_client.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/common.dart';
import '../../auth/auth_controller.dart';
import '../../donate/donate_sheet.dart';
import '../../seva/seva_section.dart';
import '../data/langar.dart';
import '../data/langar_repository.dart';

class LangarDetailScreen extends ConsumerWidget {
  const LangarDetailScreen({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final langar = ref.watch(langarByIdProvider(id));
    return langar.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(appBar: AppBar(), body: ErrorRetry(onRetry: () => ref.invalidate(langarByIdProvider(id)))),
      data: (x) => x == null
          ? Scaffold(appBar: AppBar(), body: EmptyState(icon: Icons.search_off, message: l.noLangarsFound))
          : _Body(langar: x),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.langar});
  final Langar langar;

  Future<void> _directions() async {
    final lat = langar.lat, lng = langar.lng;
    final label = Uri.encodeComponent(langar.name);
    final candidates = <Uri>[
      if (Platform.isIOS) Uri.parse('comgooglemaps://?daddr=$lat,$lng&directionsmode=driving'),
      if (Platform.isIOS) Uri.parse('https://maps.apple.com/?daddr=$lat,$lng&q=$label'),
      if (Platform.isAndroid) Uri.parse('google.navigation:q=$lat,$lng'),
      Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng'),
    ];
    for (final u in candidates) {
      if (await canLaunchUrl(u)) {
        await launchUrl(u, mode: LaunchMode.externalApplication);
        return;
      }
    }
    await launchUrl(candidates.last, mode: LaunchMode.externalApplication);
  }

  Future<void> _call() => launchUrl(Uri(scheme: 'tel', path: langar.contactPhone));

  Future<void> _share(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SharePlus.instance.share(ShareParams(text: l.shareText(langar.name, Env.langarShareUrl(langar.id))));
  }

  Future<void> _toggleFavourite(BuildContext context, WidgetRef ref) async {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      context.push('/login?next=${Uri.encodeComponent('/langar/${langar.id}')}');
      return;
    }
    final l = AppLocalizations.of(context);
    final repo = ref.read(langarRepositoryProvider);
    final ids = ref.read(favouriteIdsProvider).valueOrNull ?? {};
    try {
      if (ids.contains(langar.id)) {
        await repo.removeFavourite(user.id, langar.id);
        if (context.mounted) showSnack(context, l.favouriteRemoved);
      } else {
        await repo.addFavourite(user.id, langar.id);
        if (context.mounted) showSnack(context, l.favouriteAdded);
      }
      ref.invalidate(favouriteIdsProvider);
      ref.invalidate(favouritesProvider);
    } catch (_) {
      if (context.mounted) showSnack(context, l.errorGeneric);
    }
  }

  Future<void> _report(BuildContext context, WidgetRef ref) async {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      context.push('/login?next=${Uri.encodeComponent('/langar/${langar.id}')}');
      return;
    }
    final l = AppLocalizations.of(context);
    final ctrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.report),
        content: TextField(controller: ctrl, maxLines: 3, decoration: InputDecoration(hintText: l.reportReasonHint)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.cancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l.report)),
        ],
      ),
    );
    if (ok == true && ctrl.text.trim().isNotEmpty) {
      try {
        await ref.read(langarRepositoryProvider).report(user.id, langar.id, ctrl.text.trim());
        if (context.mounted) showSnack(context, l.reportSent);
      } catch (_) {
        if (context.mounted) showSnack(context, l.errorGeneric);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final timings = ref.watch(langarTimingsProvider(langar.id));
    final favIds = ref.watch(favouriteIdsProvider).valueOrNull ?? {};
    final isFav = favIds.contains(langar.id);
    final user = ref.watch(currentUserProvider);
    final isOwner = user != null && (user.id == langar.submittedBy || ref.watch(isAdminProvider));
    final isOpen = timings.valueOrNull == null ? langar.isOpen : isOpenNow(timings.value!);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            actions: [
              IconButton(
                icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: isFav ? Colors.red : null),
                onPressed: () => _toggleFavourite(context, ref),
              ),
              IconButton(icon: const Icon(Icons.share_outlined), onPressed: () => _share(context)),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: langar.photos.isEmpty
                  ? LangarPhoto(url: null, borderRadius: BorderRadius.zero)
                  : PageView(
                      children: [for (final p in langar.photos) LangarPhoto(url: p, borderRadius: BorderRadius.zero)],
                    ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList.list(
              children: [
                Text(langar.name, style: theme.textTheme.headlineSmall),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (isOpen != null) OpenBadge(isOpen: isOpen),
                    if (langar.distanceM != null)
                      Text(distanceLabel(context, langar.distanceM!), style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary)),
                    if (langar.status != LangarStatus.approved)
                      Chip(
                        label: Text(switch (langar.status) {
                          LangarStatus.pending => l.statusPending,
                          LangarStatus.rejected => l.statusRejected,
                          LangarStatus.approved => l.statusApproved,
                        }),
                        visualDensity: VisualDensity.compact,
                      ),
                  ],
                ),
                if (langar.shortAddress.isNotEmpty || (langar.state?.isNotEmpty ?? false)) ...[
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.place_outlined, size: 20),
                      const SizedBox(width: 8),
                      Expanded(child: Text([langar.address, langar.city, langar.state].where((e) => e != null && e.isNotEmpty).join(', '))),
                    ],
                  ),
                ],
                if (langar.description?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 12),
                  Text(langar.description!, style: theme.textTheme.bodyMedium),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: FilledButton.icon(onPressed: _directions, icon: const Icon(Icons.directions), label: Text(l.directions))),
                    const SizedBox(width: 8),
                    if (langar.contactPhone?.isNotEmpty ?? false) ...[
                      Expanded(child: OutlinedButton.icon(onPressed: _call, icon: const Icon(Icons.call), label: Text(l.call))),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => showDonateSheet(context, langar),
                        icon: const Icon(Icons.volunteer_activism_outlined),
                        label: Text(l.donate),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(l.timings, style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                timings.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (_, __) => Text(l.errorGeneric),
                  data: (t) => _TimingsTable(timings: t),
                ),
                const SizedBox(height: 24),
                SevaSection(langar: langar, canManage: isOwner),
                const SizedBox(height: 24),
                Center(
                  child: TextButton.icon(
                    onPressed: () => _report(context, ref),
                    icon: const Icon(Icons.flag_outlined, size: 18),
                    label: Text(l.report),
                    style: TextButton.styleFrom(foregroundColor: theme.colorScheme.outline),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimingsTable extends StatelessWidget {
  const _TimingsTable({required this.timings});
  final List<LangarTiming> timings;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (timings.isEmpty) return Text(l.noTimings, style: TextStyle(color: Theme.of(context).colorScheme.outline));
    final todayDow = pgDow(nowInIst());
    final names = [l.weekday7, l.weekday1, l.weekday2, l.weekday3, l.weekday4, l.weekday5, l.weekday6]; // index = pg dow
    // Order Mon..Sun for display.
    final order = [1, 2, 3, 4, 5, 6, 0];
    return Card(
      child: Column(
        children: [
          for (final dow in order)
            _row(context, names[dow], timings.where((t) => t.dayOfWeek == dow).toList(), dow == todayDow, l),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String day, List<LangarTiming> rows, bool isToday, AppLocalizations l) {
    final theme = Theme.of(context);
    final style = isToday ? theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700, color: theme.colorScheme.primary) : theme.textTheme.bodyMedium;
    final text = rows.isEmpty
        ? l.closedToday
        : rows.any((r) => r.is24h)
            ? l.open24h
            : rows.map((r) => '${_fmt(context, r.opensAt)} – ${_fmt(context, r.closesAt)}').join(', ');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          SizedBox(width: 56, child: Text(day, style: style)),
          if (isToday) ...[Text('• ${l.today}', style: style?.copyWith(fontSize: 12)), const SizedBox(width: 8)],
          Expanded(child: Text(text, style: style, textAlign: TextAlign.end)),
        ],
      ),
    );
  }

  String _fmt(BuildContext context, TimeOfDay? t) => t == null ? '' : MaterialLocalizations.of(context).formatTimeOfDay(t);
}
