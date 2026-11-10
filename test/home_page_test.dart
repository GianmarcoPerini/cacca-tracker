import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poop_diary/main.dart';
import 'package:poop_diary/src/day_store.dart';
import 'package:poop_diary/src/tipi.dart';

void main() {
  final oggi = DateTime(2026, 11, 10);

  Future<MemoryDayStore> avvia(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);
    final store = MemoryDayStore();
    await tester.pumpWidget(CaccalendarioApp(store: store, orologio: () => oggi));
    await tester.pumpAndSettle();
    return store;
  }

  testWidgets('su un telefono piccolo tutto sta in una schermata senza scroll', (tester) async {
    // 360 x 592 dp: lo spazio utile dell'emulatore. Novembre 2026 ha 6 righe.
    tester.view.physicalSize = const Size(720, 1184);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(CaccalendarioApp(store: MemoryDayStore(), orologio: () => oggi));
    await tester.pumpAndSettle();

    expect(find.byType(SingleChildScrollView), findsNothing);
    final altezza = tester.view.physicalSize.height / tester.view.devicePixelRatio;
    expect(tester.getBottomLeft(find.byKey(const ValueKey('tipo-niente'))).dy, lessThanOrEqualTo(altezza));
    expect(tester.getBottomLeft(find.byKey(const ValueKey('giorno-2026-11-30'))).dy,
        lessThan(tester.getTopLeft(find.byKey(const ValueKey('tipo-regolare'))).dy));
  });

  testWidgets('se lo schermo è troppo basso torna lo scroll', (tester) async {
    tester.view.physicalSize = const Size(720, 960);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(CaccalendarioApp(store: MemoryDayStore(), orologio: () => oggi));
    await tester.pumpAndSettle();
    expect(find.byType(SingleChildScrollView), findsOneWidget);
  });

  testWidgets('mostra solo il mese nel titolo e oggi è selezionato', (tester) async {
    await avvia(tester);
    expect(find.text('Novembre'), findsOneWidget);
    expect(find.textContaining('2026'), findsNothing);
    expect(find.text('Torna a oggi'), findsNothing);
  });

  testWidgets('registrare un tipo lo salva e lo mostra nella cella', (tester) async {
    final store = await avvia(tester);

    await tester.tap(find.byKey(const ValueKey('giorno-2026-11-05')));
    await tester.pump();
    await tester.ensureVisible(find.byKey(const ValueKey('tipo-regolare')));
    await tester.tap(find.byKey(const ValueKey('tipo-regolare')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('tipo-dura')));
    await tester.pump();

    expect(store.dati['2026-11-05'], {TipoCacca.regolare, TipoCacca.dura});
    final cella = find.byKey(const ValueKey('giorno-2026-11-05'));
    // Ogni icona è disegnata due volte: la sagoma bianca del bordo e l'immagine.
    expect(find.descendant(of: cella, matching: find.byType(Image)), findsNWidgets(4));

    await tester.tap(find.byKey(const ValueKey('tipo-niente')));
    await tester.pump();
    expect(store.dati['2026-11-05'], {TipoCacca.niente});

    await tester.tap(find.byKey(const ValueKey('tipo-niente')));
    await tester.pump();
    expect(store.dati.containsKey('2026-11-05'), isFalse);
  });

  testWidgets('i giorni futuri non si possono selezionare', (tester) async {
    final store = await avvia(tester);
    await tester.tap(find.byKey(const ValueKey('giorno-2026-11-20')));
    await tester.pump();
    await tester.ensureVisible(find.byKey(const ValueKey('tipo-poca')));
    await tester.tap(find.byKey(const ValueKey('tipo-poca')));
    await tester.pump();
    // La selezione resta su oggi.
    expect(store.dati.keys, ['2026-11-10']);
  });

  testWidgets('le frecce cambiano mese e "Torna a oggi" riporta a novembre', (tester) async {
    await avvia(tester);
    await tester.tap(find.byKey(const ValueKey('mese-precedente')));
    await tester.pumpAndSettle();
    expect(find.text('Ottobre'), findsOneWidget);
    await tester.tap(find.text('Torna a oggi'));
    await tester.pumpAndSettle();
    expect(find.text('Novembre'), findsOneWidget);
  });
}
