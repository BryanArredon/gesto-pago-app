import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gesto_pago_app/core/network/app_exception.dart';
import 'package:gesto_pago_app/core/providers/app_providers.dart';
import 'package:gesto_pago_app/core/widgets/password_field.dart';
import 'package:gesto_pago_app/features/auth/presentation/login_screen.dart';
import 'package:gesto_pago_app/features/auth/presentation/mfa_screen.dart';
import 'package:gesto_pago_app/features/registro/presentation/registro_screen.dart';
import 'package:gesto_pago_app/l10n/app_localizations.dart';

import '../support/fakes.dart';

Widget _app(Widget home, {FakeAuthRepository? repo}) {
  return ProviderScope(
    overrides: [if (repo != null) authRepositoryProvider.overrideWithValue(repo)],
    child: MaterialApp(
      locale: const Locale('es'),
      supportedLocales: const [Locale('es'), Locale('en')],
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: home,
    ),
  );
}

void _usarPantallaTelefono(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2280);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  testWidgets('login muestra campos y botón', (tester) async {
    _usarPantallaTelefono(tester);
    await tester.pumpWidget(_app(const LoginScreen()));

    expect(find.text('Bienvenido de nuevo'), findsOneWidget);
    expect(find.byType(TextFormField), findsOneWidget);
    expect(find.byType(PasswordField), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Iniciar sesión'), findsOneWidget);
  });

  testWidgets('login valida campos vacíos', (tester) async {
    _usarPantallaTelefono(tester);
    await tester.pumpWidget(_app(const LoginScreen()));

    await tester.tap(find.widgetWithText(FilledButton, 'Iniciar sesión'));
    await tester.pumpAndSettle();

    expect(find.text('Ingresa tu correo'), findsOneWidget);
  });

  testWidgets('login precarga el correo al volver del registro', (tester) async {
    _usarPantallaTelefono(tester);
    await tester.pumpWidget(_app(const LoginScreen(correoInicial: 'ana@e2e.mx')));

    expect(find.text('ana@e2e.mx'), findsOneWidget);
  });

  testWidgets('2FA: primer acceso ofrece abrir la app autenticadora y la clave manual', (tester) async {
    _usarPantallaTelefono(tester);
    await tester.pumpWidget(
      _app(
        MfaScreen(
          args: MfaArgs(desafio: desafioDePrueba(enrolamiento: true), email: 'ana@e2e.mx'),
        ),
        repo: FakeAuthRepository(),
      ),
    );

    expect(find.text('Activa la verificación'), findsOneWidget);
    expect(find.text('Abrir app autenticadora'), findsOneWidget);
    expect(find.text('JBSW Y3DP EHPK 3PXP'), findsOneWidget);
  });

  testWidgets('2FA: con sesión abierta en la web pide confirmación y reintenta cerrándola', (tester) async {
    _usarPantallaTelefono(tester);
    final repo = FakeAuthRepository()
      ..erroresVerificacion.add(
        const ConflictException(
          'Ya tienes una sesion activa en la web',
          code: 'sesion_activa',
          statusCode: 409,
          detalles: {'canal': 'WEB', 'dispositivo': 'Chrome/131.0 (Windows NT 10.0)'},
        ),
      );
    await tester.pumpWidget(
      _app(
        MfaScreen(
          args: MfaArgs(desafio: desafioDePrueba(), email: 'ana@e2e.mx'),
        ),
        repo: repo,
      ),
    );

    await tester.enterText(find.byType(TextField), '123456');
    await tester.pumpAndSettle();

    expect(find.text('Ya tienes una sesión abierta'), findsOneWidget);
    expect(find.text('Sesión activa en la web'), findsOneWidget);
    expect(find.text('Chrome en Windows'), findsOneWidget);

    await tester.tap(find.text('Cerrar la otra sesión y entrar'));
    await tester.pumpAndSettle();

    expect(repo.llamadasVerificacion, [false, true]);
  });

  testWidgets('2FA: código incorrecto muestra el error y limpia el campo', (tester) async {
    _usarPantallaTelefono(tester);
    final repo = FakeAuthRepository()
      ..erroresVerificacion.add(const UnauthorizedException('x', code: 'codigo_mfa_invalido', statusCode: 401));
    await tester.pumpWidget(
      _app(
        MfaScreen(
          args: MfaArgs(desafio: desafioDePrueba(), email: 'ana@e2e.mx'),
        ),
        repo: repo,
      ),
    );

    await tester.enterText(find.byType(TextField), '000000');
    await tester.pumpAndSettle();

    expect(find.text('Código incorrecto o ya utilizado. Espera el siguiente código.'), findsOneWidget);
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, isEmpty);
  });

  testWidgets('registro: primer paso con datos personales', (tester) async {
    _usarPantallaTelefono(tester);
    await tester.pumpWidget(_app(const RegistroScreen()));

    expect(find.text('Abre tu cuenta'), findsOneWidget);
    expect(find.text('Paso 1 de 6'), findsOneWidget);
    expect(find.text('CURP'), findsOneWidget);
  });

  testWidgets('registro: no avanza con campos obligatorios vacíos', (tester) async {
    _usarPantallaTelefono(tester);
    await tester.pumpWidget(_app(const RegistroScreen()));

    await tester.tap(find.widgetWithText(FilledButton, 'Continuar'));
    await tester.pumpAndSettle();

    expect(find.text('Paso 1 de 6'), findsOneWidget);
    expect(find.text('Campo obligatorio'), findsWidgets);
  });
}
