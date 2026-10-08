import 'package:flutter/material.dart';

import '../../../widgets/common.dart';
import '../data/langar.dart';

class LangarListTile extends StatelessWidget {
  const LangarListTile({super.key, required this.langar, this.onTap, this.onLongPress, this.trailing});
  final Langar langar;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      onTap: onTap,
      onLongPress: onLongPress,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: LangarPhoto(url: langar.photos.isEmpty ? null : langar.photos.first, size: 56),
      title: Text(langar.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.titleSmall),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (langar.shortAddress.isNotEmpty)
            Text(langar.shortAddress, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall),
          const SizedBox(height: 4),
          Row(
            children: [
              if (langar.isOpen != null) ...[OpenBadge(isOpen: langar.isOpen!, compact: true), const SizedBox(width: 8)],
              if (langar.distanceM != null)
                Text(distanceLabel(context, langar.distanceM!), style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.primary)),
            ],
          ),
        ],
      ),
      trailing: trailing ?? const Icon(Icons.chevron_right),
    );
  }
}
