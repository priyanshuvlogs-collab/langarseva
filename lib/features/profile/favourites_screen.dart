import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../widgets/common.dart';
import '../langars/data/langar_repository.dart';
import '../langars/presentation/langar_list_tile.dart';

class FavouritesScreen extends ConsumerWidget {
  const FavouritesScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final favs = ref.watch(favouritesProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.favourites)),
      body: favs.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => ErrorRetry(onRetry: () => ref.invalidate(favouritesProvider)),
        data: (items) => items.isEmpty
            ? EmptyState(icon: Icons.favorite_border, message: l.noFavourites)
            : ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, __) => const Divider(height: 1, indent: 88),
                itemBuilder: (_, i) => LangarListTile(langar: items[i], onTap: () => context.push('/langar/${items[i].id}')),
              ),
      ),
    );
  }
}
