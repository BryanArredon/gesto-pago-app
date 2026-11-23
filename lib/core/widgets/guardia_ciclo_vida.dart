import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/application/session_controller.dart';
import '../theme/gp_assets.dart';

/// Protección de la app al cambiar de primer a segundo plano (MASVS-PLATFORM):
///
/// * Al quedar inactiva cubre el contenido para que la miniatura del selector
///   de apps no muestre saldos ni datos personales.
/// * Al volver comprueba con el servidor que la sesión siga vigente: si se
///   inició sesión en la web o venció por inactividad, sale de inmediato.
class GuardiaCicloVida extends ConsumerStatefulWidget {
  const GuardiaCicloVida({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<GuardiaCicloVida> createState() => _GuardiaCicloVidaState();
}

class _GuardiaCicloVidaState extends ConsumerState<GuardiaCicloVida> with WidgetsBindingObserver {
  bool _cubierta = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final cubrir =
        state == AppLifecycleState.inactive || state == AppLifecycleState.paused || state == AppLifecycleState.hidden;
    if (cubrir != _cubierta) {
      setState(() => _cubierta = cubrir);
    }
    if (state == AppLifecycleState.resumed) {
      ref.read(sessionControllerProvider.notifier).verificarAlReanudar();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      textDirection: TextDirection.ltr,
      children: [
        widget.child,
        if (_cubierta)
          Positioned.fill(
            child: ColoredBox(
              color: const Color(0xFF1E3A8A),
              child: Center(
                child: Image.asset(GpAssets.logo, width: 96, height: 96, errorBuilder: (_, _, _) => const SizedBox()),
              ),
            ),
          ),
      ],
    );
  }
}
