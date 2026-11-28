// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'GestoPago';

  @override
  String get commonLoading => 'Cargando...';

  @override
  String get commonRetry => 'Reintentar';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonConfirm => 'Confirmar';

  @override
  String get commonSave => 'Guardar';

  @override
  String get commonClose => 'Cerrar';

  @override
  String get commonBack => 'Volver';

  @override
  String get commonDone => 'Listo';

  @override
  String get errorGeneric => 'Ocurrió un error inesperado. Intenta de nuevo.';

  @override
  String get errorNetwork =>
      'No se pudo conectar con el servidor. Revisa tu conexión.';

  @override
  String get errorTimeout =>
      'El servidor tardó demasiado en responder. Intenta de nuevo.';

  @override
  String get errorUnauthorized => 'Tu sesión expiró. Vuelve a iniciar sesión.';

  @override
  String get errorForbidden => 'No tienes permiso para realizar esta acción.';

  @override
  String get errorNotFound => 'No se encontró la información solicitada.';

  @override
  String get errorRateLimit => 'Demasiados intentos. Intenta en un momento.';

  @override
  String get errorServer => 'Error del servidor. Intenta más tarde.';

  @override
  String get splashTagline => 'Paga tus servicios en un solo lugar';

  @override
  String get splashRestoring => 'Restaurando tu sesión...';

  @override
  String get loginTitle => 'Bienvenido de nuevo';

  @override
  String get loginSubtitle => 'Inicia sesión para pagar tus servicios';

  @override
  String get loginEmailLabel => 'Correo electrónico';

  @override
  String get loginPasswordLabel => 'Contraseña';

  @override
  String get loginEmailRequired => 'Ingresa tu correo';

  @override
  String get loginEmailInvalid => 'Correo inválido';

  @override
  String get loginPasswordRequired => 'Ingresa tu contraseña';

  @override
  String get loginButton => 'Iniciar sesión';

  @override
  String get loginInvalidCredentials => 'Correo o contraseña inválidos.';

  @override
  String get loginGenericError =>
      'No se pudo iniciar sesión. Intenta de nuevo.';

  @override
  String get loginNoAccount => '¿Aún no tienes cuenta?';

  @override
  String get loginCreateAccount => 'Crear cuenta';

  @override
  String get registerTitle => 'Abre tu cuenta';

  @override
  String get registerSubtitle => 'Regístrate para comenzar';

  @override
  String get registerNameLabel => 'Nombre completo';

  @override
  String get registerEmailLabel => 'Correo electrónico';

  @override
  String get registerPasswordLabel => 'Contraseña';

  @override
  String get registerConfirmPasswordLabel => 'Confirmar contraseña';

  @override
  String get registerNameRequired => 'Ingresa tu nombre';

  @override
  String get registerPasswordTooShort => 'Usa al menos 6 caracteres';

  @override
  String get registerButton => 'Crear cuenta';

  @override
  String get registerPasswordMismatch => 'Las contraseñas no coinciden.';

  @override
  String get registerAlreadyHaveAccount => '¿Ya tienes cuenta?';

  @override
  String get registerSignIn => 'Inicia sesión';

  @override
  String get registerGenericError =>
      'No se pudo crear la cuenta. Intenta de nuevo.';

  @override
  String get homeWelcome => '¿Qué vas a pagar hoy?';

  @override
  String homeGreeting(Object nombre) {
    return '¡Hola, $nombre!';
  }

  @override
  String get navInicio => 'Inicio';

  @override
  String get navHistorial => 'Historial';

  @override
  String get navPerfil => 'Perfil';

  @override
  String get homeCatalog => 'Servicios';

  @override
  String get homeProfile => 'Perfil';

  @override
  String get catalogTitle => 'Servicios';

  @override
  String get catalogAll => 'Todos';

  @override
  String get catalogSearchHint => 'Buscar servicios...';

  @override
  String get catalogEmpty => 'No hay servicios disponibles.';

  @override
  String get catalogPrice => 'Precio';

  @override
  String get catalogCommission => 'Comisión';

  @override
  String get catalogDetails => 'Detalle del servicio';

  @override
  String get catalogReferenceTypeA => 'Número de teléfono';

  @override
  String get catalogReferenceTypeB => 'Número de cliente / contrato';

  @override
  String get catalogReferenceTypeC => 'Código de barras / referencia';

  @override
  String get catalogReferenceDefault => 'Referencia';

  @override
  String get catalogDigitoVerificador => 'Dígito verificador';

  @override
  String get catalogHelp => 'Ayuda';

  @override
  String get catalogError => 'No se pudo cargar el catálogo.';

  @override
  String get homeSectionPopular => 'Los más usados';

  @override
  String get homeSectionRecent => 'Recientes';

  @override
  String get homeSectionCatalog => 'Catálogo completo';

  @override
  String get pagoReferenceLabel => 'Referencia';

  @override
  String get pagoReferenceHint => 'Ej. 6241234567';

  @override
  String get pagoReferenceRequired => 'Ingresa la referencia';

  @override
  String get pagoServicioNoDisponible => 'El servicio no está disponible.';

  @override
  String get pagoAmountLabel => 'Monto a pagar';

  @override
  String get pagoAmountHint => '0.00';

  @override
  String get pagoServiceLabel => 'Servicio';

  @override
  String get pagoVerifyReference => 'Verificar referencia';

  @override
  String get pagoVerifying => 'Verificando referencia...';

  @override
  String get pagoVerifyValid => 'Referencia válida';

  @override
  String pagoValidReferenceMessage(Object saldo) {
    return 'Referencia válida. Saldo: $saldo.';
  }

  @override
  String get pagoVerifyInvalid =>
      'Referencia inválida. Revísala e intenta de nuevo.';

  @override
  String get pagoVerifyError => 'No se pudo verificar la referencia.';

  @override
  String get pagoInvalidAmount => 'Ingresa un monto válido.';

  @override
  String get pagoConfirmTitle => 'Confirmar pago';

  @override
  String pagoConfirmMessage(Object amount, Object reference, Object service) {
    return 'Vas a pagar $service con referencia $reference por $amount. Confirma que los datos sean correctos.';
  }

  @override
  String get pagoConfirmService => 'Servicio';

  @override
  String get pagoConfirmReference => 'Referencia';

  @override
  String get pagoConfirmAmount => 'Monto';

  @override
  String get pagoConfirmButton => 'Pagar ahora';

  @override
  String get pagoEnviado =>
      'Pago enviado. Esperando confirmación del proveedor...';

  @override
  String get pagoProcessing =>
      'Procesando el pago... Podrás consultar el resultado en cualquier momento desde tu historial.';

  @override
  String get pagoCheckingResult => 'Consultando resultado con el proveedor...';

  @override
  String get pagoSuccess => 'Pago realizado con éxito';

  @override
  String get pagoAuthorization => 'Autorización';

  @override
  String get pagoTransactionId => 'Transacción';

  @override
  String get pagoFailed => 'El pago no se completó';

  @override
  String get pagoPending =>
      'Pago en proceso. Lo confirmaremos con el proveedor.';

  @override
  String get pagoReceipt => 'Comprobante';

  @override
  String get pagoSeeHistory => 'Ver historial';

  @override
  String get pagoDoNotDoubleSubmit => 'Espera, no cierres la aplicación.';

  @override
  String get comprobanteTitle => 'Comprobante de pago';

  @override
  String get comprobanteFecha => 'Fecha';

  @override
  String get comprobanteEstado => 'Estado';

  @override
  String get comprobanteVolverInicio => 'Volver al inicio';

  @override
  String get historialTitle => 'Historial de pagos';

  @override
  String get historialEmpty => 'Aún no hay pagos.';

  @override
  String get historialError => 'No se pudo cargar el historial.';

  @override
  String get historialFecha => 'Fecha';

  @override
  String get historialVerComprobante => 'Ver comprobante';

  @override
  String get historialStateApproved => 'Aprobado';

  @override
  String get historialStateFailed => 'Fallido';

  @override
  String get historialStateProcessing => 'En proceso';

  @override
  String get historialStatePending => 'Pendiente';

  @override
  String get perfilTitle => 'Perfil';

  @override
  String get perfilName => 'Nombre';

  @override
  String get perfilEmail => 'Correo electrónico';

  @override
  String get perfilEdit => 'Editar datos personales';

  @override
  String get perfilPersonaName => 'Nombre';

  @override
  String get perfilPersonaPaternal => 'Apellido paterno';

  @override
  String get perfilPersonaMaternal => 'Apellido materno';

  @override
  String get perfilSaveSuccess => 'Datos guardados correctamente.';

  @override
  String get perfilTheme => 'Apariencia';

  @override
  String get perfilThemeSystem => 'Automático';

  @override
  String get perfilThemeLight => 'Claro';

  @override
  String get perfilThemeDark => 'Oscuro';

  @override
  String get perfilLogout => 'Cerrar sesión';

  @override
  String get perfilLogoutConfirm => '¿Cerrar sesión?';

  @override
  String get perfilLogoutConfirmMessage =>
      'Necesitarás tu contraseña para volver a entrar.';

  @override
  String get loginContinue => 'Continuar';

  @override
  String get loginClosedRevoked =>
      'Tu sesión se cerró porque se inició sesión en otro dispositivo.';

  @override
  String get loginClosedExpired =>
      'Tu sesión expiró por inactividad. Inicia sesión de nuevo.';

  @override
  String get loginClosedManual => 'Cerraste sesión correctamente.';

  @override
  String get loginUserInactive =>
      'Tu usuario está inactivo. Contacta a tu ejecutivo.';

  @override
  String get loginLocked =>
      'Tu acceso está bloqueado temporalmente por intentos fallidos. Inténtalo en 15 minutos.';

  @override
  String get mfaTitle => 'Verificación en dos pasos';

  @override
  String get mfaEnrollTitle => 'Activa la verificación';

  @override
  String get mfaInstructions =>
      'Abre tu app autenticadora y escribe el código de 6 dígitos de Gesto Pago.';

  @override
  String get mfaEnrollInstructions =>
      'Por tu seguridad, vincula una app autenticadora (Google o Microsoft Authenticator). Solo se hace una vez y la usarás en el móvil y en la web.';

  @override
  String get mfaOpenAuthenticator => 'Abrir app autenticadora';

  @override
  String get mfaCopyKey => 'Copiar clave';

  @override
  String get mfaKeyCopied => 'Clave copiada. Pégala en tu app autenticadora.';

  @override
  String get mfaManualKey => 'Clave para captura manual';

  @override
  String get mfaShowQr => 'Mostrar código QR';

  @override
  String get mfaQrHint =>
      'Escanéalo con la app autenticadora de otro dispositivo.';

  @override
  String get mfaCodeLabel => 'Código de 6 dígitos';

  @override
  String get mfaVerify => 'Verificar y entrar';

  @override
  String get mfaInvalidCode =>
      'Código incorrecto o ya utilizado. Espera el siguiente código.';

  @override
  String get mfaCodeIncomplete =>
      'Escribe los 6 dígitos de tu app autenticadora.';

  @override
  String get mfaExpired =>
      'La verificación expiró. Ingresa tu contraseña de nuevo.';

  @override
  String mfaExpiresIn(String time) {
    return 'Esta verificación vence en $time';
  }

  @override
  String get mfaNoAuthenticator =>
      'No encontramos una app autenticadora. Instala Google Authenticator o Microsoft Authenticator, o copia la clave.';

  @override
  String get mfaChangeAccount => 'Cambiar de cuenta';

  @override
  String get sessionActiveTitle => 'Ya tienes una sesión abierta';

  @override
  String get sessionActiveWeb => 'Sesión activa en la web';

  @override
  String get sessionActiveMobile => 'Sesión activa en otro teléfono';

  @override
  String sessionActiveLastActivity(String date) {
    return 'Última actividad: $date';
  }

  @override
  String get sessionActiveMessage =>
      'Por seguridad solo puedes tener una sesión abierta a la vez. Si continúas, la otra sesión se cerrará de inmediato.';

  @override
  String get sessionActiveNotYou =>
      '¿No fuiste tú? Cancela y cambia tu contraseña desde un dispositivo de confianza.';

  @override
  String get sessionActiveConfirm => 'Cerrar la otra sesión y entrar';

  @override
  String get sessionActiveCancelled =>
      'No se inició sesión. Tu otra sesión sigue abierta.';

  @override
  String get pagoPinTitle => 'Autoriza con tu PIN';

  @override
  String pagoPinMessage(String account) {
    return 'Escribe el PIN de 4 dígitos de tu cuenta $account.';
  }

  @override
  String get pagoPinLabel => 'PIN de autorización';

  @override
  String get pagoPinInvalid =>
      'PIN incorrecto. Verifícalo e inténtalo de nuevo.';

  @override
  String get pagoPinFormat => 'El PIN tiene 4 dígitos.';

  @override
  String get pagoNoAccount => 'No tienes una cuenta activa para pagar.';

  @override
  String get pagoPayWith => 'Pagar con';

  @override
  String get pagoAuthorize => 'Autorizar pago';

  @override
  String get inicioBalance => 'Saldo disponible';

  @override
  String inicioAccountType(String type) {
    return 'Cuenta $type';
  }

  @override
  String get inicioShowBalance => 'Mostrar saldo';

  @override
  String get inicioHideBalance => 'Ocultar saldo';

  @override
  String get inicioAccountError => 'No pudimos cargar tu cuenta.';

  @override
  String get perfilSecurity => 'Seguridad';

  @override
  String get perfilTwoFactor => 'Verificación en dos pasos';

  @override
  String get perfilTwoFactorActive => 'Activa con app autenticadora';

  @override
  String get perfilSingleSession => 'Sesión única';

  @override
  String get perfilSingleSessionDesc =>
      'Si entras desde la web, esta sesión se cerrará.';

  @override
  String get perfilPin => 'PIN de compras';

  @override
  String get perfilPinConfigured => 'Configurado';

  @override
  String get perfilPinPending => 'Sin configurar';

  @override
  String get perfilChangePin => 'Cambiar PIN de compras';

  @override
  String get perfilCurrentPassword => 'Contraseña actual';

  @override
  String get perfilNewPin => 'Nuevo PIN';

  @override
  String get perfilConfirmPin => 'Confirmar PIN';

  @override
  String get perfilPinMismatch => 'Los PIN no coinciden.';

  @override
  String get perfilPinSaved => 'PIN actualizado.';

  @override
  String get perfilWrongPassword => 'La contraseña actual es incorrecta.';

  @override
  String get perfilPersonalData => 'Datos personales';

  @override
  String get perfilPhone => 'Teléfono';

  @override
  String get perfilAddress => 'Domicilio';

  @override
  String get perfilLastAccess => 'Último acceso';

  @override
  String get perfilAccount => 'Cuenta';

  @override
  String get perfilLogoutServer =>
      'Tu sesión se cerrará en el servidor. Para volver a entrar necesitarás tu contraseña y tu código de verificación.';

  @override
  String get registroTitle => 'Abre tu cuenta';

  @override
  String registroStepOf(String current, String total) {
    return 'Paso $current de $total';
  }

  @override
  String get registroStepPersonal => 'Datos personales';

  @override
  String get registroStepContact => 'Contacto';

  @override
  String get registroStepAddress => 'Domicilio';

  @override
  String get registroStepWork => 'Información laboral';

  @override
  String get registroStepAccess => 'Acceso y cuenta';

  @override
  String get registroStepReview => 'Confirmación';

  @override
  String registroOptional(String field) {
    return '$field (opcional)';
  }

  @override
  String get registroNombre => 'Nombre';

  @override
  String get registroSegundoNombre => 'Segundo nombre';

  @override
  String get registroApellidoPaterno => 'Apellido paterno';

  @override
  String get registroApellidoMaterno => 'Apellido materno';

  @override
  String get registroFechaNacimiento => 'Fecha de nacimiento';

  @override
  String get registroSexo => 'Sexo';

  @override
  String get registroSexoHombre => 'Hombre';

  @override
  String get registroSexoMujer => 'Mujer';

  @override
  String get registroSexoOtro => 'Otro';

  @override
  String get registroCurp => 'CURP';

  @override
  String get registroRfc => 'RFC con homoclave';

  @override
  String get registroNacionalidad => 'Nacionalidad';

  @override
  String get registroEstadoCivil => 'Estado civil';

  @override
  String get registroEcSoltero => 'Soltero(a)';

  @override
  String get registroEcCasado => 'Casado(a)';

  @override
  String get registroEcDivorciado => 'Divorciado(a)';

  @override
  String get registroEcViudo => 'Viudo(a)';

  @override
  String get registroEcUnionLibre => 'Unión libre';

  @override
  String get registroEcSeparado => 'Separado(a)';

  @override
  String get registroEcOtro => 'Otro';

  @override
  String get registroCorreo => 'Correo electrónico';

  @override
  String get registroCorreoAyuda => 'Será tu usuario para iniciar sesión.';

  @override
  String get registroTelefono => 'Teléfono móvil';

  @override
  String get registroTelefonoAlterno => 'Teléfono alternativo';

  @override
  String get registroCalle => 'Calle';

  @override
  String get registroNumExt => 'Número exterior';

  @override
  String get registroNumInt => 'Número interior';

  @override
  String get registroColonia => 'Colonia';

  @override
  String get registroCp => 'Código postal';

  @override
  String get registroMunicipio => 'Municipio o alcaldía';

  @override
  String get registroEstado => 'Estado';

  @override
  String get registroPais => 'País';

  @override
  String get registroOcupacion => 'Ocupación';

  @override
  String get registroEmpresa => 'Empresa';

  @override
  String get registroIngreso => 'Ingreso mensual (MXN)';

  @override
  String get registroContrasenia => 'Contraseña';

  @override
  String get registroConfirmar => 'Confirmar contraseña';

  @override
  String get registroPin => 'PIN de compras (4 dígitos)';

  @override
  String get registroPinAyuda => 'Lo usarás para autorizar cada compra.';

  @override
  String get registroTipoCuenta => 'Tipo de cuenta';

  @override
  String get registroTcAhorro => 'Ahorro';

  @override
  String get registroTcCorriente => 'Corriente';

  @override
  String get registroTcNomina => 'Nómina';

  @override
  String get registroTcInversion => 'Inversión';

  @override
  String get registroReglaLongitud => 'Mínimo 8 caracteres';

  @override
  String get registroReglaMayuscula => 'Una mayúscula';

  @override
  String get registroReglaMinuscula => 'Una minúscula';

  @override
  String get registroReglaNumero => 'Un número';

  @override
  String get registroReglaEspecial => 'Un carácter especial';

  @override
  String get registroCuentaInfo =>
      'Se creará tu cuenta bancaria ACTIVA con el saldo inicial que asigna el sistema y tu usuario de acceso.';

  @override
  String get registroTerminos =>
      'Declaro que la información es verídica y acepto el aviso de privacidad.';

  @override
  String get registroTerminosRequerido =>
      'Debes aceptar el aviso de privacidad.';

  @override
  String get registroAnterior => 'Anterior';

  @override
  String get registroContinuar => 'Continuar';

  @override
  String get registroEnviar => 'Abrir mi cuenta';

  @override
  String get registroEditar => 'Editar';

  @override
  String get registroError => 'No pudimos completar tu registro';

  @override
  String registroExitoTitulo(String name) {
    return '¡Bienvenido(a), $name!';
  }

  @override
  String get registroExitoMensaje =>
      'Tu registro se completó y tu cuenta ya está lista.';

  @override
  String get registroExitoSiguiente =>
      'Al iniciar sesión activarás la verificación en dos pasos.';

  @override
  String get registroNumeroCuenta => 'Número de cuenta';

  @override
  String get registroSaldoInicial => 'Saldo inicial';

  @override
  String get registroUsuario => 'Usuario de acceso';

  @override
  String get registroYaTengoCuenta => 'Ya tengo cuenta';

  @override
  String get campoObligatorio => 'Campo obligatorio';

  @override
  String get campoNombreInvalido => 'Solo letras y espacios (2 a 50).';

  @override
  String get campoLongitud => 'Longitud no válida.';

  @override
  String get campoFechaFutura => 'No puede ser una fecha futura.';

  @override
  String get campoMenorDeEdad => 'Debes ser mayor de 18 años.';

  @override
  String get campoCurpInvalida => 'CURP inválida (18 caracteres).';

  @override
  String get campoRfcInvalido => 'RFC inválido (13 caracteres con homoclave).';

  @override
  String get campoCurpFecha =>
      'La fecha de la CURP no coincide con tu fecha de nacimiento.';

  @override
  String get campoRfcFecha =>
      'La fecha del RFC no coincide con tu fecha de nacimiento.';

  @override
  String get campoCorreoInvalido => 'Correo inválido.';

  @override
  String get campoTelefonoInvalido => 'Debe tener 10 dígitos.';

  @override
  String get campoCpInvalido => 'Debe tener 5 dígitos.';

  @override
  String get campoIngresoInvalido =>
      'Debe ser mayor a cero (máximo 2 decimales).';

  @override
  String get campoContraseniaDebil => 'La contraseña no cumple los requisitos.';

  @override
  String get campoContraseniasDistintas => 'Las contraseñas no coinciden.';

  @override
  String get campoPinInvalido => 'El PIN debe tener 4 dígitos.';

  @override
  String get campoPinesDistintos => 'Los PIN no coinciden.';

  @override
  String get notificacionesTitulo => 'Notificaciones';

  @override
  String get notificacionesVacias => 'No tienes notificaciones';

  @override
  String get notificacionesMarcarTodas => 'Marcar todas';

  @override
  String get notificacionesMarcarLeida => 'Marcar leída';

  @override
  String get notificacionesTodas => 'Todas';

  @override
  String get notificacionesNoLeidas => 'No leídas';

  @override
  String get notificacionesMotivoRechazo => 'Motivo del rechazo';

  @override
  String get notificacionesEstadoSaldo => 'Estado del saldo';

  @override
  String get historialResumenCompras => 'Compras';

  @override
  String get historialResumenTotal => 'Total pagado';

  @override
  String get historialSoloExitosas =>
      'Compras confirmadas como exitosas por Gesto Pago.';

  @override
  String pagoSaldoInsuficiente(String saldo, String monto) {
    return 'Tu saldo disponible ($saldo) no cubre este pago de $monto.';
  }

  @override
  String get pagoSaldoDespues => 'Saldo después del pago';

  @override
  String get pagoSinCancelacion =>
      'Una vez autorizado con tu PIN, el pago no se puede cancelar.';

  @override
  String get pagoMontoAyuda => 'Hasta 2 decimales.';

  @override
  String get inicioRepetirCompra => 'Repetir una compra';

  @override
  String inicioRepetirSemantica(
    String producto,
    String referencia,
    String monto,
  ) {
    return 'Repetir $producto para $referencia por $monto';
  }

  @override
  String get comprobanteCompartir => 'Compartir comprobante';

  @override
  String get comprobanteCompartirImagen => 'Como imagen';

  @override
  String get comprobanteCompartirImagenDetalle => 'Ideal para WhatsApp o redes';

  @override
  String get comprobanteCompartirPdf => 'Como PDF';

  @override
  String get comprobanteCompartirPdfDetalle =>
      'Documento formal para imprimir o enviar por correo';

  @override
  String get comprobanteCompartirError =>
      'No se pudo generar el comprobante. Inténtalo de nuevo.';

  @override
  String get comprobanteDocumento => 'Comprobante de compra';

  @override
  String get comprobanteGenerado => 'Comprobante generado por Gesto Pago';

  @override
  String get comprobanteFolio => 'Folio';

  @override
  String get comprobanteServicio => 'Servicio';

  @override
  String get comprobanteProducto => 'Producto';

  @override
  String get comprobanteComision => 'Comisión';

  @override
  String get comprobanteTotal => 'Total';
}
