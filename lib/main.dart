import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'src/colori.dart';
import 'src/day_store.dart';
import 'src/day_store_web.dart';
import 'src/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Sul telefono SQLite; nel browser (versione web per iPhone) lo storage del browser.
  final DayStore store = kIsWeb ? await PrefsDayStore.apri() : await SqliteDayStore.apri();
  runApp(CaccalendarioApp(store: store));
}

class CaccalendarioApp extends StatelessWidget {
  const CaccalendarioApp({super.key, required this.store, this.orologio = DateTime.now});

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
      title: 'Caccalendario',
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
