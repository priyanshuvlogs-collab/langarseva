import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/connectivity.dart';
import '../../../core/location_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/common.dart';
import '../data/langar.dart';
import '../data/langar_repository.dart';
import 'langar_list_tile.dart';

class LangarFilters {
  const LangarFilters({this.openNow = false, this.radiusM = 25000});
  final bool openNow;
  final double radiusM;
  LangarFilters copyWith({bool? openNow, double? radiusM}) =>
      LangarFilters(openNow: openNow ?? this.openNow, radiusM: radiusM ?? this.radiusM);
}

final filtersProvider = StateProvider<LangarFilters>((ref) => const LangarFilters());

final nearbyLangarsProvider = FutureProvider<List<Langar>>((ref) async {
  final locAsync = ref.watch(locationProvider);
  final f = ref.watch(filtersProvider);
  // While the location is still resolving, stay in the loading state instead of
  // flashing the "no langars" empty state. This future is abandoned when the
  // location provider updates and this provider rebuilds.
  if (locAsync.isLoading) return Completer<List<Langar>>().future;
  final loc = locAsync.valueOrNull;
  if (loc == null) return const [];
  return ref.watch(langarRepositoryProvider).nearby(lat: loc.lat, lng: loc.lng, radiusM: f.radiusM, openNow: f.openNow);
});

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  GoogleMapController? _map;
  final _search = TextEditingController();
  bool _searching = false;
  bool _showList = true;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _onSearch(String q) async {
    if (q.trim().isEmpty) return;
    setState(() => _searching = true);
    final ok = await ref.read(locationProvider.notifier).searchPlace(q.trim());
    if (!mounted) return;
    setState(() => _searching = false);
    if (!ok) showSnack(context, AppLocalizations.of(context).cityNotFound);
  }

  void _recentre(UserLocation loc) {
    _map?.animateCamera(CameraUpdate.newLatLngZoom(LatLng(loc.lat, loc.lng), 12));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final loc = ref.watch(locationProvider);
    final langars = ref.watch(nearbyLangarsProvider);
    final filters = ref.watch(filtersProvider);
    final offline = ref.watch(isOfflineProvider).valueOrNull ?? false;

    ref.listen(locationProvider, (_, next) {
      final v = next.valueOrNull;
      if (v != null) _recentre(v);
    });

    final centre = loc.valueOrNull;
    final markers = <Marker>{
      for (final x in langars.valueOrNull ?? const <Langar>[])
        Marker(
          markerId: MarkerId(x.id),
          position: LatLng(x.lat, x.lng),
          infoWindow: InfoWindow(title: x.name, snippet: x.city, onTap: () => context.push('/langar/${x.id}')),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            (x.isOpen ?? false) ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueOrange,
          ),
        ),
    };

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(centre?.lat ?? fallbackLat, centre?.lng ?? fallbackLng),
                zoom: 12,
              ),
              onMapCreated: (c) => _map = c,
              markers: markers,
              myLocationEnabled: !(centre?.isFallback ?? true),
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              padding: EdgeInsets.only(bottom: _showList ? MediaQuery.sizeOf(context).height * 0.35 : 0),
            ),
          ),
          // Top bar: search + profile
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Material(
                          elevation: 3,
                          borderRadius: BorderRadius.circular(28),
                          child: TextField(
                            controller: _search,
                            textInputAction: TextInputAction.search,
                            onSubmitted: _onSearch,
                            decoration: InputDecoration(
                              hintText: l.searchCityHint,
                              prefixIcon: const Icon(Icons.search),
                              suffixIcon: _searching
                                  ? const Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2))
                                  : IconButton(
                                      tooltip: l.useMyLocation,
                                      icon: const Icon(Icons.my_location),
                                      onPressed: () {
                                        _search.clear();
                                        ref.read(locationProvider.notifier).refresh();
                                      },
                                    ),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: BorderSide.none),
                              filled: true,
                              fillColor: Theme.of(context).colorScheme.surface,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Material(
                        elevation: 3,
                        shape: const CircleBorder(),
                        color: Theme.of(context).colorScheme.surface,
                        child: IconButton(
                          tooltip: l.profile,
                          icon: const Icon(Icons.person_outline),
                          onPressed: () => context.push('/profile'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        FilterChip(
                          label: Text(l.openNow),
                          selected: filters.openNow,
                          avatar: Icon(Icons.schedule, size: 16, color: filters.openNow ? Colors.green.shade800 : null),
                          onSelected: (v) => ref.read(filtersProvider.notifier).state = filters.copyWith(openNow: v),
                        ),
                        const SizedBox(width: 8),
                        for (final (label, r) in [(l.within5km, 5000.0), (l.within25km, 25000.0), (l.within100km, 100000.0)]) ...[
                          ChoiceChip(
                            label: Text(label),
                            selected: filters.radiusM == r,
                            onSelected: (_) => ref.read(filtersProvider.notifier).state = filters.copyWith(radiusM: r),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ],
                    ),
                  ),
                  if (offline) _Banner(text: l.offline, icon: Icons.wifi_off),
                  if (centre != null && centre.isFallback && centre.label == null && centre.failure != LocationFailure.none)
                    _Banner(
                      text: switch (centre.failure) {
                        LocationFailure.serviceOff => l.locationServiceOff,
                        LocationFailure.timeout => l.locationTimeout,
                        _ => l.locationPermissionDenied,
                      },
                      icon: Icons.location_off_outlined,
                      action: switch (centre.failure) {
                        LocationFailure.timeout => TextButton(
                            onPressed: () => ref.read(locationProvider.notifier).refresh(),
                            child: Text(l.retry),
                          ),
                        LocationFailure.serviceOff => TextButton(
                            onPressed: () => ref.read(locationProvider.notifier).openLocationSettings(),
                            child: Text(l.enableLocation),
                          ),
                        _ => TextButton(
                            onPressed: () => ref.read(locationProvider.notifier).openSettings(),
                            child: Text(l.enableLocation),
                          ),
                      },
                    ),
                ],
              ),
            ),
          ),
          // Bottom list sheet
          if (_showList)
            DraggableScrollableSheet(
              initialChildSize: 0.38,
              minChildSize: 0.12,
              maxChildSize: 0.9,
              snap: true,
              builder: (context, scroll) => Material(
                elevation: 8,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                color: Theme.of(context).colorScheme.surface,
                child: CustomScrollView(
                  controller: scroll,
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          const SizedBox(height: 8),
                          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(2))),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    centre?.label != null ? '${l.nearby}: ${centre!.label}' : l.nearYou,
                                    style: Theme.of(context).textTheme.titleMedium,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (langars.valueOrNull != null)
                                  Text('${langars.value!.length}', style: Theme.of(context).textTheme.labelLarge),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    langars.when(
                      loading: () => const SliverFillRemaining(hasScrollBody: false, child: Center(child: CircularProgressIndicator())),
                      error: (e, _) => SliverFillRemaining(
                        hasScrollBody: false,
                        child: ErrorRetry(onRetry: () => ref.invalidate(nearbyLangarsProvider)),
                      ),
                      data: (items) => items.isEmpty
                          ? SliverFillRemaining(
                              hasScrollBody: false,
                              child: EmptyState(
                                icon: Icons.restaurant_outlined,
                                message: l.noLangarsFound,
                                action: FilledButton.tonalIcon(
                                  onPressed: () => context.push('/add'),
                                  icon: const Icon(Icons.add_location_alt_outlined),
                                  label: Text(l.addLangar),
                                ),
                              ),
                            )
                          : SliverList.separated(
                              itemCount: items.length,
                              separatorBuilder: (_, __) => const Divider(height: 1, indent: 88),
                              itemBuilder: (_, i) => LangarListTile(
                                langar: items[i],
                                onTap: () => context.push('/langar/${items[i].id}'),
                                onLongPress: () =>
                                    _map?.animateCamera(CameraUpdate.newLatLngZoom(LatLng(items[i].lat, items[i].lng), 15)),
                              ),
                            ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 96)),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'toggle',
            tooltip: _showList ? l.viewMap : l.viewList,
            onPressed: () => setState(() => _showList = !_showList),
            child: Icon(_showList ? Icons.map_outlined : Icons.view_list_outlined),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.extended(
            heroTag: 'add',
            onPressed: () => context.push('/add'),
            icon: const Icon(Icons.add_location_alt_outlined),
            label: Text(l.addLangar),
          ),
        ],
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.text, required this.icon, this.action});
  final String text;
  final IconData icon;
  final Widget? action;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: scheme.secondaryContainer, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, size: 18, color: scheme.onSecondaryContainer),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(color: scheme.onSecondaryContainer, fontSize: 13))),
          if (action != null) action!,
        ],
      ),
    );
  }
}
