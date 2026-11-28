import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/application/session_controller.dart';
import '../../features/notificaciones/application/notificaciones_controller.dart';
import '../config/app_config.dart';
import '../providers/app_providers.dart';
import '../theme/gp_assets.dart';

/// Protección de la app al cambiar de primer a segundo plano (MASVS-PLATFORM):
///
/// * Al quedar inactiva cubre el contenido para que la miniatura del selector
///   de apps no muestre saldos ni datos personales.
/// * Al volver, y cada [AppConfig.sondeoSesion] mientras está en primer plano,
///   comprueba con el servidor que la sesión siga vigente: si se inició sesión
///   en la web o venció por inactividad, sale de inmediato.
/// * Con sesión iniciada revisa cada [AppConfig.sondeoAvisos] —también en
///   segundo plano— si hay movimientos nuevos y los anuncia como aviso del
///   celular. Es un sondeo pasivo: no alarga la sesión.
class GuardiaCicloVida extends ConsumerStatefulWidget {
  const GuardiaCicloVida({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<GuardiaCicloVida> createState() => _GuardiaCicloVidaState();
}

class _GuardiaCicloVidaState extends ConsumerState<GuardiaCicloVida> with WidgetsBindingObserver {
  bool _cubierta = false;
  Timer? _sondeo;
  Timer? _avisos;
  bool _permisoSolicitado = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _iniciarSondeo();
    ref.listenManual(sessionControllerProvider.select((s) => s.isAuthenticated), (_, autenticado) {
      autenticado ? _alIniciarSesion() : _alCerrarSesion();
    }, fireImmediately: true);
  }

  @override
  void dispose() {
    _sondeo?.cancel();
    _avisos?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _iniciarSondeo() {
    _sondeo?.cancel();
    _sondeo = Timer.periodic(AppConfig.sondeoSesion, (_) => _verificarSesion());
  }

  void _alIniciarSesion() {
    // El permiso se pide ya dentro de la cuenta, cuando el usuario entiende para qué sirve.
    if (!_permisoSolicitado) {
      _permisoSolicitado = true;
      unawaited(ref.read(notificadorSistemaProvider).solicitarPermiso().catchError((Object _) => false));
    }
    _revisarAvisos();
    _avisos?.cancel();
    _avisos = Timer.periodic(AppConfig.sondeoAvisos, (_) => _revisarAvisos());
  }

  void _alCerrarSesion() {
    _avisos?.cancel();
    _avisos = null;
    ref.read(vigiaNotificacionesProvider).reiniciar();
  }

  void _revisarAvisos() {
    if (!ref.read(sessionControllerProvider).isAuthenticated) {
      return;
    }
    unawaited(ref.read(vigiaNotificacionesProvider).revisar().catchError((Object _) {}));
  }

  void _verificarSesion() {
    if (!ref.read(sessionControllerProvider).isAuthenticated) {
      return;
    }
    unawaited(ref.read(sessionControllerProvider.notifier).verificarAlReanudar().catchError((Object _) {}));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final cubrir =
        state == AppLifecycleState.inactive || state == AppLifecycleState.paused || state == AppLifecycleState.hidden;
    if (cubrir != _cubierta) {
      setState(() => _cubierta = cubrir);
    }
    if (state == AppLifecycleState.resumed) {
      _verificarSesion();
      _iniciarSondeo();
      _revisarAvisos();
    } else if (state == AppLifecycleState.paused || state == AppLifecycleState.hidden) {
      // La sesión no se sondea en segundo plano (ahorra batería); los avisos sí siguen.
      _sondeo?.cancel();
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
