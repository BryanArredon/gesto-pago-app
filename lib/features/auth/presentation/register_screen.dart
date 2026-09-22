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

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmacionController = TextEditingController();
  bool _cargando = false;
  String? _error;

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmacionController.dispose();
    super.dispose();
  }

  Future<void> _crearCuenta() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final l = AppLocalizations.of(context);
    if (_passwordController.text != _confirmacionController.text) {
      setState(() => _error = l.registerPasswordMismatch);
      return;
    }
    if (_passwordController.text.length < 6) {
      setState(() => _error = l.registerPasswordTooShort);
      return;
    }
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      await ref.read(sessionControllerProvider.notifier).register(
            nombre: _nombreController.text.trim(),
            email: _emailController.text,
            password: _passwordController.text,
          );
      // El router redirige a /home al autenticarse.
    } on AppException catch (e) {
      if (mounted) {
        setState(() => _error = messageDeError(context, e));
      }
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('Registro falló con error inesperado: $e\n$st');
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l.registerSubtitle,
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(color: Colors.white.withValues(alpha: 0.9)),
                      ),
                      const SizedBox(height: 24),
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
                            child: _FormularioRegistro(
                              l: l,
                              formKey: _formKey,
                              nombreController: _nombreController,
                              emailController: _emailController,
                              passwordController: _passwordController,
                              confirmacionController: _confirmacionController,
                              cargando: _cargando,
                              error: _error,
                              onCrear: _crearCuenta,
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

class _FormularioRegistro extends StatelessWidget {
  const _FormularioRegistro({
    required this.l,
    required this.formKey,
    required this.nombreController,
    required this.emailController,
    required this.passwordController,
    required this.confirmacionController,
    required this.cargando,
    required this.error,
    required this.onCrear,
  });

  final AppLocalizations l;
  final GlobalKey<FormState> formKey;
  final TextEditingController nombreController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmacionController;
  final bool cargando;
  final String? error;
  final VoidCallback onCrear;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: nombreController,
            enabled: !cargando,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            autocorrect: false,
            decoration: InputDecoration(
              labelText: l.registerNameLabel,
              prefixIcon: const Icon(Icons.badge_outlined),
            ),
            validator: (value) =>
                (value?.trim().isEmpty ?? true) ? l.registerNameRequired : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: emailController,
            enabled: !cargando,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            autocorrect: false,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: l.registerEmailLabel,
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
            label: l.registerPasswordLabel,
            enabled: !cargando,
          ),
          const SizedBox(height: 16),
          PasswordField(
            controller: confirmacionController,
            label: l.registerConfirmPasswordLabel,
            enabled: !cargando,
            onSubmitted: (_) => cargando ? null : onCrear(),
          ),
          if (error != null) ...[
            const SizedBox(height: 16),
            _ErrorBanner(mensaje: error!),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: cargando ? null : onCrear,
            child: cargando
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.4),
                  )
                : Text(l.registerButton),
          ),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                l.registerAlreadyHaveAccount,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              TextButton(
                onPressed: cargando ? null : () => context.go('/login'),
                child: Text(l.registerSignIn),
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
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