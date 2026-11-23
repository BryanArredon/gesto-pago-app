import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/format/gp_money.dart';
import '../../../../core/theme/gp_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../cuenta/domain/cuenta.dart';

/// Pide el PIN de 4 dígitos que autoriza el cargo. Devuelve el PIN, o null si
/// el usuario cancela. El PIN no se guarda: vive solo durante el pago.
Future<String?> pedirPinAutorizacion(BuildContext context, {required Cuenta cuenta, required String monto}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _PinSheet(cuenta: cuenta, monto: monto),
  );
}

class _PinSheet extends StatefulWidget {
  const _PinSheet({required this.cuenta, required this.monto});

  final Cuenta cuenta;
  final String monto;

  @override
  State<_PinSheet> createState() => _PinSheetState();
}

class _PinSheetState extends State<_PinSheet> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _autorizar() {
    final pin = _controller.text;
    if (!RegExp(r'^\d{4}$').hasMatch(pin)) {
      setState(() => _error = AppLocalizations.of(context).pagoPinFormat);
      return;
    }
    Navigator.of(context).pop(pin);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final tema = Theme.of(context);
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
          Icon(Icons.lock_rounded, size: 36, color: tema.colorScheme.primary),
          const SizedBox(height: 8),
          Text(l.pagoPinTitle, textAlign: TextAlign.center, style: tema.textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(l.pagoPinMessage(widget.cuenta.enmascarada), textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(GpMoney.format(widget.monto), textAlign: TextAlign.center, style: tema.textTheme.headlineSmall),
          const SizedBox(height: 20),
          TextField(
            controller: _controller,
            autofocus: true,
            obscureText: true,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4)],
            style: tema.textTheme.headlineMedium?.copyWith(letterSpacing: 16),
            decoration: InputDecoration(labelText: l.pagoPinLabel, errorText: _error, counterText: ''),
            onChanged: (v) {
              if (_error != null) {
                setState(() => _error = null);
              }
              if (v.length == 4) {
                _autorizar();
              }
            },
            onSubmitted: (_) => _autorizar(),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _autorizar,
            icon: const Icon(Icons.verified_user_outlined),
            label: Text(l.pagoAuthorize),
          ),
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l.commonCancel)),
        ],
      ),
    );
  }
}
