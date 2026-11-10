import 'package:flutter/material.dart';

import 'calendario.dart';
import 'colori.dart';
import 'date.dart';
import 'day_store.dart';
import 'esporta.dart';
import 'pannello_tipi.dart';
import 'tipi.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.store, this.orologio = DateTime.now});

  final DayStore store;

  /// Fonte della data di oggi; nei test si passa una data fissa.
  final DateTime Function() orologio;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late int _anno;
  late int _mese;
  late DateTime _selezionato;
  Map<String, Set<TipoCacca>> _dati = {};
  bool _caricato = false;

  /// Conta le letture: una risposta arrivata dopo un cambio di mese viene ignorata.
  int _lettura = 0;

  DateTime get _oggi => soloData(widget.orologio());

  @override
  void initState() {
    super.initState();
    final oggi = _oggi;
    _anno = oggi.year;
    _mese = oggi.month;
    _selezionato = oggi;
    _carica();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    for (final t in TipoCacca.values) {
      precacheImage(AssetImage(t.asset), context);
    }
  }

  Future<void> _carica() async {
    final lettura = ++_lettura;
    try {
      final dati = await widget.store.leggiMese(_anno, _mese);
      if (!mounted || lettura != _lettura) return;
      setState(() {
        _dati = dati;
        _caricato = true;
      });
    } catch (_) {
      if (!mounted || lettura != _lettura) return;
      setState(() => _caricato = true);
      _avvisa('Non riesco a leggere i dati salvati. Chiudi e riapri l\'app.');
    }
  }

  void _cambiaMese(int delta) {
    final d = DateTime(_anno, _mese + delta);
    setState(() {
      _anno = d.year;
      _mese = d.month;
      _dati = {};
      _caricato = false;
    });
    _carica();
  }

  void _tornaAOggi() {
    final oggi = _oggi;
    final stessoMese = oggi.year == _anno && oggi.month == _mese;
    setState(() => _selezionato = oggi);
    if (!stessoMese) _cambiaMese((oggi.year - _anno) * 12 + oggi.month - _mese);
  }

  bool get _selezioneVisibile => _selezionato.year == _anno && _selezionato.month == _mese;

  Future<void> _toggle(TipoCacca tipo) async {
    if (isFuturo(_selezionato, _oggi)) return;
    final iso = isoData(_selezionato);
    final prima = _dati[iso] ?? const <TipoCacca>{};
    final dopo = toggleTipo(prima, tipo);
    final eraVisibile = _selezioneVisibile;
    setState(() {
      if (eraVisibile) {
        if (dopo.isEmpty) {
          _dati.remove(iso);
        } else {
          _dati[iso] = dopo;
        }
      }
    });
    try {
      await widget.store.scriviGiorno(iso, dopo);
    } catch (_) {
      _avvisa('Non sono riuscito a salvare. Riprova.');
      _carica();
    }
  }

  void _avvisa(String testo) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(testo)));
  }

  void _esporta() {
    mostraEsportazione(context, anno: _anno, mese: _mese, dati: Map.of(_dati), oggi: _oggi);
  }

  @override
  Widget build(BuildContext context) {
    final oggi = _oggi;
    final calendario = _CardCalendario(
      anno: _anno,
      mese: _mese,
      dati: _dati,
      oggi: oggi,
      selezionato: _selezionato,
      caricato: _caricato,
      mostraOggi: !(oggi.year == _anno && oggi.month == _mese),
      onCambiaMese: _cambiaMese,
      onOggi: _tornaAOggi,
      onTapGiorno: (d) => setState(() => _selezionato = d),
    );
    final pannello = _Card(
      child: _selezioneVisibile || !_caricato
          ? PannelloTipi(
              selezionati: _selezioneVisibile ? (_dati[isoData(_selezionato)] ?? const {}) : const {},
              onToggle: _selezioneVisibile ? _toggle : (_) {},
            )
          : const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'Tocca un giorno di questo mese per registrarlo.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colori.inchiostroTenue, fontWeight: FontWeight.w600),
              ),
            ),
    );

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, vincoli) {
            final largo = vincoli.maxWidth >= 840;
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1040),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _Testata(onEsporta: _esporta),
                      const SizedBox(height: 16),
                      if (largo)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 13, child: calendario),
                            const SizedBox(width: 18),
                            Expanded(flex: 10, child: pannello),
                          ],
                        )
                      else ...[
                        calendario,
                        const SizedBox(height: 18),
                        pannello,
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Testata extends StatelessWidget {
  const _Testata({required this.onEsporta});

  final VoidCallback onEsporta;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ExcludeSemantics(child: Image.asset(TipoCacca.regolare.asset, width: 52, height: 52)),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            'Tracker Cacca',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colori.inchiostro, height: 1.1),
          ),
        ),
        _BottoneTondo(
          icona: Icons.ios_share_rounded,
          etichetta: 'Esporta il mese come immagine',
          onTap: onEsporta,
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colori.superficie,
        borderRadius: BorderRadius.circular(raggioGrande),
        boxShadow: ombraCard,
      ),
      child: child,
    );
  }
}

