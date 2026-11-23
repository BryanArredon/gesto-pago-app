import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/format/message_de_error.dart';
import '../../../core/network/app_exception.dart';
import '../../../core/theme/gp_theme.dart';
import '../../../core/widgets/fondo_auth.dart';
import '../../../l10n/app_localizations.dart';
import '../application/session_controller.dart';
import '../domain/desafio_mfa.dart';
import 'login_screen.dart';
import 'widgets/sesion_activa_dialog.dart';

/// Argumentos de la ruta `/login/mfa`.
class MfaArgs {
  const MfaArgs({required this.desafio, required this.email});

  final DesafioMfa desafio;
  final String email;
}

/// Segundo paso del inicio de sesión: código de 6 dígitos de la app
/// autenticadora (TOTP), validado en el servidor. La primera vez incluye el
/// enrolamiento de la app.
class MfaScreen extends ConsumerStatefulWidget {
  const MfaScreen({super.key, required this.args});

  final MfaArgs args;

  @override
  ConsumerState<MfaScreen> createState() => _MfaScreenState();
}

class _MfaScreenState extends ConsumerState<MfaScreen> {
  final _codigoController = TextEditingController();
  final _codigoFocus = FocusNode();
  Timer? _reloj;
  Duration _restante = Duration.zero;
  bool _verificando = false;
  bool _mostrarQr = false;
  String? _error;

  DesafioMfa get _desafio => widget.args.desafio;

