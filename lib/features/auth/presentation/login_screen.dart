import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format/message_de_error.dart';
import '../../../core/network/app_exception.dart';
import '../../../core/network/token_refresher.dart';
import '../../../core/theme/gp_assets.dart';
import '../../../core/widgets/fondo_auth.dart';
import '../../../core/widgets/password_field.dart';
import '../../../l10n/app_localizations.dart';
import '../application/session_controller.dart';
import 'mfa_screen.dart';

/// Primer paso del inicio de sesión: correo y contraseña. Si son correctos el
/// servidor emite un desafío y se continúa en [MfaScreen] con el código TOTP.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key, this.correoInicial});

  /// Correo precargado (p. ej. al volver del registro).
  final String? correoInicial;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _emailController = TextEditingController(text: widget.correoInicial ?? '');
  final _passwordController = TextEditingController();
  bool _cargando = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _continuar() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final l = AppLocalizations.of(context);
    if (_passwordController.text.isEmpty) {
      setState(() => _error = l.loginPasswordRequired);
      return;
    }
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final email = _emailController.text.trim().toLowerCase();
      final desafio = await ref
          .read(sessionControllerProvider.notifier)
          .iniciarSesion(email: email, password: _passwordController.text);
      if (!mounted) {
        return;
      }
      // La contraseña no se conserva en memoria más de lo necesario.
      _passwordController.clear();
      await context.push(
        '/login/mfa',
        extra: MfaArgs(desafio: desafio, email: email),
      );
    } on AppException catch (e) {
      if (!mounted) {
        return;
      }
      setState(
        () => _error = switch (e) {
          UnauthorizedException() => l.loginInvalidCredentials,
          ForbiddenException() => l.loginUserInactive,
          LockedException() => l.loginLocked,
          _ => messageDeError(context, e),
        },
      );
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('Login falló con error inesperado: $e\n$st');
      }
      if (mounted) {
        setState(() => _error = l.errorGeneric);
      }
    } finally {
      if (mounted) {
        setState(() => _cargando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final motivo = ref.watch(sessionControllerProvider.select((s) => s.motivoCierre));
    final avisoCierre = switch (motivo) {
      MotivoCierre.revocada => l.loginClosedRevoked,
      MotivoCierre.expirada => l.loginClosedExpired,
      MotivoCierre.manual => l.loginClosedManual,
      null => null,
    };
    return Scaffold(
      body: FondoAuth(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const LogoAuth(),
                  const SizedBox(height: 24),
                  Text(
                    l.loginTitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l.loginSubtitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white.withValues(alpha: 0.85)),
                  ),
                  const SizedBox(height: 30),
                  TarjetaAuth(
                    child: _FormularioLogin(
                      l: l,
                      formKey: _formKey,
                      emailController: _emailController,
                      passwordController: _passwordController,
                      cargando: _cargando,
                      error: _error,
                      aviso: _error == null ? avisoCierre : null,
                      avisoEsError: motivo == MotivoCierre.revocada,
                      onContinuar: _continuar,
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

/// Isotipo de la marca sobre fondo blanco.
class LogoAuth extends StatelessWidget {
  const LogoAuth({super.key, this.size = 88});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: size,
        height: size,
        padding: EdgeInsets.all(size * 0.09),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(size * 0.3),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.22), blurRadius: 28, offset: const Offset(0, 10)),
          ],
        ),
        child: Image.asset(
          GpAssets.logo,
          fit: BoxFit.contain,
          semanticLabel: 'Gesto Pago',
          errorBuilder: (_, _, _) => const Icon(Icons.payments_outlined, size: 40, color: Color(0xFF1D4ED8)),
        ),
      ),
    );
  }
}

class _FormularioLogin extends StatelessWidget {
  const _FormularioLogin({
    required this.l,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.cargando,
    required this.error,
    required this.aviso,
    required this.avisoEsError,
    required this.onContinuar,
  });

  final AppLocalizations l;
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool cargando;
  final String? error;
  final String? aviso;
  final bool avisoEsError;
  final VoidCallback onContinuar;

  @override
  Widget build(BuildContext context) {
    return AutofillGroup(
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (aviso != null) ...[
              AvisoBanner(
                mensaje: aviso!,
                esError: avisoEsError,
                icono: avisoEsError ? Icons.devices_other : Icons.check_circle_outline,
              ),
              const SizedBox(height: 16),
            ],
            TextFormField(
              controller: emailController,
              enabled: !cargando,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.username, AutofillHints.email],
              autocorrect: false,
              maxLength: 100,
              buildCounter: (_, {required currentLength, required isFocused, maxLength}) => null,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: l.loginEmailLabel,
                hintText: 'correo@ejemplo.com',
                prefixIcon: const Icon(Icons.alternate_email),
              ),
              validator: (value) {
                final v = value?.trim() ?? '';
                if (v.isEmpty) {
                  return l.loginEmailRequired;
                }
                if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v)) {
                  return l.loginEmailInvalid;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            PasswordField(
              controller: passwordController,
              label: l.loginPasswordLabel,
              enabled: !cargando,
              autofillHints: const [AutofillHints.password],
              onSubmitted: (_) => cargando ? null : onContinuar(),
            ),
            if (error != null) ...[const SizedBox(height: 16), AvisoBanner(mensaje: error!)],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: cargando ? null : onContinuar,
              child: cargando
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4))
                  : Text(l.loginButton),
            ),
            const SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(l.loginNoAccount, style: Theme.of(context).textTheme.bodyMedium),
                TextButton(onPressed: cargando ? null : () => context.push('/register'), child: Text(l.registroTitle)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