class _CardCalendario extends StatelessWidget {
  const _CardCalendario({
    required this.anno,
    required this.mese,
    required this.dati,
    required this.oggi,
    required this.selezionato,
    required this.caricato,
    required this.mostraOggi,
    required this.onCambiaMese,
    required this.onOggi,
    required this.onTapGiorno,
  });

  final int anno;
  final int mese;
  final Map<String, Set<TipoCacca>> dati;
  final DateTime oggi;
  final DateTime selezionato;
  final bool caricato;
  final bool mostraOggi;
  final ValueChanged<int> onCambiaMese;
  final VoidCallback onOggi;
  final ValueChanged<DateTime> onTapGiorno;

  @override
  Widget build(BuildContext context) {
    final spazio = MediaQuery.sizeOf(context).width >= 560 ? 8.0 : 5.0;
    return _Card(
      child: GestureDetector(
        // Swipe orizzontale per cambiare mese, oltre alle frecce.
        onHorizontalDragEnd: (d) {
          final v = d.primaryVelocity ?? 0;
          if (v.abs() < 250) return;
          onCambiaMese(v < 0 ? 1 : -1);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                _BottoneTondo(
                  key: const ValueKey('mese-precedente'),
                  icona: Icons.chevron_left_rounded,
                  etichetta: 'Mese precedente',
                  onTap: () => onCambiaMese(-1),
                ),
                Expanded(
                  child: Semantics(
                    liveRegion: true,
                    child: Text(
                      maiuscola(mesi[mese - 1]),
                      key: const ValueKey('titolo-mese'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w800, color: Colori.inchiostro),
                    ),
                  ),
                ),
                _BottoneTondo(
                  key: const ValueKey('mese-successivo'),
                  icona: Icons.chevron_right_rounded,
                  etichetta: 'Mese successivo',
                  onTap: () => onCambiaMese(1),
                ),
              ],
            ),
            if (mostraOggi)
              Center(
                child: TextButton(
                  onPressed: onOggi,
                  child: const Text(
                    'Torna a oggi',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colori.inchiostro,
                      decoration: TextDecoration.underline,
                      decorationColor: Colori.rosaForte,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 10),
            IntestazioneSettimana(spazio: spazio),
            const SizedBox(height: 6),
            AnimatedOpacity(
              opacity: caricato ? 1 : 0.5,
              duration: const Duration(milliseconds: 120),
              child: GrigliaMese(
                anno: anno,
                mese: mese,
                dati: dati,
                oggi: oggi,
                selezionato: selezionato,
                onTap: onTapGiorno,
                spazio: spazio,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottoneTondo extends StatelessWidget {
  const _BottoneTondo({super.key, required this.icona, required this.etichetta, required this.onTap});

  final IconData icona;
  final String etichetta;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: etichetta,
      child: Material(
        color: Colori.frecciaSfondo,
        shape: const CircleBorder(side: BorderSide(color: Colori.frecciaBordo, width: 2)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: 48,
            height: 48,
            child: Icon(icona, color: Colori.inchiostro, size: 28, semanticLabel: etichetta),
          ),
        ),
      ),
    );
  }
}
