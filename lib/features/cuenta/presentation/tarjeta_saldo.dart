import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/format/gp_money.dart';
import '../../../core/theme/gp_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../application/cuenta_providers.dart';

/// Ocultar el saldo es una preferencia de privacidad en pantalla (en memoria).
final saldoOcultoProvider = StateProvider<bool>((_) => false);

/// Tarjeta con la cuenta bancaria del cliente y su saldo disponible.
class TarjetaSaldo extends ConsumerWidget {
  const TarjetaSaldo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final cuenta = ref.watch(cuentaActivaProvider);
    final oculto = ref.watch(saldoOcultoProvider);
    final tema = Theme.of(context);
    const blanco70 = TextStyle(color: Colors.white70);

    return Container(
      padding: const EdgeInsets.all(GpSpacing.xl),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(GpRadii.dialogo),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2563EB), Color(0xFF1D4ED8), Color(0xFF1E3A8A)],
        ),
        boxShadow: [
          BoxShadow(color: const Color(0xFF1D4ED8).withValues(alpha: 0.3), blurRadius: 24, offset: const Offset(0, 12)),
        ],
      ),
      child: cuenta.when(
        loading: () => const SizedBox(
          height: 110,
          child: Center(child: CircularProgressIndicator(color: Colors.white)),
        ),
        error: (_, _) => SizedBox(
          height: 110,
          child: Row(
            children: [
              Expanded(
                child: Text(l.inicioAccountError, style: const TextStyle(color: Colors.white)),
              ),
              IconButton(
                onPressed: () => ref.invalidate(cuentaActivaProvider),
                icon: const Icon(Icons.refresh, color: Colors.white),
                tooltip: l.commonRetry,
              ),
            ],
          ),
        ),
        data: (c) => c == null
            ? SizedBox(
                height: 110,
                child: Center(
                  child: Text(l.pagoNoAccount, style: const TextStyle(color: Colors.white)),
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(l.inicioAccountType(_tipo(c.tipo)), style: blanco70)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(GpRadii.pastilla),
                        ),
                        child: Text(
                          c.estatus,
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(l.inicioBalance, style: blanco70),
                  Row(
                    children: [
                      Flexible(
                        child: Semantics(
                          label: l.inicioBalance,
                          value: oculto ? l.inicioHideBalance : GpMoney.format(c.saldo),
                          child: Text(
                            oculto ? r'$ ••••••' : GpMoney.format(c.saldo),
                            style: tema.textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => ref.read(saldoOcultoProvider.notifier).state = !oculto,
                        tooltip: oculto ? l.inicioShowBalance : l.inicioHideBalance,
                        icon: Icon(
                          oculto ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    c.agrupada,
                    style: const TextStyle(
                      color: Colors.white,
                      letterSpacing: 2,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  static String _tipo(String tipo) => switch (tipo) {
    'AHORRO' => 'Ahorro',
    'CORRIENTE' => 'Corriente',
    'NOMINA' => 'Nómina',
    'INVERSION' => 'Inversión',
    _ => tipo,
  };
}
