// Generates Play Store / App Store phone screenshots from the real app widgets.
//
//   flutter test --update-goldens tool/store_screenshots_test.dart \
//     --dart-define=NOTO_DIR=/path/to/noto/fonts
//
// NOTO_DIR must contain NotoSansDevanagari.ttf and NotoSansGurmukhi.ttf (from
// github.com/google/fonts) so Hindi and Punjabi render; Roboto and Material
// Icons come from the Flutter SDK cache. Output: store/screenshots/<locale>/.
// Langar names, addresses, distances and timings are the live seed data seen
// from Connaught Place, New Delhi. Seva slots are sample entries.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langarseva/app/theme.dart';
import 'package:langarseva/core/locale_controller.dart';
import 'package:langarseva/core/supabase_client.dart';
import 'package:langarseva/features/auth/auth_controller.dart';
import 'package:langarseva/features/langars/data/langar.dart';
import 'package:langarseva/features/langars/data/langar_repository.dart';
import 'package:langarseva/features/langars/presentation/langar_detail_screen.dart';
import 'package:langarseva/features/langars/presentation/langar_list_tile.dart';
import 'package:langarseva/features/profile/profile_screen.dart';
import 'package:langarseva/features/seva/seva_repository.dart';
import 'package:langarseva/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _noto = String.fromEnvironment('NOTO_DIR');

const _langars = [
  Langar(
    id: 'bangla',
    name: 'Gurudwara Bangla Sahib',
    lat: 28.6264,
    lng: 77.2091,
    address: 'Ashoka Rd, Hanuman Road Area, Connaught Place, New Delhi 110001',
    city: 'New Delhi',
    state: 'Delhi',
    description: 'One of the largest langars in Delhi, serving thousands every day.',
    distanceM: 941,
    isOpen: true,
  ),
  Langar(id: 'rakab', name: 'Gurudwara Rakab Ganj Sahib', lat: 0, lng: 0, address: 'Pandit Pant Marg, near Parliament House', city: 'New Delhi', distanceM: 1882, isOpen: true),
  Langar(id: 'sisganj', name: 'Gurudwara Sis Ganj Sahib', lat: 0, lng: 0, address: 'Chandni Chowk Rd, Old Delhi', city: 'Delhi', distanceM: 3187, isOpen: true),
  Langar(id: 'majnu', name: 'Gurudwara Majnu Ka Tilla', lat: 0, lng: 0, address: 'Outer Ring Rd, Majnu Ka Tilla', city: 'Delhi', distanceM: 7692, isOpen: true),
  Langar(id: 'nanak', name: 'Gurudwara Nanak Piao Sahib', lat: 0, lng: 0, address: 'GT Karnal Rd, Rana Pratap Bagh', city: 'Delhi', distanceM: 8517, isOpen: true),
];

final _timings = [for (var d = 0; d < 7; d++) LangarTiming(dayOfWeek: d, is24h: true)];

List<SevaSlot> _slots() {
  final base = DateTime.now().add(const Duration(days: 1));
  DateTime at(int h) => DateTime(base.year, base.month, base.day, h);
  return [
    SevaSlot(id: 's1', langarId: 'bangla', title: 'Kitchen seva: roti making', startsAt: at(6), endsAt: at(9), capacity: 20, joined: 12),
    SevaSlot(id: 's2', langarId: 'bangla', title: 'Serving langar (pangat)', startsAt: at(12), endsAt: at(15), capacity: 30, joined: 21),
    SevaSlot(id: 's3', langarId: 'bangla', title: 'Utensil washing', startsAt: at(18), endsAt: at(21), capacity: 15, joined: 15),
  ];
}

const _captions = {
  'en': ['Find free langars near you', 'Timings and open-now at a glance', 'Join seva as a volunteer', 'English, Hindi and Punjabi'],
  'hi': ['अपने आस-पास मुफ़्त लंगर खोजें', 'समय और अभी खुला, एक नज़र में', 'स्वयंसेवक बनकर सेवा करें', 'अंग्रेज़ी, हिंदी और पंजाबी'],
  'pa': ['ਆਪਣੇ ਨੇੜੇ ਮੁਫ਼ਤ ਲੰਗਰ ਲੱਭੋ', 'ਸਮਾਂ ਅਤੇ ਹੁਣ ਖੁੱਲ੍ਹਾ, ਇੱਕ ਨਜ਼ਰ ਵਿੱਚ', 'ਸੇਵਾਦਾਰ ਬਣ ਕੇ ਸੇਵਾ ਕਰੋ', 'ਅੰਗਰੇਜ਼ੀ, ਹਿੰਦੀ ਅਤੇ ਪੰਜਾਬੀ'],
};

const _fallback = ['NotoSansDevanagari', 'NotoSansGurmukhi'];

Future<void> _loadFont(String family, List<String> paths) async {
  final loader = FontLoader(family);
  for (final p in paths) {
    final bytes = File(p).readAsBytesSync();
    loader.addFont(Future.value(ByteData.view(Uint8List.fromList(bytes).buffer)));
  }
  await loader.load();
}

ThemeData _theme() {
  final t = buildTheme(Brightness.light);
  return t.copyWith(
    textTheme: t.textTheme.apply(fontFamily: 'Roboto', fontFamilyFallback: _fallback),
    primaryTextTheme: t.primaryTextTheme.apply(fontFamily: 'Roboto', fontFamilyFallback: _fallback),
  );
}

