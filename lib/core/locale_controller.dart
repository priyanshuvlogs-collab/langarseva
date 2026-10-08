import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const supportedLocales = [Locale('en'), Locale('hi'), Locale('pa')];

const localeNames = {'en': 'English', 'hi': 'हिन्दी', 'pa': 'ਪੰਜਾਬੀ'};

class LocaleController extends StateNotifier<Locale?> {
  LocaleController(this._prefs) : super(_read(_prefs));
  final SharedPreferences _prefs;
  static const _key = 'locale';

  static Locale? _read(SharedPreferences p) {
    final code = p.getString(_key);
    return code == null ? null : Locale(code);
  }

  Future<void> set(Locale? locale) async {
    state = locale;
    if (locale == null) {
      await _prefs.remove(_key);
    } else {
      await _prefs.setString(_key, locale.languageCode);
    }
  }
}

final sharedPrefsProvider = Provider<SharedPreferences>((ref) => throw UnimplementedError('override in main'));

final localeProvider = StateNotifierProvider<LocaleController, Locale?>(
  (ref) => LocaleController(ref.watch(sharedPrefsProvider)),
);
