import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langarseva/core/open_now.dart';
import 'package:langarseva/features/langars/data/langar.dart';

void main() {
  // 2026-10-07 is a Wednesday. 12:00 IST == 06:30 UTC.
  final wedNoonIst = DateTime.utc(2026, 10, 7, 6, 30);
  final wedMidnightIst = DateTime.utc(2026, 10, 6, 18, 30); // 00:00 IST Wednesday
  const wed = 3;

  group('nowInIst / pgDow', () {
    test('converts UTC to IST', () {
      final ist = nowInIst(wedNoonIst);
      expect(ist.hour, 12);
      expect(ist.minute, 0);
      expect(pgDow(ist), wed);
    });
    test('Sunday maps to 0', () {
      expect(pgDow(DateTime.utc(2026, 10, 11, 12)), 0);
    });
  });

  group('isOpenAt', () {
    test('open within a daytime window', () {
      final t = [LangarTiming(dayOfWeek: wed, opensAt: const TimeOfDay(hour: 6, minute: 0), closesAt: const TimeOfDay(hour: 22, minute: 0))];
      expect(isOpenAt(t, wedNoonIst), isTrue);
    });
    test('closed outside the window', () {
      final t = [LangarTiming(dayOfWeek: wed, opensAt: const TimeOfDay(hour: 13, minute: 0), closesAt: const TimeOfDay(hour: 15, minute: 0))];
      expect(isOpenAt(t, wedNoonIst), isFalse);
    });
    test('closed when no row for that day', () {
      final t = [LangarTiming(dayOfWeek: 4, opensAt: const TimeOfDay(hour: 0, minute: 0), closesAt: const TimeOfDay(hour: 23, minute: 59))];
      expect(isOpenAt(t, wedNoonIst), isFalse);
    });
    test('24h row is always open', () {
      expect(isOpenAt([const LangarTiming(dayOfWeek: wed, is24h: true)], wedNoonIst), isTrue);
      expect(isOpenAt([const LangarTiming(dayOfWeek: wed, is24h: true)], wedMidnightIst), isTrue);
    });
    test('overnight row covers its own evening and the next early morning', () {
      // Tuesday 20:00 - 02:00
      final t = [LangarTiming(dayOfWeek: 2, opensAt: const TimeOfDay(hour: 20, minute: 0), closesAt: const TimeOfDay(hour: 2, minute: 0))];
      expect(isOpenAt(t, DateTime.utc(2026, 10, 6, 15, 30)), isTrue, reason: 'Tue 21:00 IST');
      expect(isOpenAt(t, wedMidnightIst), isTrue, reason: 'Wed 00:00 IST, tail of Tue night');
      expect(isOpenAt(t, DateTime.utc(2026, 10, 6, 19, 30)), isTrue, reason: 'Wed 01:00 IST');
      expect(isOpenAt(t, DateTime.utc(2026, 10, 6, 21, 30)), isFalse, reason: 'Wed 03:00 IST');
      expect(isOpenAt(t, DateTime.utc(2026, 10, 5, 19, 30)), isFalse, reason: 'Tue 01:00 IST belongs to Monday night');
      expect(isOpenAt(t, wedNoonIst), isFalse);
    });
    test('a 24h row does not spill into the next day', () {
      final t = [const LangarTiming(dayOfWeek: 2, is24h: true)];
      expect(isOpenAt(t, wedNoonIst), isFalse);
    });
    test('two sittings in one day', () {
      final t = [
        LangarTiming(dayOfWeek: wed, opensAt: const TimeOfDay(hour: 11, minute: 30), closesAt: const TimeOfDay(hour: 14, minute: 30)),
        LangarTiming(dayOfWeek: wed, opensAt: const TimeOfDay(hour: 19, minute: 0), closesAt: const TimeOfDay(hour: 21, minute: 30)),
      ];
      expect(isOpenAt(t, wedNoonIst), isTrue);
      expect(isOpenAt(t, DateTime.utc(2026, 10, 7, 11, 0)), isFalse); // 16:30 IST
      expect(isOpenAt(t, DateTime.utc(2026, 10, 7, 14, 30)), isTrue); // 20:00 IST
    });
  });
}
