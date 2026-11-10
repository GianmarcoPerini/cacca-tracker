const mesi = [
  'gennaio', 'febbraio', 'marzo', 'aprile', 'maggio', 'giugno',
  'luglio', 'agosto', 'settembre', 'ottobre', 'novembre', 'dicembre',
];

/// Intestazione della griglia: la settimana parte da lunedì.
const giorniBrevi = ['Lun', 'Mar', 'Mer', 'Gio', 'Ven', 'Sab', 'Dom'];

/// Nomi completi indicizzati da [DateTime.weekday] - 1 (lunedì = 0).
const giorniLunghi = [
  'lunedì', 'martedì', 'mercoledì', 'giovedì', 'venerdì', 'sabato', 'domenica',
];

String maiuscola(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

String _due(int n) => n.toString().padLeft(2, '0');

/// Data ISO "YYYY-MM-DD" del giorno locale, chiave usata per salvare i dati.
String isoData(DateTime d) => '${d.year.toString().padLeft(4, '0')}-${_due(d.month)}-${_due(d.day)}';

/// Prefisso ISO del mese, es. "2026-11-".
String isoMese(int anno, int mese) => '${anno.toString().padLeft(4, '0')}-${_due(mese)}-';

DateTime soloData(DateTime d) => DateTime(d.year, d.month, d.day);

bool stessoGiorno(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

bool isFuturo(DateTime giorno, DateTime oggi) => soloData(giorno).isAfter(soloData(oggi));

/// Celle vuote prima del giorno 1, con la settimana che parte da lunedì.
int celleVuoteIniziali(int anno, int mese) => DateTime(anno, mese, 1).weekday - 1;

int giorniNelMese(int anno, int mese) => DateTime(anno, mese + 1, 0).day;
