import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/gp_theme.dart';

/// Fondo con degradado azul de las pantallas de acceso (login, 2FA, registro).
class FondoAuth extends StatelessWidget {
  const FondoAuth({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final oscuro = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: oscuro
                    ? const [Color(0xFF020617), Color(0xFF0F172A), Color(0xFF1E293B)]
                    : const [Color(0xFF0F172A), Color(0xFF1E3A8A), Color(0xFF1D4ED8)],
              ),
            ),
          ),
        ),
        const Positioned(top: -60, right: -60, child: _Halo(color: Color(0x3338BDF8), size: 240)),
        const Positioned(bottom: -80, left: -80, child: _Halo(color: Color(0x406366F1), size: 280)),
        SafeArea(child: child),
      ],
    );
  }
}

/// Tarjeta translúcida (glassmorphism) que contiene los formularios de acceso.
class TarjetaAuth extends StatelessWidget {
  const TarjetaAuth({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final oscuro = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(GpRadii.dialogo),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          padding: const EdgeInsets.all(GpSpacing.xl),
          decoration: BoxDecoration(
            color: oscuro ? const Color(0xE6161D1A) : const Color(0xF2FFFFFF),
            borderRadius: BorderRadius.circular(GpRadii.dialogo),
            border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.14), blurRadius: 36, offset: const Offset(0, 16)),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _Halo extends StatelessWidget {
  const _Halo({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, Colors.transparent]),
      ),
    );
  }
}

/// Aviso con icono para errores o mensajes informativos en formularios.
class AvisoBanner extends StatelessWidget {
  const AvisoBanner({super.key, required this.mensaje, this.esError = true, this.icono});

  final String mensaje;
  final bool esError;
  final IconData? icono;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = esError ? scheme.error : const Color(0xFFB45309);
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(GpSpacing.md),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(GpRadii.campo),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Icon(icono ?? (esError ? Icons.error_outline : Icons.info_outline), color: color, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(mensaje, style: TextStyle(color: color)),
            ),
          ],
        ),
      ),
    );
  }
}
