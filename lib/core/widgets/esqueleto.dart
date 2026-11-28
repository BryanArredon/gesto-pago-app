import 'package:flutter/material.dart';

/// Bloque de carga con la forma del contenido final, para que la pantalla no
/// "salte" al llegar los datos. Pulsa suavemente salvo que el sistema pida
/// reducir el movimiento.
class Esqueleto extends StatefulWidget {
  const Esqueleto({super.key, this.ancho, required this.alto, this.radio = 8, this.color});

  final double? ancho;
  final double alto;
  final double radio;

  /// Color base; por defecto se deriva del tema (claro u oscuro).
  final Color? color;

  @override
  State<Esqueleto> createState() => _EsqueletoState();
}

class _EsqueletoState extends State<Esqueleto> with SingleTickerProviderStateMixin {
  late final AnimationController _pulso = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
    lowerBound: 0.45,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _pulso.value = 0.7;
      _pulso.stop();
    } else if (!_pulso.isAnimating) {
      _pulso.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulso.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = widget.color ?? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08);
    return ExcludeSemantics(
      child: FadeTransition(
        opacity: _pulso,
        child: Container(
          width: widget.ancho,
          height: widget.alto,
          decoration: BoxDecoration(color: base, borderRadius: BorderRadius.circular(widget.radio)),
        ),
      ),
    );
  }
}

/// Lista de movimientos en carga (historial, compras recientes).
class EsqueletoLista extends StatelessWidget {
  const EsqueletoLista({super.key, this.filas = 5, required this.etiqueta});

  final int filas;

  /// Lo que anuncia el lector de pantalla mientras carga.
  final String etiqueta;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: etiqueta,
      liveRegion: true,
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        itemCount: filas,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (_, _) => Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: scheme.outline),
          ),
          child: const Row(
            children: [
              Esqueleto(ancho: 40, alto: 40, radio: 12),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FractionallySizedBox(widthFactor: 0.6, child: Esqueleto(alto: 14)),
                    SizedBox(height: 8),
                    FractionallySizedBox(widthFactor: 0.35, child: Esqueleto(alto: 11)),
                  ],
                ),
              ),
              SizedBox(width: 12),
              Esqueleto(ancho: 64, alto: 16),
            ],
          ),
        ),
      ),
    );
  }
}
