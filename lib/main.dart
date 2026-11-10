import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'src/colori.dart';
import 'src/day_store.dart';
import 'src/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = await SqliteDayStore.apri();
  runApp(TrackerCaccaApp(store: store));
}

class TrackerCaccaApp extends StatelessWidget {
  const TrackerCaccaApp({super.key, required this.store, this.orologio = DateTime.now});

  final DayStore store;
  final DateTime Function() orologio;

  @override
  Widget build(BuildContext context) {
    final schema = ColorScheme.fromSeed(
      seedColor: Colori.rosaForte,
      brightness: Brightness.light,
      surface: Colori.superficie,
      onSurface: Colori.inchiostro,
      primary: Colori.inchiostro,
      onPrimary: Colors.white,
    );
    return MaterialApp(
      title: 'Tracker Cacca',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      locale: const Locale('it'),
      supportedLocales: const [Locale('it')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: schema,
        scaffoldBackgroundColor: Colori.sfondo,
        textTheme: ThemeData.light().textTheme.apply(
              bodyColor: Colori.inchiostro,
              displayColor: Colori.inchiostro,
            ),
      ),
      home: HomePage(store: store, orologio: orologio),
    );
  }
}
