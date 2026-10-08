import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';
import '../../widgets/common.dart';
import '../langars/data/langar.dart';

Future<void> showDonateSheet(BuildContext context, Langar langar) {
  return showModalBottomSheet(
    context: context,
    showDragHandle: true,
    builder: (ctx) => _DonateSheet(langar: langar),
  );
}

class _DonateSheet extends StatelessWidget {
  const _DonateSheet({required this.langar});
  final Langar langar;

  Uri _upiUri() => Uri(
        scheme: 'upi',
        host: 'pay',
        queryParameters: {'pa': langar.donateUpiId!, 'pn': langar.name, 'cu': 'INR', 'tn': 'Langar seva donation'},
      );

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.donateTitle, style: theme.textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(langar.name, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline)),
            const SizedBox(height: 16),
            if (!langar.hasDonation) Text(l.noDonateInfo),
            if (langar.donateUpiId?.isNotEmpty ?? false) ...[
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.account_balance_wallet_outlined),
                title: Text(l.donateUpiId),
                subtitle: SelectableText(langar.donateUpiId!),
                trailing: IconButton(
                  tooltip: l.copyUpi,
                  icon: const Icon(Icons.copy),
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: langar.donateUpiId!));
                    if (context.mounted) showSnack(context, l.copied);
                  },
                ),
              ),
              FilledButton.icon(
                onPressed: () async {
                  final uri = _upiUri();
                  final ok = await canLaunchUrl(uri) && await launchUrl(uri, mode: LaunchMode.externalApplication);
                  if (!ok && context.mounted) showSnack(context, l.noUpiApp);
                },
                icon: const Icon(Icons.payments_outlined),
                label: Text(l.openUpiApp),
              ),
            ],
            if (langar.donateUrl?.isNotEmpty ?? false) ...[
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => launchUrl(Uri.parse(langar.donateUrl!), mode: LaunchMode.externalApplication),
                icon: const Icon(Icons.open_in_new),
                label: Text(l.donateWebsite),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
