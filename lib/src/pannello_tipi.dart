import 'package:flutter/material.dart';

import 'colori.dart';
import 'tipi.dart';

/// I 7 bottoni dei tipi: due colonne (un tipo per colonna) e "Niente" in fondo.
class PannelloTipi extends StatelessWidget {
  const PannelloTipi({super.key, required this.selezionati, required this.onToggle});

  final Set<TipoCacca> selezionati;
  final ValueChanged<TipoCacca> onToggle;

  @override
  Widget build(BuildContext context) {
    final sinistra = TipoCacca.diColonna(1);
    final destra = TipoCacca.diColonna(2);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < sinistra.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _bottone(sinistra[i])),
              const SizedBox(width: 8),
              Expanded(child: _bottone(destra[i])),
            ],
          ),
        ],
        // Spazio un po' più ampio: "Niente" esclude tutti gli altri tipi.
        const SizedBox(height: 14),
        _bottone(TipoCacca.niente),
      ],
    );
  }

  Widget _bottone(TipoCacca t) => BottoneTipo(
        key: ValueKey('tipo-${t.name}'),
        tipo: t,
        attivo: selezionati.contains(t),
        onTap: () => onToggle(t),
      );
}


class BottoneTipo extends StatelessWidget {
  const BottoneTipo({super.key, required this.tipo, required this.attivo, required this.onTap});

  final TipoCacca tipo;
  final bool attivo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      toggled: attivo,
      label: tipo.nome,
      excludeSemantics: true,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: attivo
              ? const [BoxShadow(color: Color(0x4745365A), offset: Offset(0, 3))]
              : null,
        ),
        child: Material(
          color: attivo ? tipo.colore : Colori.superficie,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: attivo ? Colori.inchiostro : Colori.linea, width: 2),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 46),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(5, 4, 8, 4),
                child: Row(
                  children: [
                    // Icona con la spunta sull'angolo quando il tipo è attivo.
                    SizedBox(
                      width: 38,
                      height: 38,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            padding: const EdgeInsets.all(1),
                            decoration: BoxDecoration(
                              color: attivo ? const Color(0x99FFFFFF) : const Color(0xFFFBF7FB),
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: Image.asset(tipo.asset, fit: BoxFit.contain),
                          ),
                          if (attivo)
                            Positioned(
                              right: -4,
                              top: -4,
                              child: Container(
                                width: 18,
                                height: 18,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colori.inchiostro,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: const Icon(Icons.check_rounded, size: 12, color: Colors.white),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        tipo.nome,
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.fade,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colori.inchiostro,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
