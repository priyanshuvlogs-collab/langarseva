import 'package:flutter_test/flutter_test.dart';
import 'package:langarseva/core/distance.dart';

void main() {
  test('haversine: Bangla Sahib to Sis Ganj is roughly 4 km', () {
    final d = haversineMetres(28.6264, 77.2090, 28.6562, 77.2334);
    expect(d, inInclusiveRange(3800, 4400));
  });
  test('haversine: same point is zero', () {
    expect(haversineMetres(10, 10, 10, 10), 0);
  });
  test('formatDistance switches units at 1 km', () {
    expect(formatDistance(850), (isKm: false, value: '850'));
    expect(formatDistance(1234), (isKm: true, value: '1.2'));
    expect(formatDistance(12345), (isKm: true, value: '12'));
  });
}
