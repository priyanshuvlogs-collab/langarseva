import 'dart:math' as math;

/// Great-circle distance in metres between two WGS84 points.
double haversineMetres(double lat1, double lng1, double lat2, double lng2) {
  const r = 6371000.0;
  final dLat = _rad(lat2 - lat1);
  final dLng = _rad(lng2 - lng1);
  final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(_rad(lat1)) * math.cos(_rad(lat2)) * math.sin(dLng / 2) * math.sin(dLng / 2);
  return 2 * r * math.atan2(math.sqrt(a), math.sqrt(1 - a));
}

double _rad(double deg) => deg * math.pi / 180.0;

/// Formats metres as "850 m" or "12.4 km". Returns (isKm, value).
({bool isKm, String value}) formatDistance(double metres) {
  if (metres < 1000) return (isKm: false, value: metres.round().toString());
  final km = metres / 1000;
  return (isKm: true, value: km < 10 ? km.toStringAsFixed(1) : km.round().toString());
}
