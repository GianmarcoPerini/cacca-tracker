import 'package:flutter_test/flutter_test.dart';
import 'package:poop_diary/src/day_store_web.dart';
import 'package:poop_diary/src/tipi.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('PrefsDayStore salva, legge per mese e cancella i giorni vuoti', () async {
    SharedPreferences.setMockInitialValues({'altra-chiave': 'x'});
    final store = await PrefsDayStore.apri();

    await store.scriviGiorno('2026-11-05', {TipoCacca.dura, TipoCacca.regolare});
    await store.scriviGiorno('2026-11-06', {TipoCacca.niente});
    await store.scriviGiorno('2026-12-01', {TipoCacca.poca});
    expect(await store.leggiMese(2026, 11), {
      '2026-11-05': {TipoCacca.regolare, TipoCacca.dura},
      '2026-11-06': {TipoCacca.niente},
    });

    await store.scriviGiorno('2026-11-06', {});
    expect((await store.leggiMese(2026, 11)).keys, ['2026-11-05']);
    expect(await store.leggiMese(2026, 12), {
      '2026-12-01': {TipoCacca.poca},
    });

    // Una nuova istanza rilegge gli stessi dati.
    final riaperto = await PrefsDayStore.apri();
    expect((await riaperto.leggiMese(2026, 11))['2026-11-05'], {TipoCacca.regolare, TipoCacca.dura});
  });
}
