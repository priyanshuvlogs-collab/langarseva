import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../langars/data/langar.dart';

/// Default: open every day 06:00 - 22:00.
List<LangarTiming> defaultTimings() => [
      for (var d = 0; d < 7; d++)
        LangarTiming(dayOfWeek: d, opensAt: const TimeOfDay(hour: 6, minute: 0), closesAt: const TimeOfDay(hour: 22, minute: 0)),
    ];

/// Per-day editor. Each day is either closed (no row), 24h, or one open/close window.
class TimingsEditor extends StatelessWidget {
  const TimingsEditor({super.key, required this.timings, required this.onChanged});
  final List<LangarTiming> timings;
  final ValueChanged<List<LangarTiming>> onChanged;

  LangarTiming? _for(int dow) => timings.where((t) => t.dayOfWeek == dow).firstOrNull;

  void _set(int dow, LangarTiming? t) {
    final next = timings.where((x) => x.dayOfWeek != dow).toList();
    if (t != null) next.add(t);
    next.sort((a, b) => a.dayOfWeek.compareTo(b.dayOfWeek));
    onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final names = [l.weekday7, l.weekday1, l.weekday2, l.weekday3, l.weekday4, l.weekday5, l.weekday6];
    const order = [1, 2, 3, 4, 5, 6, 0];
    final monday = _for(1);
    return Card(
      child: Column(
        children: [
          for (final dow in order) _DayRow(dow: dow, name: names[dow], timing: _for(dow), onChanged: (t) => _set(dow, t)),
          if (monday != null)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => onChanged([for (var d = 0; d < 7; d++) LangarTiming(dayOfWeek: d, opensAt: monday.opensAt, closesAt: monday.closesAt, is24h: monday.is24h)]),
                icon: const Icon(Icons.copy_all, size: 18),
                label: Text(l.applyToAllDays),
              ),
            ),
        ],
      ),
    );
  }
}

class _DayRow extends StatelessWidget {
  const _DayRow({required this.dow, required this.name, required this.timing, required this.onChanged});
  final int dow;
  final String name;
  final LangarTiming? timing;
  final ValueChanged<LangarTiming?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = timing;
    final theme = Theme.of(context);
    Future<void> pick(bool open) async {
      final cur = (open ? t?.opensAt : t?.closesAt) ?? TimeOfDay(hour: open ? 6 : 22, minute: 0);
      final v = await showTimePicker(context: context, initialTime: cur);
      if (v == null) return;
      onChanged(LangarTiming(dayOfWeek: t!.dayOfWeek, opensAt: open ? v : t.opensAt, closesAt: open ? t.closesAt : v));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Row(
        children: [
          SizedBox(width: 44, child: Text(name, style: theme.textTheme.bodyMedium)),
          Switch(
            value: t != null,
            onChanged: (v) => onChanged(v
                ? LangarTiming(dayOfWeek: dow, opensAt: const TimeOfDay(hour: 6, minute: 0), closesAt: const TimeOfDay(hour: 22, minute: 0))
                : null),
          ),
          Expanded(
            child: t == null
                ? Text(l.closedToday, style: TextStyle(color: theme.colorScheme.outline))
                : t.is24h
                    ? Text(l.open24h)
                    : Row(
                        children: [
                          TextButton(onPressed: () => pick(true), child: Text(MaterialLocalizations.of(context).formatTimeOfDay(t.opensAt!))),
                          const Text('–'),
                          TextButton(onPressed: () => pick(false), child: Text(MaterialLocalizations.of(context).formatTimeOfDay(t.closesAt!))),
                        ],
                      ),
          ),
          if (t != null)
            Tooltip(
              message: l.open24h,
              child: IconButton(
                icon: Icon(Icons.all_inclusive, color: t.is24h ? theme.colorScheme.primary : theme.colorScheme.outline),
                onPressed: () => onChanged(t.is24h
                    ? LangarTiming(dayOfWeek: t.dayOfWeek, opensAt: const TimeOfDay(hour: 6, minute: 0), closesAt: const TimeOfDay(hour: 22, minute: 0))
                    : LangarTiming(dayOfWeek: t.dayOfWeek, is24h: true)),
              ),
            ),
        ],
      ),
    );
  }
}
