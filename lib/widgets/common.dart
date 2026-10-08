import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../core/distance.dart';
import '../l10n/app_localizations.dart';

class OpenBadge extends StatelessWidget {
  const OpenBadge({super.key, required this.isOpen, this.compact = false});
  final bool isOpen;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final color = isOpen ? Colors.green.shade700 : Theme.of(context).colorScheme.error;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 6 : 10, vertical: compact ? 2 : 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 8, color: color),
          const SizedBox(width: 4),
          Text(isOpen ? l.open : l.closed,
              style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: compact ? 12 : 13)),
        ],
      ),
    );
  }
}

String distanceLabel(BuildContext context, double metres) {
  final l = AppLocalizations.of(context);
  final d = formatDistance(metres);
  return d.isKm ? l.kmAway(d.value) : l.mAway(int.parse(d.value));
}

class LangarPhoto extends StatelessWidget {
  const LangarPhoto({super.key, this.url, this.size, this.fit = BoxFit.cover, this.borderRadius});
  final String? url;
  final double? size;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final placeholder = Container(
      width: size,
      height: size,
      color: scheme.primaryContainer,
      child: Icon(Icons.restaurant_rounded, color: scheme.onPrimaryContainer, size: (size ?? 80) * 0.4),
    );
    final child = (url == null || url!.isEmpty)
        ? placeholder
        : CachedNetworkImage(
            imageUrl: url!,
            width: size,
            height: size,
            fit: fit,
            placeholder: (_, __) => placeholder,
            errorWidget: (_, __, ___) => placeholder,
          );
    return ClipRRect(borderRadius: borderRadius ?? BorderRadius.circular(12), child: child);
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.message, this.action});
  final IconData icon;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge),
            if (action != null) ...[const SizedBox(height: 16), action!],
          ],
        ),
      ),
    );
  }
}

class ErrorRetry extends StatelessWidget {
  const ErrorRetry({super.key, required this.onRetry, this.message});
  final VoidCallback onRetry;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return EmptyState(
      icon: Icons.cloud_off_outlined,
      message: message ?? l.errorGeneric,
      action: OutlinedButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh), label: Text(l.retry)),
    );
  }
}

void showSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
