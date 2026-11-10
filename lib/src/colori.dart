import 'package:flutter/painting.dart';

/// Palette kawaii pastello (una sola versione chiara, come deciso).
abstract final class Colori {
  static const sfondo = Color(0xFFFFF5F9);
  static const superficie = Color(0xFFFFFFFF);
  static const inchiostro = Color(0xFF45365A); // testo principale
  static const inchiostroTenue = Color(0xFF6E5E80); // testo secondario, ~5.5:1 sul bianco
  static const linea = Color(0xFFF0DDEA);
  static const rosaForte = Color(0xFFF27BA6);
  static const lilla = Color(0xFFE3D6FA);
  static const menta = Color(0xFFC6EEDD);
  static const giornoRegistrato = Color(0xFFF6EEFA); // unico colore tenue dei giorni registrati
  static const weekend = Color(0xFFB0457A);
  static const futuro = Color(0xFFA99BB6);
  static const frecciaSfondo = Color(0xFFFDF0F6);
  static const frecciaBordo = Color(0xFFF3DCE8);
  static const ombra = Color(0x1F965A8C);
}

const raggioGrande = 28.0;
const raggioMedio = 20.0;
const raggioPiccolo = 14.0;

const ombraCard = [
  BoxShadow(color: Colori.ombra, blurRadius: 18, offset: Offset(0, 6)),
];
