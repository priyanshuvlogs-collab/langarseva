import '../features/langars/data/langar.dart';

/// India Standard Time is fixed at UTC+05:30 (no DST).
const istOffset = Duration(hours: 5, minutes: 30);

DateTime nowInIst([DateTime? now]) => (now ?? DateTime.now()).toUtc().add(istOffset);

/// Postgres-style day of week: 0 = Sunday ... 6 = Saturday.
int pgDow(DateTime istTime) => istTime.weekday % 7;

/// Whether any timing row covers [at] (interpreted in IST).
bool isOpenAt(List<LangarTiming> timings, DateTime at) {
  final ist = nowInIst(at);
  final dow = pgDow(ist);
  final minutes = ist.hour * 60 + ist.minute;
  for (final t in timings.where((t) => t.dayOfWeek == dow)) {
    if (t.is24h) return true;
    final o = t.opensAt, c = t.closesAt;
    if (o == null || c == null) continue;
    final om = o.hour * 60 + o.minute, cm = c.hour * 60 + c.minute;
    if (om <= cm) {
      if (minutes >= om && minutes <= cm) return true;
    } else {
      // overnight, e.g. 20:00 - 02:00
      if (minutes >= om || minutes <= cm) return true;
    }
  }
  return false;
}

bool isOpenNow(List<LangarTiming> timings) => isOpenAt(timings, DateTime.now());
