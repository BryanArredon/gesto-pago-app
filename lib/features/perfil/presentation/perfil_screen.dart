import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/format/gp_fecha.dart';
import '../../../core/format/message_de_error.dart';
import '../../../core/network/app_exception.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/gp_assets.dart';
import '../../../core/theme/gp_colors.dart';
import '../../../core/theme/gp_theme.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/fondo_auth.dart';
import '../../../core/widgets/password_field.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/application/session_controller.dart';
import '../../cuenta/application/cuenta_providers.dart';

/// Perfil del cliente: datos del expediente (onboarding-clientes), seguridad
/// de la cuenta, PIN de compras, apariencia y cierre de sesión.
class PerfilScreen extends ConsumerStatefulWidget {
  const PerfilScreen({super.key});

  @override
  ConsumerState<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends ConsumerState<PerfilScreen> {
  Future<void> _confirmarLogout(AppLocalizations l) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l.perfilLogoutConfirm),
        content: Text(l.perfilLogoutServer),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: Text(l.commonCancel)),
          FilledButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: Text(l.perfilLogout)),
        ],
      ),
    );
    if (confirmado == true && mounted) {
      await ref.read(sessionControllerProvider.notifier).logout();
    }
  }

  Future<void> _cambiarPin(AppLocalizations l) async {
    final usuarioId = ref.read(sessionControllerProvider).session?.usuarioId;
    if (usuarioId == null) {
      return;
    }
    final guardado = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _CambiarPinSheet(usuarioId: usuarioId),
    );
    if (guardado == true && mounted) {
      ref.invalidate(clienteDetalleProvider);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.perfilPinSaved)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final sesion = ref.watch(sessionControllerProvider);
    final themeMode = ref.watch(themeModeProvider);
    final detalle = ref.watch(clienteDetalleProvider);
    final cuenta = ref.watch(cuentaActivaProvider).value;
    final d = detalle.value;

    final nombre = d?.nombreCompleto ?? sesion.session?.nombre ?? '';

    return Scaffold(
      appBar: AppBar(title: Text(l.perfilTitle)),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(clienteDetalleProvider);
          ref.invalidate(cuentaActivaProvider);
          await ref.read(clienteDetalleProvider.future);
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(GpSpacing.page, 8, GpSpacing.page, 24),
          children: [
            const SizedBox(height: 8),
            _Encabezado(nombre: nombre.isEmpty ? l.perfilName : nombre, email: sesion.session?.email ?? ''),
            const SizedBox(height: 24),
            if (detalle.isLoading && d == null)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (detalle.hasError && d == null)
              AppErrorView(message: l.errorGeneric, onRetry: () => ref.invalidate(clienteDetalleProvider))
            else if (d != null)
              _TarjetaSeccion(
                title: l.perfilPersonalData,
                children: [
                  _Dato(icon: Icons.badge_outlined, etiqueta: 'CURP', valor: d.curp),
                  _Dato(icon: Icons.receipt_long_outlined, etiqueta: 'RFC', valor: d.rfc),
                  _Dato(icon: Icons.phone_outlined, etiqueta: l.perfilPhone, valor: d.telefonoMovil),
                  _Dato(icon: Icons.home_outlined, etiqueta: l.perfilAddress, valor: d.domicilio),
                  if (cuenta != null)
                    _Dato(icon: Icons.account_balance_outlined, etiqueta: l.perfilAccount, valor: cuenta.agrupada),
                ],
              ),
            const SizedBox(height: 16),
            _TarjetaSeccion(
              title: l.perfilSecurity,
              children: [
                _Dato(
                  icon: Icons.verified_user_outlined,
                  etiqueta: l.perfilTwoFactor,
                  valor: l.perfilTwoFactorActive,
                  color: const Color(0xFF047857),
                ),
                _Dato(icon: Icons.devices_outlined, etiqueta: l.perfilSingleSession, valor: l.perfilSingleSessionDesc),
                if (d?.ultimoAcceso != null)
                  _Dato(
                    icon: Icons.history_outlined,
                    etiqueta: l.perfilLastAccess,
                    valor: formatFecha(d!.ultimoAcceso!.toUtc().toIso8601String()),
                  ),
                _Dato(
                  icon: Icons.pin_outlined,
                  etiqueta: l.perfilPin,
                  valor: d?.tienePin == true ? l.perfilPinConfigured : l.perfilPinPending,
                ),
                _FilaIcono(icon: Icons.password_outlined, texto: l.perfilChangePin, onTap: () => _cambiarPin(l)),
              ],
            ),
            const SizedBox(height: 16),
            _TarjetaSeccion(
              title: l.perfilTheme,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: SegmentedButton<ThemeMode>(
                    segments: [
                      ButtonSegment(
                        value: ThemeMode.system,
                        icon: const Icon(Icons.brightness_auto_outlined),
                        label: Text(l.perfilThemeSystem),
                      ),
                      ButtonSegment(
                        value: ThemeMode.light,
                        icon: const Icon(Icons.light_mode_outlined),
                        label: Text(l.perfilThemeLight),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        icon: const Icon(Icons.dark_mode_outlined),
                        label: Text(l.perfilThemeDark),
                      ),
                    ],
                    selected: {themeMode},
                    showSelectedIcon: false,
                    onSelectionChanged: (value) => ref.read(themeModeProvider.notifier).state = value.first,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _TarjetaSeccion(
              title: null,
              children: [
                _FilaIcono(
                  icon: Icons.logout,
                  texto: l.perfilLogout,
                  color: GpColors.error,
                  onTap: () => _confirmarLogout(l),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Encabezado extends StatelessWidget {
  const _Encabezado({required this.nombre, required this.email});

  final String nombre;
  final String email;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(GpSpacing.xl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E3A8A), Color(0xFF1D4ED8), Color(0xFF2563EB)],
          stops: [0.0, 0.6, 1.0],
        ),
        borderRadius: BorderRadius.circular(GpRadii.tarjeta),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 24, offset: const Offset(0, 10)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: Image.asset(
              GpAssets.logo,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => const Icon(Icons.payments_outlined, size: 32, color: Color(0xFF1D4ED8)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombre,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Dato extends StatelessWidget {
  const _Dato({required this.icon, required this.etiqueta, required this.valor, this.color});

  final IconData icon;
  final String etiqueta;
  final String valor;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color ?? scheme.onSurfaceVariant),
      title: Text(etiqueta, style: Theme.of(context).textTheme.bodySmall),
      subtitle: Text(valor.isEmpty ? '—' : valor, style: TextStyle(color: color ?? scheme.onSurface)),
    );
  }
}

/// Cambio del PIN de compras: exige la contraseña actual (re-autenticación).
class _CambiarPinSheet extends ConsumerStatefulWidget {
  const _CambiarPinSheet({required this.usuarioId});

  final String usuarioId;

  @override
  ConsumerState<_CambiarPinSheet> createState() => _CambiarPinSheetState();
}

class _CambiarPinSheetState extends ConsumerState<_CambiarPinSheet> {
  final _password = TextEditingController();
  final _pin = TextEditingController();
  final _confirmacion = TextEditingController();
  bool _guardando = false;
  String? _error;

  @override
  void dispose() {
    _password.dispose();
    _pin.dispose();
    _confirmacion.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    final l = AppLocalizations.of(context);
    if (_password.text.isEmpty) {
      setState(() => _error = l.loginPasswordRequired);
      return;
    }
    if (!RegExp(r'^\d{4}$').hasMatch(_pin.text)) {
      setState(() => _error = l.campoPinInvalido);
      return;
    }
    if (_pin.text != _confirmacion.text) {
      setState(() => _error = l.perfilPinMismatch);
      return;
    }
    setState(() {
      _guardando = true;
      _error = null;
    });
    try {
      await ref
          .read(cuentaRemoteProvider)
          .cambiarPin(usuarioId: widget.usuarioId, contraseniaActual: _password.text, nuevoPin: _pin.text);
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } on AppException catch (e) {
      if (mounted) {
        setState(
          () => _error = e is UnauthorizedException && !UnauthorizedException.esPerdidaDeSesion(e.code)
              ? l.perfilWrongPassword
              : messageDeError(context, e),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _guardando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final digitos = [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4)];
    return Padding(
      padding: EdgeInsets.fromLTRB(
        GpSpacing.xl,
        0,
        GpSpacing.xl,
        GpSpacing.xl + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.perfilChangePin, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          PasswordField(controller: _password, label: l.perfilCurrentPassword, enabled: !_guardando),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _pin,
                  enabled: !_guardando,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: digitos,
                  decoration: InputDecoration(labelText: l.perfilNewPin),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _confirmacion,
                  enabled: !_guardando,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: digitos,
                  decoration: InputDecoration(labelText: l.perfilConfirmPin),
                ),
              ),
            ],
          ),
          if (_error != null) ...[const SizedBox(height: 12), AvisoBanner(mensaje: _error!)],
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _guardando ? null : _guardar,
            child: _guardando
                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4))
                : Text(l.commonSave),
          ),
        ],
      ),
    );
  }
}

class _TarjetaSeccion extends StatelessWidget {
  const _TarjetaSeccion({required this.title, required this.children});

  final String? title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: GpSpacing.lg),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(GpRadii.tarjeta),
        border: Border.all(color: scheme.outline),
      ),
      child: Material(
        color: Colors.transparent,
        clipBehavior: Clip.hardEdge,
        borderRadius: BorderRadius.circular(GpRadii.tarjeta),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(title!, style: Theme.of(context).textTheme.titleMedium),
              ),
              const Divider(),
            ],
            ...children,
          ],
        ),
      ),
    );
  }
}

class _FilaIcono extends StatelessWidget {
  const _FilaIcono({required this.icon, required this.texto, this.onTap, this.color});

  final IconData icon;
  final String texto;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final target = color ?? Theme.of(context).colorScheme.onSurfaceVariant;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: target),
      title: Text(texto, style: TextStyle(color: target)),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
      enabled: onTap != null,
    );
  }
}
