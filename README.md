# Gesto Pago · App móvil (Flutter)

App de banca y pagos de servicios. Comparte usuarios, sesión y reglas con la web (`onboarding-web`)
y consume los mismos servicios REST:

| Servicio | Puerto local | Uso |
| :-- | :-- | :-- |
| `onboarding-clientes` | 8082 | Alta de cliente, login con 2FA, sesiones, cuenta y datos del cliente |
| `api-gesto-pago` | 8080 | Catálogo, compras e historial (acepta el JWT de onboarding) |

## Ejecutar

```bash
flutter pub get
flutter run                                      # iOS / escritorio: localhost
flutter run -d emulator-5554                     # Android: usa 10.0.2.2 automáticamente
flutter run --dart-define=ONBOARDING_URL=https://onboarding.midominio.mx \
            --dart-define=API_BASE_URL=https://api.midominio.mx \
            --dart-define=CERT_PINS=<sha256-actual>,<sha256-respaldo>
```

Build de release ofuscado (MASVS-RESILIENCE):

```bash
flutter build apk --release --obfuscate --split-debug-info=build/debug-info
```

## Flujo

1. **Alta** (`/register`): asistente de 6 pasos con las mismas validaciones que el backend (CURP/RFC con
   fecha de nacimiento, mayoría de edad, teléfono, C.P., política de contraseñas, PIN). Al terminar
   muestra la cuenta ACTIVA creada.
2. **Login**: contraseña → código de la app autenticadora (TOTP, validado en el servidor). En el
   primer acceso: "Abrir app autenticadora" (`otpauth://`), copiar clave o QR para otro dispositivo.
3. **Una sola sesión**: si hay una sesión abierta en la web se muestra dónde y se pide confirmación
   antes de cerrarla. Si la web inicia sesión después, la app sale con el aviso "se inició sesión en
   otro dispositivo".
4. **Compra**: confirmación → PIN de 4 dígitos → resultado (exitosa / rechazada / en proceso /
   error de comunicación). Clave de idempotencia estable: reintentar nunca cobra dos veces.
5. **Historial**: solo compras exitosas (LIQUIDADO).

## Seguridad

- Token en Keystore/Keychain (`flutter_secure_storage`, solo con el dispositivo desbloqueado, sin respaldo en la nube).
- Sesión de servidor: renovación previa al vencimiento, cierre ante `401` de sesión (un `401` de negocio
  como el PIN incorrecto `PAGO-008` no cierra la sesión) y verificación al volver del segundo plano.
- Al pasar a segundo plano se cubre la pantalla (sin saldos en el selector de apps).
- Certificate pinning por huella SHA-256 (`CERT_PINS`); en release Android solo HTTPS y solo CAs del
  sistema; en debug HTTP permitido únicamente hacia `10.0.2.2`/`localhost`.
- `allowBackup=false` y reglas de extracción de datos vacías.
- Los logs de red en debug nunca incluyen cuerpos (contraseñas, códigos, PIN).

## Pruebas

```bash
flutter analyze
flutter test                                                  # unitarias y de widgets
ONBOARDING_E2E_URL=http://127.0.0.1:8082 flutter test test/integration   # contra un backend real
```

La prueba de integración da de alta un cliente, enrola el 2FA, verifica la sesión única entre web y
móvil, la revocación y el logout. **Úsala solo contra una base de datos de pruebas.**
