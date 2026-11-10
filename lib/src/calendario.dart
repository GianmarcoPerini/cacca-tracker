import 'package:flutter/material.dart';

import 'colori.dart';
import 'date.dart';
import 'tipi.dart';

/// Intestazione con i giorni della settimana, da lunedì.
class IntestazioneSettimana extends StatelessWidget {
  const IntestazioneSettimana({super.key, this.spazio = 5});

  final double spazio;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Row(
        children: [
          for (var i = 0; i < 7; i++) ...[
            if (i > 0) SizedBox(width: spazio),
            Expanded(
              child: Text(
                giorniBrevi[i].toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: i >= 5 ? Colori.weekend : Colori.inchiostroTenue,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Griglia del mese. Usata sia nell'app (con [onTap]) sia nell'immagine esportata.
class GrigliaMese extends StatelessWidget {
  const GrigliaMese({
    super.key,
    required this.anno,
    required this.mese,
    required this.dati,
    required this.oggi,
    this.selezionato,
    this.onTap,
    this.spazio = 5,
    this.evidenziaOggi = true,
    this.adattaAltezza = false,
  });

  final int anno;
  final int mese;
  final Map<String, Set<TipoCacca>> dati;
  final DateTime oggi;
  final DateTime? selezionato;
  final ValueChanged<DateTime>? onTap;
  final double spazio;
  final bool evidenziaOggi;

  /// Se true, le celle si dividono l'altezza disponibile (senza superare la
  /// proporzione normale), così il calendario sta nello spazio che gli resta.
  /// Se false, ogni cella ha la proporzione fissa 1 : 1.12.
  final bool adattaAltezza;

  static const _proporzione = 1.12;

  @override
  Widget build(BuildContext context) {
    final vuote = celleVuoteIniziali(anno, mese);
    final giorni = giorniNelMese(anno, mese);
    final righe = ((vuote + giorni) / 7).ceil();

    Widget griglia(double? altezzaCella) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var r = 0; r < righe; r++) ...[
          if (r > 0) SizedBox(height: spazio),
          Row(
            children: [
              for (var c = 0; c < 7; c++) ...[
                if (c > 0) SizedBox(width: spazio),
                Expanded(child: _cella(r * 7 + c - vuote + 1, giorni, altezzaCella)),
              ],
            ],
          ),
        ],
      ],
    );

    if (!adattaAltezza) return griglia(null);
    return LayoutBuilder(
      builder: (context, vincoli) {
        final larghezzaCella = (vincoli.maxWidth - 6 * spazio) / 7;
        final naturale = larghezzaCella * _proporzione;
        final disponibile = (vincoli.maxHeight - (righe - 1) * spazio) / righe;
        return griglia(disponibile.isFinite ? disponibile.clamp(0.0, naturale) : naturale);
      },
    );
  }

  Widget _cella(int giorno, int giorni, double? altezza) {
    Widget dimensiona(Widget figlio) => altezza == null
        ? AspectRatio(aspectRatio: 1 / _proporzione, child: figlio)
        : SizedBox(height: altezza, child: figlio);

    if (giorno < 1 || giorno > giorni) return dimensiona(const SizedBox());
    final data = DateTime(anno, mese, giorno);
    return dimensiona(
      CellaGiorno(
        key: ValueKey('giorno-${isoData(data)}'),
        data: data,
        tipi: ordinati(dati[isoData(data)] ?? const {}),
        oggi: evidenziaOggi && stessoGiorno(data, oggi),
        selezionato: selezionato != null && stessoGiorno(data, selezionato!),
        futuro: isFuturo(data, oggi),
        onTap: onTap == null ? null : () => onTap!(data),
      ),
    );
  }
}

class CellaGiorno extends StatelessWidget {
  const CellaGiorno({
    super.key,
    required this.data,
    required this.tipi,
    required this.oggi,
    required this.selezionato,
    required this.futuro,
    this.onTap,
  });

  final DateTime data;
  final List<TipoCacca> tipi;
  final bool oggi;
  final bool selezionato;
  final bool futuro;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final registrato = tipi.isNotEmpty;
    final etichetta = StringBuffer('${data.day} ${mesi[data.month - 1]}');
    if (oggi) etichetta.write(', oggi');
    if (futuro) {
      etichetta.write(', non ancora registrabile');
    } else {
      etichetta.write(registrato ? ': ${tipi.map((t) => t.nome).join(', ')}' : ': nessuna registrazione');
    }

    return Semantics(
      button: onTap != null,
      selected: selezionato,
      enabled: !futuro,
      label: etichetta.toString(),
      excludeSemantics: true,
      child: LayoutBuilder(
        builder: (context, vincoli) {
          // Il giorno è un cerchio grande quanto il lato corto della cella.
          final lato = vincoli.maxHeight.isFinite
              ? (vincoli.maxHeight < vincoli.maxWidth ? vincoli.maxHeight : vincoli.maxWidth)
              : vincoli.maxWidth;
          final icona = (lato * 0.46).clamp(15.0, 24.0);
          final tocco = futuro ? null : onTap;
          // Tutta la cella resta toccabile, non solo il cerchio.
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: tocco,
            child: Center(
              child: SizedBox.square(
                dimension: lato,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Cerchio: colore tenue solo se il giorno è registrato, anello sottile se selezionato.
                    Positioned.fill(
                      child: Material(
                        color: registrato ? Colori.giornoRegistrato : Colors.transparent,
                        shape: CircleBorder(
                          side: selezionato
                              ? const BorderSide(color: Colori.rosaForte, width: 2)
                              : BorderSide.none,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: tocco,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 3),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    '${data.day}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      height: 1,
                                      fontWeight: futuro ? FontWeight.w700 : FontWeight.w800,
                                      fontFeatures: const [FontFeature.tabularFigures()],
                                      color: futuro ? Colori.futuro : Colori.inchiostro,
                                    ),
                                  ),
                                ),
                              ),
                              // Oggi: pallina sul fondo del cerchio, sotto il numero.
                              if (oggi)
                                Positioned(
                                  bottom: lato * 0.1,
                                  child: Container(
                                    width: 5,
                                    height: 5,
                                    decoration: const BoxDecoration(
                                      color: Colori.rosaForte,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Adesivo: le icone sull'angolo in alto a destra, un po' fuori dalla casella.
                    if (registrato)
                      Positioned(
                        top: -icona * 0.35,
                        right: -icona * 0.45,
                        child: IgnorePointer(
                          child: _Adesivo(tipi: tipi, lato: icona),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Le icone del giorno sovrapposte come adesivi, con un bordino bianco.
class _Adesivo extends StatelessWidget {
  const _Adesivo({required this.tipi, required this.lato});

  final List<TipoCacca> tipi;
  final double lato;

  @override
  Widget build(BuildContext context) {
    final passo = lato * 0.5; // la seconda icona copre in parte la prima
    return SizedBox(
      width: lato + passo * (tipi.length - 1),
      height: lato,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (var i = 0; i < tipi.length; i++)
            Positioned(
              left: passo * i,
              top: 0,
              child: _Icona(tipo: tipi[i], lato: lato),
            ),
        ],
      ),
    );
  }
}

class _Icona extends StatelessWidget {
  const _Icona({required this.tipo, required this.lato});

  final TipoCacca tipo;
  final double lato;

  @override
  Widget build(BuildContext context) {
    final immagine = Image.asset(tipo.asset, width: lato, height: lato, filterQuality: FilterQuality.medium);
    return SizedBox(
      width: lato,
      height: lato,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Sagoma bianca leggermente più grande: fa da bordo dell'adesivo.
          Transform.scale(
            scale: 1.14,
            child: Image.asset(
              tipo.asset,
              width: lato,
              height: lato,
              color: Colors.white,
              colorBlendMode: BlendMode.srcIn,
            ),
          ),
          immagine,
        ],
      ),
    );
  }
}
