import 'package:flutter_test/flutter_test.dart';
import 'package:poop_diary/src/date.dart';
import 'package:poop_diary/src/tipi.dart';

void main() {
  group('toggleTipo', () {
    test('un tipo per colonna: il nuovo sostituisce quello della stessa colonna', () {
      expect(toggleTipo({TipoCacca.regolare}, TipoCacca.tanta), {TipoCacca.tanta});
      expect(toggleTipo({TipoCacca.dura}, TipoCacca.morbida), {TipoCacca.morbida});
    });

    test('si può avere un tipo per ciascuna colonna', () {
      expect(toggleTipo({TipoCacca.regolare}, TipoCacca.dura), {TipoCacca.regolare, TipoCacca.dura});
      expect(toggleTipo({TipoCacca.poca, TipoCacca.dura}, TipoCacca.liquida),
          {TipoCacca.poca, TipoCacca.liquida});
    });

    test('toccare un tipo attivo lo spegne', () {
      expect(toggleTipo({TipoCacca.regolare, TipoCacca.dura}, TipoCacca.dura), {TipoCacca.regolare});
      expect(toggleTipo({TipoCacca.niente}, TipoCacca.niente), <TipoCacca>{});
    });

    test('"Niente" spegne tutto e un altro tipo spegne "Niente"', () {
      expect(toggleTipo({TipoCacca.tanta, TipoCacca.liquida}, TipoCacca.niente), {TipoCacca.niente});
      expect(toggleTipo({TipoCacca.niente}, TipoCacca.poca), {TipoCacca.poca});
    });

    test('ogni colonna ha tre tipi, "Niente" è da solo', () {
      expect(TipoCacca.diColonna(1), [TipoCacca.regolare, TipoCacca.tanta, TipoCacca.poca]);
      expect(TipoCacca.diColonna(2), [TipoCacca.dura, TipoCacca.liquida, TipoCacca.morbida]);
      expect(TipoCacca.diColonna(0), [TipoCacca.niente]);
    });
  });

  group('date', () {
    test('isoData usa la data locale con zeri', () {
      expect(isoData(DateTime(2026, 3, 7)), '2026-03-07');
      expect(isoMese(2026, 11), '2026-11-');
    });

    test('la settimana parte da lunedì', () {
      expect(celleVuoteIniziali(2026, 11), 6); // 1 novembre 2026 è domenica
      expect(celleVuoteIniziali(2026, 6), 0); // 1 giugno 2026 è lunedì
      expect(giorniNelMese(2028, 2), 29);
    });

    test('i giorni futuri si riconoscono anche a orari diversi', () {
      final oggi = DateTime(2026, 11, 10, 23, 59);
      expect(isFuturo(DateTime(2026, 11, 10, 0, 1), oggi), isFalse);
      expect(isFuturo(DateTime(2026, 11, 11), oggi), isTrue);
    });
  });
}
