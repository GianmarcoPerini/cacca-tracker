import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'calendario.dart';
import 'colori.dart';
import 'date.dart';
import 'tipi.dart';

/// Larghezza logica dell'immagine; con pixelRatio 3 diventa 1080 px.
const _larghezza = 360.0;
const _pixelRatio = 3.0;

/// Mostra l'anteprima del mese e la condivide come PNG con il menu Condividi.
Future<void> mostraEsportazione(
  BuildContext context, {
  required int anno,
  required int mese,
  required Map<String, Set<TipoCacca>> dati,
  required DateTime oggi,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => _DialogoEsporta(anno: anno, mese: mese, dati: dati, oggi: oggi),
  );
}

class _DialogoEsporta extends StatefulWidget {
  const _DialogoEsporta({required this.anno, required this.mese, required this.dati, required this.oggi});

  final int anno;
  final int mese;
  final Map<String, Set<TipoCacca>> dati;
  final DateTime oggi;

  @override
  State<_DialogoEsporta> createState() => _DialogoEsportaState();
}

class _DialogoEsportaState extends State<_DialogoEsporta> {
  final _chiaveImmagine = GlobalKey();
  final _chiaveBottone = GlobalKey();
  bool _inCorso = false;
  String? _errore;

  String get _nomeFile => 'caccalendario-${isoMese(widget.anno, widget.mese).substring(0, 7)}';

  Future<Uint8List> _creaPng() async {
    final boundary = _chiaveImmagine.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final immagine = await boundary.toImage(pixelRatio: _pixelRatio);
    final byte = await immagine.toByteData(format: ui.ImageByteFormat.png);
    immagine.dispose();
    return byte!.buffer.asUint8List();
  }

  /// Esegue [azione] mostrando l'attesa; in caso di errore mostra [messaggioErrore].
  Future<void> _esegui(Future<void> Function() azione, String Function(Object) messaggioErrore) async {
    setState(() {
      _inCorso = true;
      _errore = null;
    });
    try {
      await azione();
    } catch (e) {
      if (mounted) setState(() => _errore = messaggioErrore(e));
    } finally {
      if (mounted) setState(() => _inCorso = false);
    }
  }

  Future<void> _condividi() => _esegui(() async {
        final file = File(p.join((await getTemporaryDirectory()).path, '$_nomeFile.png'));
        await file.writeAsBytes(await _creaPng(), flush: true);

        // Su iPad il menu Condividi ha bisogno di un punto di ancoraggio.
        final box = _chiaveBottone.currentContext?.findRenderObject() as RenderBox?;
        final origine = box == null ? null : box.localToGlobal(Offset.zero) & box.size;

        await SharePlus.instance.share(ShareParams(
          files: [XFile(file.path, mimeType: 'image/png')],
          subject: 'Caccalendario · ${maiuscola(mesi[widget.mese - 1])} ${widget.anno}',
          sharePositionOrigin: origine,
        ));
        if (mounted) Navigator.of(context).pop();
      }, (_) => "Non sono riuscito a creare l'immagine. Riprova.");

  Future<void> _salva() => _esegui(() async {
        if (!await Gal.hasAccess() && !await Gal.requestAccess()) {
          throw const _PermessoNegato();
        }
        await Gal.putImageBytes(await _creaPng(), name: _nomeFile);
        if (!mounted) return;
        final messenger = ScaffoldMessenger.of(context);
        Navigator.of(context).pop();
        messenger.showSnackBar(const SnackBar(content: Text('Immagine salvata nella galleria.')));
      }, (e) => e is _PermessoNegato || (e is GalException && e.type == GalExceptionType.accessDenied)
          ? "Per salvare serve il permesso alla galleria. Puoi darlo dalle impostazioni del telefono."
          : "Non sono riuscito a salvare l'immagine. Riprova.");

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colori.superficie,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(raggioGrande)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Esporta il mese',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colori.inchiostro),
                  ),
                ),
                IconButton(
                  tooltip: 'Chiudi',
                  onPressed: _inCorso ? null : () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, color: Colori.inchiostro),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Flexible(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(raggioMedio),
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: RepaintBoundary(
                    key: _chiaveImmagine,
                    child: ImmagineMese(
                      anno: widget.anno,
                      mese: widget.mese,
                      dati: widget.dati,
                      oggi: widget.oggi,
                    ),
                  ),
                ),
              ),
            ),
            if (_errore != null) ...[
              const SizedBox(height: 10),
              Text(_errore!, style: const TextStyle(color: Colori.weekend, fontWeight: FontWeight.w600)),
            ],
            const SizedBox(height: 14),
            if (_inCorso) ...[
              const LinearProgressIndicator(minHeight: 3),
              const SizedBox(height: 8),
            ],
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    key: const ValueKey('salva'),
                    onPressed: _inCorso ? null : _salva,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      side: const BorderSide(color: Colori.inchiostro, width: 2),
                    ),
                    icon: const Icon(Icons.download_rounded),
                    label: const Text('Salva'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    key: _chiaveBottone,
                    onPressed: _inCorso ? null : _condividi,
                    style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                    icon: const Icon(Icons.ios_share_rounded),
                    label: const Text('Condividi'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PermessoNegato implements Exception {
  const _PermessoNegato();
}

/// Il contenuto dell'immagine esportata: mese e anno, calendario e legenda.
class ImmagineMese extends StatelessWidget {
  const ImmagineMese({
    super.key,
    required this.anno,
    required this.mese,
    required this.dati,
    required this.oggi,
  });

  final int anno;
  final int mese;
  final Map<String, Set<TipoCacca>> dati;
  final DateTime oggi;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colori.sfondo,
      child: SizedBox(
        width: _larghezza,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '${maiuscola(mesi[mese - 1])} $anno',
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colori.inchiostro),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colori.superficie,
                  borderRadius: BorderRadius.circular(raggioMedio),
                ),
                child: Column(
                  children: [
                    const IntestazioneSettimana(spazio: 4),
                    const SizedBox(height: 6),
                    GrigliaMese(
                      anno: anno,
                      mese: mese,
                      dati: dati,
                      oggi: oggi,
                      spazio: 4,
                      evidenziaOggi: false,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final t in TipoCacca.values)
                    Container(
                      padding: const EdgeInsets.fromLTRB(4, 3, 10, 3),
                      decoration: BoxDecoration(
                        color: t.colore,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(t.asset, width: 24, height: 24),
                          const SizedBox(width: 4),
                          Text(
                            t.nome,
                            style: const TextStyle(
                                fontSize: 12.5, fontWeight: FontWeight.w700, color: Colori.inchiostro),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
