import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'date.dart';
import 'tipi.dart';

/// Accesso ai dati dei giorni, indicizzati per data ISO "YYYY-MM-DD".
/// Un giorno senza tipi non viene salvato.
abstract class DayStore {
  Future<Map<String, Set<TipoCacca>>> leggiMese(int anno, int mese);
  Future<void> scriviGiorno(String iso, Set<TipoCacca> tipi);
}

/// Storage in memoria, usato nei test.
class MemoryDayStore implements DayStore {
  final Map<String, Set<TipoCacca>> dati = {};

  @override
  Future<Map<String, Set<TipoCacca>>> leggiMese(int anno, int mese) async {
    final prefisso = isoMese(anno, mese);
    return {
      for (final e in dati.entries)
        if (e.key.startsWith(prefisso)) e.key: {...e.value},
    };
  }

  @override
  Future<void> scriviGiorno(String iso, Set<TipoCacca> tipi) async {
    if (tipi.isEmpty) {
      dati.remove(iso);
    } else {
      dati[iso] = {...tipi};
    }
  }
}

/// Storage persistente sul telefono, in un database SQLite locale.
class SqliteDayStore implements DayStore {
  SqliteDayStore._(this._db);

  final Database _db;
  static const _tabella = 'giorni';

  /// Apre (o crea) il database. [factory] e [percorso] servono ai test.
  static Future<SqliteDayStore> apri({DatabaseFactory? factory, String? percorso}) async {
    final f = factory ?? databaseFactory;
    // Il file mantiene il nome del primo nome dell'app, per non perdere i dati già salvati.
    final path = percorso ?? p.join(await f.getDatabasesPath(), 'tracker_cacca.db');
    final db = await f.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, _) => db.execute(
          'CREATE TABLE $_tabella (data TEXT PRIMARY KEY, tipi TEXT NOT NULL)',
        ),
      ),
    );
    return SqliteDayStore._(db);
  }

  @override
  Future<Map<String, Set<TipoCacca>>> leggiMese(int anno, int mese) async {
    final righe = await _db.query(
      _tabella,
      where: 'data LIKE ?',
      whereArgs: ['${isoMese(anno, mese)}%'],
    );
    final risultato = <String, Set<TipoCacca>>{};
    for (final r in righe) {
      final tipi = (r['tipi'] as String)
          .split(',')
          .map(TipoCacca.daId)
          .whereType<TipoCacca>()
          .toSet();
      if (tipi.isNotEmpty) risultato[r['data'] as String] = tipi;
    }
    return risultato;
  }

  @override
  Future<void> scriviGiorno(String iso, Set<TipoCacca> tipi) async {
    if (tipi.isEmpty) {
      await _db.delete(_tabella, where: 'data = ?', whereArgs: [iso]);
    } else {
      await _db.insert(
        _tabella,
        {'data': iso, 'tipi': ordinati(tipi).map((t) => t.name).join(',')},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<void> chiudi() => _db.close();
}
