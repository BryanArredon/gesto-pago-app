import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gesto_pago_app/core/widgets/brand_mark.dart';
import 'package:gesto_pago_app/l10n/app_localizations.dart';

Widget _app(Widget home) {
  return MaterialApp(
    locale: const Locale('es'),
    supportedLocales: const [Locale('es'), Locale('en')],
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: Scaffold(body: home),
  );
}

void _esperaLogo(WidgetTester tester, String servicio, String esperado) {
  final imagen = tester.widget<Image>(find.byType(Image));
  final asset = (imagen.image as AssetImage).assetName;
  expect(asset, esperado,
      reason: 'Para "$servicio" debería resolverse $esperado');
}

void main() {
  group('BrandMark resuelve el logo correcto', () {
    for (final (caso, servicios, esperado) in [
      ('nombre exacto', ['Telcel'], 'assets/images/marcas/telcel.png'),
      ('AT&T', ['AT-T', 'AT-T Pospago'], 'assets/images/marcas/att.png'),
      ('con sufijo', ['Netflix Premium', 'Netflix'], 'assets/images/marcas/netflix.png'),
      (
        'nombres compuestos',
        ['Xbox Game Pass Core', 'Nintendo Switch Online'],
        ['assets/images/marcas/xbox.png', 'assets/images/marcas/nintendo.png'],
      ),
    ]) {
      testWidgets(caso, (tester) async {
        for (var i = 0; i < servicios.length; i++) {
          final esperadoActual = esperado is List ? esperado[i] : esperado;
          await tester.pumpWidget(
            _app(BrandMark(servicio: servicios[i])),
          );
          _esperaLogo(tester, servicios[i], esperadoActual.toString());
        }
      });
    }

    testWidgets('sin marca conocida usa ícono de respaldo', (tester) async {
      await tester.pumpWidget(_app(const BrandMark(servicio: 'Something Co')));
      expect(find.byType(Image), findsNothing);
      expect(find.byIcon(Icons.receipt_outlined), findsOneWidget);
    });
  });
}