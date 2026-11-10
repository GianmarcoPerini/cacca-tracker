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
  });

  final int anno;
  final int mese;
  final Map<String, Set<TipoCacca>> dati;
  final DateTime oggi;
  final DateTime? selezionato;
  final ValueChanged<DateTime>? onTap;
  final double spazio;
  final bool evidenziaOggi;

  @override
  Widget build(BuildContext context) {
    final vuote = celleVuoteIniziali(anno, mese);
    final giorni = giorniNelMese(anno, mese);
    final righe = ((vuote + giorni) / 7).ceil();
    return Column(
      children: [
        for (var r = 0; r < righe; r++) ...[
          if (r > 0) SizedBox(height: spazio),
          Row(
            children: [
              for (var c = 0; c < 7; c++) ...[
                if (c > 0) SizedBox(width: spazio),
                Expanded(child: _cella(r * 7 + c - vuote + 1, giorni)),
              ],
            ],
          ),
        ],
      ],
    );
  }

  Widget _cella(int giorno, int giorni) {
    if (giorno < 1 || giorno > giorni) {
      return const AspectRatio(aspectRatio: 1 / 1.12, child: SizedBox());
    }
    final data = DateTime(anno, mese, giorno);
    return CellaGiorno(
      key: ValueKey('giorno-${isoData(data)}'),
      data: data,
      tipi: ordinati(dati[isoData(data)] ?? const {}),
      oggi: evidenziaOggi && stessoGiorno(data, oggi),
      selezionato: selezionato != null && stessoGiorno(data, selezionato!),
      futuro: isFuturo(data, oggi),
      onTap: onTap == null ? null : () => onTap!(data),
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
    final sfondo = selezionato
        ? Colori.lilla
        : futuro
            ? Colors.transparent
            : oggi
                ? Colori.cellaOggi
                : Colori.cella;
    final etichetta = StringBuffer('${data.day} ${mesi[data.month - 1]}');
    if (oggi) etichetta.write(', oggi');
    if (futuro) {
      etichetta.write(', non ancora registrabile');
    } else {
      etichetta.write(tipi.isEmpty
          ? ': nessuna registrazione'
          : ': ${tipi.map((t) => t.nome).join(', ')}');
    }

    return Semantics(
      button: onTap != null,
      selected: selezionato,
      enabled: !futuro,
      label: etichetta.toString(),
      excludeSemantics: true,
      child: AspectRatio(
        aspectRatio: 1 / 1.12,
        child: Material(
          color: sfondo,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(raggioPiccolo),
            side: BorderSide(
              color: selezionato ? Colori.inchiostro : Colors.transparent,
              width: 2,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: futuro ? null : onTap,
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Numero(giorno: data.day, oggi: oggi, futuro: futuro),
                  Expanded(child: _Icone(tipi: tipi)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Numero extends StatelessWidget {
  const _Numero({required this.giorno, required this.oggi, required this.futuro});

  final int giorno;
  final bool oggi;
  final bool futuro;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: oggi
          ? const BoxDecoration(color: Colori.rosaForte, shape: BoxShape.circle)
          : null,
      child: Text(
        '$giorno',
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          height: 1,
          fontFeatures: const [FontFeature.tabularFigures()],
          color: oggi
              ? Colors.white
              : futuro
                  ? Colori.futuro
                  : Colori.inchiostro,
        ),
      ),
    );
  }
}

class _Icone extends StatelessWidget {
  const _Icone({required this.tipi});

  final List<TipoCacca> tipi;

  @override
  Widget build(BuildContext context) {
    if (tipi.isEmpty) return const SizedBox.expand();
    return Padding(
      padding: const EdgeInsets.fromLTRB(1, 1, 1, 2),
      child: Row(
        children: [
          for (final t in tipi)
            Expanded(
              child: Image.asset(t.asset, fit: BoxFit.contain, filterQuality: FilterQuality.medium),
            ),
        ],
      ),
    );
  }
}
