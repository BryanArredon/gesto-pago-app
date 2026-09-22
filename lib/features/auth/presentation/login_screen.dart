import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format/message_de_error.dart';
import '../../../core/network/app_exception.dart';
import '../../../core/theme/gp_assets.dart';
import '../../../core/theme/gp_colors.dart';
import '../../../core/theme/gp_theme.dart';
import '../../../core/widgets/password_field.dart';
import '../../../l10n/app_localizations.dart';
import '../application/session_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _cargando = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _iniciarSesion() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      await ref
          .read(sessionControllerProvider.notifier)
          .login(email: _emailController.text, password: _passwordController.text);
      // El router redirigirá a /home al cambiar el estado de sesión.
    } on AppException catch (e) {
      if (!mounted) {
        return;
      }
      final mensaje =
          e is UnauthorizedException && e.code == 'AUTH-002'
              ? AppLocalizations.of(context).loginInvalidCredentials
              : messageDeError(context, e);
      setState(() => _error = mensaje);
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('Login falló con error inesperado: $e\n$st');
      }
      if (mounted) {
        setState(() => _error = AppLocalizations.of(context).errorGeneric);
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
    final oscuro = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              GpAssets.loginFondo,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => ColoredBox(
                color: oscuro ? GpColors.fondoOscuro : const Color(0xFF1D4ED8),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.26),
                    Colors.black.withValues(alpha: 0.08),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 88,
                          height: 88,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(26),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.22),
                                blurRadius: 28,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Image.asset(
                            GpAssets.logo,
                            fit: BoxFit.contain,
                            errorBuilder: (_, _, _) =>
                                const Icon(Icons.payments_outlined,
                                    size: 40, color: Color(0xFF1D4ED8)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        l.loginTitle,
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .displaySmall
                            ?.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l.loginSubtitle,
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(color: Colors.white.withValues(alpha: 0.85)),
                      ),
                      const SizedBox(height: 30),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(GpRadii.dialogo),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                          child: Container(
                            padding: const EdgeInsets.all(GpSpacing.xl),
                            decoration: BoxDecoration(
                              color: oscuro
                                  ? const Color(0xE6161D1A)
                                  : const Color(0xF2FFFFFF),
                              borderRadius: BorderRadius.circular(GpRadii.dialogo),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.35),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.14),
                                  blurRadius: 36,
                                  offset: const Offset(0, 16),
                                ),
                              ],
                            ),
                            child: _FormularioLogin(
                              l: l,
                              formKey: _formKey,
                              emailController: _emailController,
                              passwordController: _passwordController,
                              cargando: _cargando,
                              error: _error,
                              onIniciar: _iniciarSesion,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
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
    required this.onIniciar,
  });

  final AppLocalizations l;
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool cargando;
  final String? error;
  final VoidCallback onIniciar;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: emailController,
            enabled: !cargando,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            autocorrect: false,
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
            onFieldSubmitted: (_) => cargando ? null : onIniciar(),
          ),
          const SizedBox(height: 16),
          PasswordField(
            controller: passwordController,
            label: l.loginPasswordLabel,
            enabled: !cargando,
            onSubmitted: (_) => cargando ? null : onIniciar(),
          ),
          if (error != null) ...[
            const SizedBox(height: 16),
            _ErrorBanner(mensaje: error!),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: cargando ? null : onIniciar,
            child: cargando
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.4),
                  )
                : Text(l.loginButton),
          ),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                l.loginNoAccount,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              TextButton(
                onPressed: cargando
                    ? null
                    : () => context.pushReplacement('/register'),
                child: Text(l.loginCreateAccount),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.mensaje});

  final String mensaje;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(GpSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(GpRadii.campo),
        border: Border.all(color: Theme.of(context).colorScheme.error.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              mensaje,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}