/// Store frame: saffron background, caption on top, the app screen below.
class _Frame extends StatelessWidget {
  const _Frame({required this.caption, required this.locale, required this.child});
  final String caption;
  final Locale locale;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    const captionH = 150.0, pad = 22.0;
    final screen = Size(media.size.width - pad * 2, media.size.height - captionH - pad);
    return Material(
      color: seedColor,
      child: Column(
        children: [
          SizedBox(
            height: captionH,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  caption,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontFamily: 'Roboto', fontFamilyFallback: _fallback, fontSize: 28, height: 1.25, fontWeight: FontWeight.w700, color: Colors.white),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: pad),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              child: SizedBox.fromSize(
                size: screen,
                child: MediaQuery(
                  data: media.copyWith(size: screen, padding: const EdgeInsets.only(top: 12), viewPadding: const EdgeInsets.only(top: 12)),
                  child: child,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _app(Locale locale, String caption, Widget home, SharedPreferences prefs) {
  return ProviderScope(
    overrides: [
      sharedPrefsProvider.overrideWithValue(prefs),
      currentUserProvider.overrideWithValue(null),
      profileProvider.overrideWith((ref) async => null),
      favouriteIdsProvider.overrideWith((ref) async => <String>{}),
      langarByIdProvider.overrideWith((ref, id) async => _langars.first),
      langarTimingsProvider.overrideWith((ref, id) async => _timings),
      sevaSlotsProvider.overrideWith((ref, id) async => _slots()),
      mySlotIdsProvider.overrideWith((ref) async => {'s2'}),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _theme(),
      locale: locale,
      supportedLocales: supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Builder(builder: (context) => _Frame(caption: caption, locale: locale, child: home)),
    ),
  );
}

/// The nearby list exactly as the home screen's bottom sheet renders it.
class _NearbyList extends StatelessWidget {
  const _NearbyList();
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Material(
                elevation: 3,
                borderRadius: BorderRadius.circular(28),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: l.searchCityHint,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: const Icon(Icons.person_outline),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  FilterChip(label: Text(l.openNow), selected: true, avatar: Icon(Icons.schedule, size: 16, color: Colors.green.shade800), onSelected: (_) {}),
                  const SizedBox(width: 8),
                  ChoiceChip(label: Text(l.within5km), selected: false, onSelected: (_) {}),
                  const SizedBox(width: 8),
                  ChoiceChip(label: Text(l.within25km), selected: true, onSelected: (_) {}),
                  const SizedBox(width: 8),
                  ChoiceChip(label: Text(l.within100km), selected: false, onSelected: (_) {}),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Row(children: [
                Expanded(child: Text(l.nearYou, style: theme.textTheme.titleMedium)),
                Text('${_langars.length}', style: theme.textTheme.labelLarge),
              ]),
            ),
            Expanded(
              child: ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _langars.length,
                separatorBuilder: (_, __) => const Divider(height: 1, indent: 88),
                itemBuilder: (_, i) => LangarListTile(langar: _langars[i], onTap: () {}),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(onPressed: () {}, icon: const Icon(Icons.add_location_alt_outlined), label: Text(l.addLangar)),
    );
  }
}

void main() {
  setUpAll(() async {
    final sdk = Platform.environment['FLUTTER_ROOT'] ?? '/opt/flutter';
    final mf = '$sdk/bin/cache/artifacts/material_fonts';
    await _loadFont('Roboto', ['$mf/Roboto-Regular.ttf', '$mf/Roboto-Medium.ttf', '$mf/Roboto-Bold.ttf']);
    await _loadFont('MaterialIcons', ['$mf/MaterialIcons-Regular.otf']);
    if (_noto.isNotEmpty) {
      await _loadFont('NotoSansDevanagari', ['$_noto/NotoSansDevanagari.ttf']);
      await _loadFont('NotoSansGurmukhi', ['$_noto/NotoSansGurmukhi.ttf']);
    }
  });

  for (final code in ['en', 'hi', 'pa']) {
    final locale = Locale(code);
    final caps = _captions[code]!;
    Future<void> shoot(WidgetTester tester, int n, Widget home, {Future<void> Function()? before}) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(tester.view.reset);
      debugDisableShadows = false;
      // ignore: invalid_use_of_visible_for_testing_member
      SharedPreferences.setMockInitialValues({'locale': code});
      final prefs = await SharedPreferences.getInstance();
      await tester.pumpWidget(_app(locale, caps[n - 1], home, prefs));
      await tester.pumpAndSettle();
      if (before != null) await before();
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('../store/screenshots/$code/0${n}_${['nearby', 'detail', 'seva', 'language'][n - 1]}.png'));
      debugDisableShadows = true;
    }

    testWidgets('$code 1 nearby', (t) => shoot(t, 1, const _NearbyList()));
    testWidgets('$code 2 detail', (t) => shoot(t, 2, const LangarDetailScreen(id: 'bangla')));
    testWidgets('$code 3 seva', (t) => shoot(t, 3, const LangarDetailScreen(id: 'bangla'), before: () async {
          await t.scrollUntilVisible(find.byType(Card).last, 400, scrollable: find.byType(Scrollable).first);
          await t.drag(find.byType(Scrollable).first, const Offset(0, -900));
          await t.pumpAndSettle();
        }));
    testWidgets('$code 4 language', (t) => shoot(t, 4, const ProfileScreen()));
  }
}
