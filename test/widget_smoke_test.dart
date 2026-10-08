import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langarseva/features/langars/data/langar.dart';
import 'package:langarseva/features/langars/presentation/langar_list_tile.dart';
import 'package:langarseva/l10n/app_localizations.dart';

Widget wrap(Widget child, {Locale locale = const Locale('en')}) => MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Scaffold(body: child),
    );

void main() {
  const langar = Langar(id: '1', name: 'Gurudwara Bangla Sahib', lat: 28.6, lng: 77.2, city: 'New Delhi', distanceM: 2300, isOpen: true);

  testWidgets('list tile shows name, distance and open badge (en)', (tester) async {
    await tester.pumpWidget(wrap(const LangarListTile(langar: langar)));
    await tester.pumpAndSettle();
    expect(find.text('Gurudwara Bangla Sahib'), findsOneWidget);
    expect(find.text('2.3 km away'), findsOneWidget);
    expect(find.text('Open'), findsOneWidget);
  });

  testWidgets('list tile localises to Hindi', (tester) async {
    await tester.pumpWidget(wrap(const LangarListTile(langar: langar), locale: const Locale('hi')));
    await tester.pumpAndSettle();
    expect(find.text('खुला'), findsOneWidget);
    expect(find.text('2.3 किमी दूर'), findsOneWidget);
  });

  testWidgets('list tile localises to Punjabi', (tester) async {
    await tester.pumpWidget(wrap(const LangarListTile(langar: langar), locale: const Locale('pa')));
    await tester.pumpAndSettle();
    expect(find.text('ਖੁੱਲ੍ਹਾ'), findsOneWidget);
  });
}
