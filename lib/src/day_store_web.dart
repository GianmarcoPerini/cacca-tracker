import 'package:shared_preferences/shared_preferences.dart';

import 'date.dart';
import 'day_store.dart';
import 'tipi.dart';

/// Storage per la versione web (app aggiunta alla schermata Home).
///
/// SQLite non funziona nel browser: qui ogni giorno è una voce dello storage
/// del browser, con chiave "giorno:YYYY-MM-DD" e valore gli id dei tipi
/// separati da virgola. I dati restano solo in quel browser.
class PrefsDayStore implements DayStore {
  PrefsDayStore._(this._prefs);

  final SharedPreferences _prefs;
  static const _prefisso = 'giorno:';

  static Future<PrefsDayStore> apri() async => PrefsDayStore._(await SharedPreferences.getInstance());

  @override
  Future<Map<String, Set<TipoCacca>>> leggiMese(int anno, int mese) async {
    final prefissoMese = '$_prefisso${isoMese(anno, mese)}';
    final risultato = <String, Set<TipoCacca>>{};
    for (final chiave in _prefs.getKeys()) {
      if (!chiave.startsWith(prefissoMese)) continue;
      final tipi = (_prefs.getString(chiave) ?? '')
          .split(',')
          .map(TipoCacca.daId)
          .whereType<TipoCacca>()
          .toSet();
      if (tipi.isNotEmpty) risultato[chiave.substring(_prefisso.length)] = tipi;
    }
    return risultato;
  }

  @override
  Future<void> scriviGiorno(String iso, Set<TipoCacca> tipi) async {
    final chiave = '$_prefisso$iso';
    if (tipi.isEmpty) {
      await _prefs.remove(chiave);
    } else {
      await _prefs.setString(chiave, ordinati(tipi).map((t) => t.name).join(','));
    }
  }
}
