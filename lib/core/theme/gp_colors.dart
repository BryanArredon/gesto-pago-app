import 'package:flutter/material.dart';

/// Paleta de colores de Gesto Pago.
/// Diseño moderno, profesional y limpio estilo FinTech.
abstract final class GpColors {
  static const Color seed = Color(0xFF1A56DB);

  // Color primario de marca (Azul Real / Cobalto moderno).
  static const Color primario = Color(0xFF1A56DB);
  static const Color verde = Color(0xFF1A56DB); // Alias para compatibilidad
  static const Color sobrePrimario = Colors.white;
  static const Color sobreVerde = Colors.white;
  static const Color primarioClaro = Color(0xFF3B82F6);
  static const Color verdeClaro = Color(0xFF3B82F6);
  static const Color primarioOscuro = Color(0xFF1E3A8A);
  static const Color esmeraldaOscuro = Color(0xFF1E3A8A);

  // Neutros claros.
  static const Color fondoClaro = Color(0xFFF8FAFC);
  static const Color superficieClara = Colors.white;
  static const Color bordeClaro = Color(0xFFE2E8F0);
  static const Color textoClaro = Color(0xFF0F172A);
  static const Color textoSuaveClaro = Color(0xFF64748B);

  // Neutros oscuros.
  static const Color fondoOscuro = Color(0xFF0B1120);
  static const Color superficieOscura = Color(0xFF1E293B);
  static const Color bordeOscuro = Color(0xFF334155);
  static const Color textoOscuro = Color(0xFFF8FAFC);
  static const Color textoSuaveOscuro = Color(0xFF94A3B8);

  // Estados.
  static const Color exito = Color(0xFF16A34A);
  static const Color exitoClaro = Color(0xFFDCFCE7);
  static const Color exitoOscuro = Color(0xFF4ADE80);
  static const Color error = Color(0xFFDC2626);
  static const Color errorClaro = Color(0xFFFEE2E2);
  static const Color errorOscuro = Color(0xFFF87171);
  static const Color proceso = Color(0xFFD97706);
  static const Color procesoClaro = Color(0xFFFEF3C7);
  static const Color procesoOscuro = Color(0xFFFBBF24);
  static const Color neutro = Color(0xFF64748B);

  // Acento.
  static const Color acentoAmarillo = Color(0xFFF59E0B);
}