import 'package:flutter_test/flutter_test.dart';
import 'package:poop_diary/src/day_store.dart';
import 'package:poop_diary/src/tipi.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  test('SqliteDayStore salva, legge per mese e cancella i giorni vuoti', () async {
    final store = await SqliteDayStore.apri(factory: databaseFactoryFfi, percorso: inMemoryDatabasePath);

    await store.scriviGiorno('2026-11-05', {TipoCacca.dura, TipoCacca.regolare});
    await store.scriviGiorno('2026-11-06', {TipoCacca.niente});
    await store.scriviGiorno('2026-12-01', {TipoCacca.poca});

    expect(await store.leggiMese(2026, 11), {
      '2026-11-05': {TipoCacca.regolare, TipoCacca.dura},
      '2026-11-06': {TipoCacca.niente},
    });

    await store.scriviGiorno('2026-11-05', {TipoCacca.tanta});
    await store.scriviGiorno('2026-11-06', {});
    expect(await store.leggiMese(2026, 11), {
      '2026-11-05': {TipoCacca.tanta},
    });
    expect(await store.leggiMese(2026, 12), {
      '2026-12-01': {TipoCacca.poca},
    });

    await store.chiudi();
  });
}
