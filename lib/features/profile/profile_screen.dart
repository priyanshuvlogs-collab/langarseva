import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/env.dart';
import '../../core/locale_controller.dart';
import '../../core/supabase_client.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/common.dart';
import '../auth/auth_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _deleteAccount(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.deleteAccount),
        content: Text(l.deleteAccountConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.cancel)),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(ctx).colorScheme.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.delete),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(authControllerProvider).deleteAccount();
      if (context.mounted) {
        showSnack(context, l.accountDeleted);
        context.go('/');
      }
    } catch (_) {
      if (context.mounted) showSnack(context, l.errorGeneric);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider);
    final profile = ref.watch(profileProvider).valueOrNull;
    final isAdmin = ref.watch(isAdminProvider);
    final locale = ref.watch(localeProvider);
    final name = profile?['display_name'] as String? ?? user?.phone ?? user?.email ?? l.guest;

    return Scaffold(
      appBar: AppBar(title: Text(l.profile)),
      body: ListView(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Icon(user == null ? Icons.person_outline : Icons.person, color: theme.colorScheme.onPrimaryContainer),
            ),
            title: Text(name, style: theme.textTheme.titleMedium),
            subtitle: user == null ? Text(l.loginSubtitle) : null,
            trailing: user == null ? FilledButton(onPressed: () => context.push('/login'), child: Text(l.login)) : null,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(l.language),
            trailing: DropdownButton<String>(
              value: locale?.languageCode ?? Localizations.localeOf(context).languageCode,
              underline: const SizedBox(),
              items: [for (final e in localeNames.entries) DropdownMenuItem(value: e.key, child: Text(e.value))],
              onChanged: (v) => v == null ? null : ref.read(localeProvider.notifier).set(Locale(v)),
            ),
          ),
          if (user != null) ...[
            ListTile(leading: const Icon(Icons.favorite_border), title: Text(l.favourites), trailing: const Icon(Icons.chevron_right), onTap: () => context.push('/profile/favourites')),
            ListTile(leading: const Icon(Icons.volunteer_activism_outlined), title: Text(l.mySeva), trailing: const Icon(Icons.chevron_right), onTap: () => context.push('/profile/seva')),
            ListTile(leading: const Icon(Icons.add_location_alt_outlined), title: Text(l.mySubmissions), trailing: const Icon(Icons.chevron_right), onTap: () => context.push('/profile/submissions')),
            if (isAdmin)
              ListTile(leading: const Icon(Icons.admin_panel_settings_outlined), title: Text(l.admin), subtitle: Text(l.pendingApprovals), trailing: const Icon(Icons.chevron_right), onTap: () => context.push('/admin')),
          ],
          const Divider(),
          ListTile(leading: const Icon(Icons.privacy_tip_outlined), title: Text(l.privacyPolicy), onTap: () => launchUrl(Uri.parse(Env.privacyUrl), mode: LaunchMode.externalApplication)),
          ListTile(leading: const Icon(Icons.description_outlined), title: Text(l.terms), onTap: () => launchUrl(Uri.parse(Env.termsUrl), mode: LaunchMode.externalApplication)),
          if (user != null) ...[
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: Text(l.signOut),
              onTap: () async {
                await ref.read(authControllerProvider).signOut();
                if (context.mounted) context.go('/');
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_forever_outlined, color: theme.colorScheme.error),
              title: Text(l.deleteAccount, style: TextStyle(color: theme.colorScheme.error)),
              onTap: () => _deleteAccount(context, ref),
            ),
          ],
          const SizedBox(height: 24),
          Center(child: Text('LangarSeva v1.0.0', style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline))),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