  @override
  void initState() {
    super.initState();
    _actualizarRestante();
    _reloj = Timer.periodic(const Duration(seconds: 1), (_) => _actualizarRestante());
    if (!_desafio.requiereEnrolamiento) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _codigoFocus.requestFocus();
        }
      });
    }
  }

  @override
  void dispose() {
    _reloj?.cancel();
    _codigoController.dispose();
    _codigoFocus.dispose();
    super.dispose();
  }

  void _actualizarRestante() {
    final restante = _desafio.venceEn.difference(DateTime.now());
    if (!mounted) {
      return;
    }
    setState(() => _restante = restante.isNegative ? Duration.zero : restante);
    if (restante <= Duration.zero) {
      _reloj?.cancel();
    }
  }

  bool get _vencido => _restante == Duration.zero;

  Future<void> _verificar({bool cerrarSesionAnterior = false}) async {
    final l = AppLocalizations.of(context);
    final codigo = _codigoController.text.trim();
    if (!RegExp(r'^\d{6}$').hasMatch(codigo)) {
      setState(() => _error = l.mfaCodeIncomplete);
      return;
    }
    if (_verificando) {
      return;
    }
    setState(() {
      _verificando = true;
      _error = null;
    });
    try {
      await ref
          .read(sessionControllerProvider.notifier)
          .verificarSegundoFactor(
            desafio: _desafio,
            codigo: codigo,
            email: widget.args.email,
            cerrarSesionAnterior: cerrarSesionAnterior,
          );
      // El router redirige a /home al quedar autenticado.
    } on ConflictException catch (e) {
      if (e.code != 'sesion_activa' || !mounted) {
        _mostrarError(e);
        return;
      }
      setState(() => _verificando = false);
      final confirmar = await mostrarSesionActivaDialog(context, SesionActivaInfo.desdeDetalles(e.detalles));
      if (!mounted) {
        return;
      }
      if (confirmar == true) {
        await _verificar(cerrarSesionAnterior: true);
      } else {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.sessionActiveCancelled)));
      }
    } on AppException catch (e) {
      _mostrarError(e);
    } finally {
      if (mounted && _verificando) {
        setState(() => _verificando = false);
      }
    }
  }

  void _mostrarError(AppException e) {
    if (!mounted) {
      return;
    }
    final l = AppLocalizations.of(context);
    if (e is UnauthorizedException && e.code == 'desafio_mfa_invalido') {
      _volverAlLogin(l.mfaExpired);
      return;
    }
    if (e is LockedException || e is ForbiddenException) {
      _volverAlLogin(e is LockedException ? l.loginLocked : l.loginUserInactive);
      return;
    }
    _codigoController.clear();
    setState(() => _error = e is UnauthorizedException ? l.mfaInvalidCode : messageDeError(context, e));
    _codigoFocus.requestFocus();
  }

  void _volverAlLogin(String mensaje) {
    context.pop();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  Future<void> _abrirAutenticador() async {
    final l = AppLocalizations.of(context);
    final uri = Uri.tryParse(_desafio.otpauthUri ?? '');
    final abierta = uri != null && await launchUrl(uri, mode: LaunchMode.externalApplication).catchError((_) => false);
    if (!abierta && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.mfaNoAuthenticator)));
    }
  }

  Future<void> _copiarClave() async {
    final l = AppLocalizations.of(context);
    await Clipboard.setData(ClipboardData(text: _desafio.secreto ?? ''));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.mfaKeyCopied)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final tema = Theme.of(context);
    final enrolamiento = _desafio.requiereEnrolamiento;
    final mm = _restante.inMinutes;
    final ss = (_restante.inSeconds % 60).toString().padLeft(2, '0');

    return Scaffold(
      body: FondoAuth(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: _verificando ? null : () => context.pop(),
                      style: TextButton.styleFrom(foregroundColor: Colors.white),
                      icon: const Icon(Icons.arrow_back),
                      label: Text(l.mfaChangeAccount),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const LogoAuth(size: 64),
                  const SizedBox(height: 16),
                  TarjetaAuth(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: tema.colorScheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(GpRadii.campo),
                              ),
                              child: Icon(Icons.shield_outlined, color: tema.colorScheme.primary),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(enrolamiento ? l.mfaEnrollTitle : l.mfaTitle, style: tema.textTheme.titleLarge),
                                  Text(widget.args.email, style: tema.textTheme.bodySmall),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          enrolamiento ? l.mfaEnrollInstructions : l.mfaInstructions,
                          style: tema.textTheme.bodyMedium,
                        ),
                        if (enrolamiento) ...[
                          const SizedBox(height: 16),
                          _Enrolamiento(
                            desafio: _desafio,
                            mostrarQr: _mostrarQr,
                            onAbrir: _abrirAutenticador,
                            onCopiar: _copiarClave,
                            onAlternarQr: () => setState(() => _mostrarQr = !_mostrarQr),
                          ),
                        ],
                        const SizedBox(height: 20),
                        TextField(
                          controller: _codigoController,
                          focusNode: _codigoFocus,
                          enabled: !_verificando && !_vencido,
                          keyboardType: TextInputType.number,
                          autofillHints: const [AutofillHints.oneTimeCode],
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(6),
                          ],
                          textAlign: TextAlign.center,
                          style: tema.textTheme.headlineMedium?.copyWith(
                            letterSpacing: 12,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                          decoration: InputDecoration(labelText: l.mfaCodeLabel, hintText: '000000', counterText: ''),
                          onChanged: (v) {
                            if (_error != null) {
                              setState(() => _error = null);
                            }
                            if (v.length == 6) {
                              _verificar();
                            }
                          },
                          onSubmitted: (_) => _verificar(),
                        ),
                        if (_error != null) ...[const SizedBox(height: 12), AvisoBanner(mensaje: _error!)],
                        if (_vencido) ...[const SizedBox(height: 12), AvisoBanner(mensaje: l.mfaExpired)],
                        const SizedBox(height: 20),
                        FilledButton.icon(
                          onPressed: _verificando || _vencido ? null : () => _verificar(),
                          icon: _verificando
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2.4),
                                )
                              : const Icon(Icons.lock_open_rounded),
                          label: Text(l.mfaVerify),
                        ),
                        const SizedBox(height: 12),
                        Text(l.mfaExpiresIn('$mm:$ss'), textAlign: TextAlign.center, style: tema.textTheme.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Enrolamiento extends StatelessWidget {
  const _Enrolamiento({
    required this.desafio,
    required this.mostrarQr,
    required this.onAbrir,
    required this.onCopiar,
    required this.onAlternarQr,
  });

  final DesafioMfa desafio;
  final bool mostrarQr;
  final VoidCallback onAbrir;
  final VoidCallback onCopiar;
  final VoidCallback onAlternarQr;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final tema = Theme.of(context);
    final clave = (desafio.secreto ?? '').replaceAllMapped(RegExp(r'.{4}'), (m) => '${m[0]} ').trim();
    return Container(
      padding: const EdgeInsets.all(GpSpacing.lg),
      decoration: BoxDecoration(
        color: tema.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(GpRadii.tarjeta),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilledButton.tonalIcon(
            onPressed: onAbrir,
            icon: const Icon(Icons.open_in_new_rounded),
            label: Text(l.mfaOpenAuthenticator),
          ),
          const SizedBox(height: 12),
          Text(l.mfaManualKey, style: tema.textTheme.labelMedium),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: SelectableText(
                  clave,
                  style: tema.textTheme.titleSmall?.copyWith(fontFamily: 'monospace', letterSpacing: 1.2),
                ),
              ),
              IconButton(onPressed: onCopiar, tooltip: l.mfaCopyKey, icon: const Icon(Icons.copy_rounded)),
            ],
          ),
          TextButton.icon(
            onPressed: onAlternarQr,
            icon: Icon(mostrarQr ? Icons.expand_less : Icons.qr_code_2_rounded),
            label: Text(l.mfaShowQr),
          ),
          if (mostrarQr && desafio.otpauthUri != null) ...[
            Center(
              child: Container(
                padding: const EdgeInsets.all(8),
                color: Colors.white,
                child: QrImageView(data: desafio.otpauthUri!, size: 180, semanticsLabel: l.mfaShowQr),
              ),
            ),
            const SizedBox(height: 8),
            Text(l.mfaQrHint, textAlign: TextAlign.center, style: tema.textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}
