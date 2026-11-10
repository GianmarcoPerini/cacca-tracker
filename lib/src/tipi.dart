import 'package:flutter/painting.dart';

/// I 7 tipi di registrazione.
///
/// [colonna] è la colonna del pannello: si può scegliere al massimo un tipo
/// per colonna. La colonna 0 è "Niente", che esclude tutti gli altri tipi.
/// L'ordine dei valori è anche l'ordine in cui le icone compaiono nelle celle.
enum TipoCacca {
  regolare('Regolare', Color(0xFFBFEBD5), 1),
  tanta('Tanta', Color(0xFFFFC2D9), 1),
  poca('Poca', Color(0xFFFFEFA6), 1),
  dura('Dura', Color(0xFFD7C6F2), 2),
  liquida('Liquida', Color(0xFFBEE2F6), 2),
  morbida('Morbida', Color(0xFFFFD2B5), 2),
  niente('Niente', Color(0xFFE4E1EC), 0);

  const TipoCacca(this.nome, this.colore, this.colonna);

  final String nome;
  final Color colore;
  final int colonna;

  String get asset => 'assets/icons/$name.png';

  static List<TipoCacca> diColonna(int colonna) =>
      values.where((t) => t.colonna == colonna).toList();

  /// Converte l'id salvato nel database; ignora gli id sconosciuti.
  static TipoCacca? daId(String id) {
    for (final t in values) {
      if (t.name == id) return t;
    }
    return null;
  }
}

/// Applica il tocco su [tipo] alla selezione [attuali] e restituisce la nuova selezione.
///
/// - Se il tipo era attivo, si spegne.
/// - "Niente" spegne tutti gli altri tipi.
/// - Un altro tipo spegne "Niente" e il tipo già scelto nella sua stessa colonna.
Set<TipoCacca> toggleTipo(Set<TipoCacca> attuali, TipoCacca tipo) {
  if (attuali.contains(tipo)) return {...attuali}..remove(tipo);
  if (tipo == TipoCacca.niente) return {TipoCacca.niente};
  return {
    for (final t in attuali)
      if (t != TipoCacca.niente && t.colonna != tipo.colonna) t,
    tipo,
  };
}

/// I tipi nell'ordine di visualizzazione.
List<TipoCacca> ordinati(Iterable<TipoCacca> tipi) {
  final s = tipi.toSet();
  return TipoCacca.values.where(s.contains).toList();
}
