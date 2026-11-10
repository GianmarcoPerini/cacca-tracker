# Caccalendario

App Flutter (Android, iOS e web) per segnare i giorni in cui vai in bagno, con un calendario mensile e icone kawaii.

- Calendario con la settimana che parte da lunedì. Si cambia mese con le frecce o con uno swipe. Non si possono registrare i giorni futuri.
- 7 tipi in due colonne: Regolare, Tanta e Poca; Dura, Liquida e Morbida. Si sceglie al massimo un tipo per colonna. "Niente" esclude tutti gli altri.
- I dati restano solo sul dispositivo: SQLite sul telefono (`lib/src/day_store.dart`), lo storage del browser nella versione web (`lib/src/day_store_web.dart`).
- Il bottone in alto esporta il mese come PNG, con la legenda, e apre il menu Condividi.

## Sviluppo

Flutter è in `C:\flutter`:

```bash
C:/flutter/bin/flutter test
C:/flutter/bin/flutter run
```

Le icone dei tipi sono in `assets/icons/`, ritagliate dal set "Style A - Set 3". Il corpo di ogni icona è ricolorato con la tinta del suo tipo, così i tipi si distinguono anche in piccolo: lo script è `tool/ricolora_icone.py` e parte dalle PNG originali (menta o beige). L'icona dell'app si rigenera con `dart run flutter_launcher_icons`.

## Versione web (iPhone senza App Store)

A ogni push su `main` il workflow `.github/workflows/pages.yml` compila la versione web e la pubblica su GitHub Pages:
https://gianmarcoperini.github.io/cacca-tracker/

Sull'iPhone: apri l'indirizzo con Safari, poi Condividi → Aggiungi alla schermata Home. Nel browser "Salva" diventa "Scarica".
