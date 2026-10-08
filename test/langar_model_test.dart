import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langarseva/features/langars/data/langar.dart';

void main() {
  test('Langar.fromJson parses an RPC row', () {
    final l = Langar.fromJson({
      'id': 'abc',
      'name': 'Test Langar',
      'lat': 28.6,
      'lng': 77.2,
      'photos': ['https://x/y.jpg'],
      'distance_m': 1500.5,
      'is_open': true,
      'status': 'approved',
    });
    expect(l.name, 'Test Langar');
    expect(l.photos, hasLength(1));
    expect(l.distanceM, 1500.5);
    expect(l.isOpen, isTrue);
    expect(l.status, LangarStatus.approved);
    expect(l.hasDonation, isFalse);
  });

  test('LangarTiming round-trips time strings', () {
    final t = LangarTiming.fromJson({'day_of_week': 2, 'opens_at': '06:30:00', 'closes_at': '22:00:00', 'is_24h': false});
    expect(t.opensAt, const TimeOfDay(hour: 6, minute: 30));
    final json = t.toJson('id1');
    expect(json['opens_at'], '06:30');
    expect(json['closes_at'], '22:00');
    expect(json['langar_id'], 'id1');
  });

  test('SevaSlot computes spots left from counts', () {
    final s = SevaSlot.fromJson({
      'id': 's1',
      'langar_id': 'l1',
      'title': 'Roti',
      'starts_at': '2026-10-10T03:30:00Z',
      'ends_at': '2026-10-10T06:30:00Z',
      'capacity': 5,
      'seva_slot_counts': {'joined': 5},
    });
    expect(s.spotsLeft, 0);
    expect(s.isFull, isTrue);
  });
}
