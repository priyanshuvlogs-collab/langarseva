import '../features/langars/data/langar.dart';

/// India Standard Time is fixed at UTC+05:30 (no DST).
const istOffset = Duration(hours: 5, minutes: 30);

DateTime nowInIst([DateTime? now]) => (now ?? DateTime.now()).toUtc().add(istOffset);

/// Postgres-style day of week: 0 = Sunday ... 6 = Saturday.
int pgDow(DateTime istTime) => istTime.weekday % 7;

/// Whether any timing row covers [at] (interpreted in IST).
///
/// An overnight row on day D (opens_at > closes_at, e.g. 20:00-02:00) covers
/// D from opens_at to midnight and D+1 from midnight to closes_at.
bool isOpenAt(List<LangarTiming> timings, DateTime at) {
  final ist = nowInIst(at);
  final dow = pgDow(ist);
  final yesterday = (dow + 6) % 7;
  final minutes = ist.hour * 60 + ist.minute;
  for (final t in timings) {
    if (t.dayOfWeek != dow && t.dayOfWeek != yesterday) continue;
    if (t.is24h) {
      if (t.dayOfWeek == dow) return true;
      continue;
    }
    final o = t.opensAt, c = t.closesAt;
    if (o == null || c == null) continue;
    final om = o.hour * 60 + o.minute, cm = c.hour * 60 + c.minute;
    final overnight = om > cm;
    if (t.dayOfWeek == dow) {
      if (!overnight && minutes >= om && minutes <= cm) return true;
      if (overnight && minutes >= om) return true;
    } else if (overnight && minutes <= cm) {
      return true; // tail of last night's session
    }
  }
  return false;
}

bool isOpenNow(List<LangarTiming> timings) => isOpenAt(timings, DateTime.now());
