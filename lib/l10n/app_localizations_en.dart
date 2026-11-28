// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'GestoPago';

  @override
  String get commonLoading => 'Loading...';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonSave => 'Save';

  @override
  String get commonClose => 'Close';

  @override
  String get commonBack => 'Back';

  @override
  String get commonDone => 'Done';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get errorNetwork =>
      'Unable to reach the server. Check your connection.';

  @override
  String get errorTimeout =>
      'The server took too long to respond. Please try again.';

  @override
  String get errorUnauthorized =>
      'Your session has expired. Please log in again.';

  @override
  String get errorForbidden =>
      'You don\'t have permission to perform this action.';

  @override
  String get errorNotFound => 'The requested information was not found.';

  @override
  String get errorRateLimit => 'Too many attempts. Please try again shortly.';

  @override
  String get errorServer => 'Server error. Please try again later.';

  @override
  String get splashTagline => 'Pay your services in one place';

  @override
  String get splashRestoring => 'Restoring your session...';

  @override
  String get loginTitle => 'Welcome back';

  @override
  String get loginSubtitle => 'Sign in to pay your services';

  @override
  String get loginEmailLabel => 'Email';

  @override
  String get loginPasswordLabel => 'Password';

  @override
  String get loginEmailRequired => 'Enter your email';

  @override
  String get loginEmailInvalid => 'Invalid email';

  @override
  String get loginPasswordRequired => 'Enter your password';

  @override
  String get loginButton => 'Sign in';

  @override
  String get loginInvalidCredentials => 'Invalid email or password.';

  @override
  String get loginGenericError => 'Unable to sign in. Please try again.';

  @override
  String get loginNoAccount => 'Don\'t have an account?';

  @override
  String get loginCreateAccount => 'Create account';

  @override
  String get registerTitle => 'Create account';

  @override
  String get registerSubtitle => 'Register to get started';

  @override
  String get registerNameLabel => 'Full name';

  @override
  String get registerEmailLabel => 'Email';

  @override
  String get registerPasswordLabel => 'Password';

  @override
  String get registerConfirmPasswordLabel => 'Confirm password';

  @override
  String get registerNameRequired => 'Enter your name';

  @override
  String get registerPasswordTooShort => 'Use at least 6 characters';

  @override
  String get registerButton => 'Create account';

  @override
  String get registerPasswordMismatch => 'Passwords do not match.';

  @override
  String get registerAlreadyHaveAccount => 'Already have an account?';

  @override
  String get registerSignIn => 'Sign in';

  @override
  String get registerGenericError =>
      'Unable to create the account. Please try again.';

  @override
  String get homeWelcome => 'What would you like to pay today?';

  @override
  String homeGreeting(Object nombre) {
    return 'Hi, $nombre!';
  }

  @override
  String get navInicio => 'Home';

  @override
  String get navHistorial => 'History';

  @override
  String get navPerfil => 'Profile';

  @override
  String get homeCatalog => 'Services';

  @override
  String get homeProfile => 'Profile';

  @override
  String get catalogTitle => 'Services';

  @override
  String get catalogAll => 'All';

  @override
  String get catalogSearchHint => 'Search services...';

  @override
  String get catalogEmpty => 'No services available.';

  @override
  String get catalogPrice => 'Price';

  @override
  String get catalogCommission => 'Commission';

  @override
  String get catalogDetails => 'Service details';

  @override
  String get catalogReferenceTypeA => 'Mobile number';

  @override
  String get catalogReferenceTypeB => 'Customer / contract number';

  @override
  String get catalogReferenceTypeC => 'Barcode / reference';

  @override
  String get catalogReferenceDefault => 'Reference';

  @override
  String get catalogDigitoVerificador => 'Check digit';

  @override
  String get catalogHelp => 'Help';

  @override
  String get catalogError => 'Unable to load the catalog.';

  @override
  String get homeSectionPopular => 'Most popular';

  @override
  String get homeSectionRecent => 'Recent';

  @override
  String get homeSectionCatalog => 'Full catalog';

  @override
  String get pagoReferenceLabel => 'Reference';

  @override
  String get pagoReferenceHint => 'e.g. 6241234567';

  @override
  String get pagoReferenceRequired => 'Enter the reference';

  @override
  String get pagoServicioNoDisponible => 'This service is not available.';

  @override
  String get pagoAmountLabel => 'Amount to pay';

  @override
  String get pagoAmountHint => '0.00';

  @override
  String get pagoServiceLabel => 'Service';

  @override
  String get pagoVerifyReference => 'Verify reference';

  @override
  String get pagoVerifying => 'Verifying reference...';

  @override
  String get pagoVerifyValid => 'Valid reference';

  @override
  String pagoValidReferenceMessage(Object saldo) {
    return 'Valid reference. Balance: $saldo.';
  }

  @override
  String get pagoVerifyInvalid => 'Invalid reference. Check it and try again.';

  @override
  String get pagoVerifyError => 'Unable to verify the reference.';

  @override
  String get pagoInvalidAmount => 'Enter a valid amount.';

  @override
  String get pagoConfirmTitle => 'Confirm payment';

  @override
  String pagoConfirmMessage(Object amount, Object reference, Object service) {
    return 'You are about to pay $service reference $reference for $amount. Confirm that the data is correct.';
  }

  @override
  String get pagoConfirmService => 'Service';

  @override
  String get pagoConfirmReference => 'Reference';

  @override
  String get pagoConfirmAmount => 'Amount';

  @override
  String get pagoConfirmButton => 'Pay now';

  @override
  String get pagoEnviado =>
      'Payment sent. Waiting for provider confirmation...';

  @override
  String get pagoProcessing =>
      'Processing payment... You will be able to check the result at any time from your history.';

  @override
  String get pagoCheckingResult => 'Checking result with the provider...';

  @override
  String get pagoSuccess => 'Payment completed successfully';

  @override
  String get pagoAuthorization => 'Authorization';

  @override
  String get pagoTransactionId => 'Transaction';

  @override
  String get pagoFailed => 'The payment was not completed';

  @override
  String get pagoPending =>
      'Payment in process. We will confirm it with the provider.';

  @override
  String get pagoReceipt => 'Receipt';

  @override
  String get pagoSeeHistory => 'View history';

  @override
  String get pagoDoNotDoubleSubmit => 'Please wait, do not close the app.';

  @override
  String get comprobanteTitle => 'Payment receipt';

  @override
  String get comprobanteFecha => 'Date';

  @override
  String get comprobanteEstado => 'Status';

  @override
  String get comprobanteVolverInicio => 'Back to home';

  @override
  String get historialTitle => 'Payment history';

  @override
  String get historialEmpty => 'No payments yet.';

  @override
  String get historialError => 'Unable to load history.';

  @override
  String get historialFecha => 'Date';

  @override
  String get historialVerComprobante => 'View receipt';

  @override
  String get historialStateApproved => 'Approved';

  @override
  String get historialStateFailed => 'Failed';

  @override
  String get historialStateProcessing => 'In process';

  @override
  String get historialStatePending => 'Pending';

  @override
  String get perfilTitle => 'Profile';

  @override
  String get perfilName => 'Name';

  @override
  String get perfilEmail => 'Email';

  @override
  String get perfilEdit => 'Edit profile data';

  @override
  String get perfilPersonaName => 'Name';

  @override
  String get perfilPersonaPaternal => 'Paternal last name';

  @override
  String get perfilPersonaMaternal => 'Maternal last name';

  @override
  String get perfilSaveSuccess => 'Profile data saved correctly.';

  @override
  String get perfilTheme => 'Appearance';

  @override
  String get perfilThemeSystem => 'System';

  @override
  String get perfilThemeLight => 'Light';

  @override
  String get perfilThemeDark => 'Dark';

  @override
  String get perfilLogout => 'Sign out';

  @override
  String get perfilLogoutConfirm => 'Sign out?';

  @override
  String get perfilLogoutConfirmMessage =>
      'You will need your password to sign back in.';

  @override
  String get loginContinue => 'Continue';

  @override
  String get loginClosedRevoked =>
      'Your session was closed because you signed in on another device.';

  @override
  String get loginClosedExpired =>
      'Your session expired due to inactivity. Please sign in again.';

  @override
  String get loginClosedManual => 'You signed out successfully.';

  @override
  String get loginUserInactive =>
      'Your user is inactive. Contact your account executive.';

  @override
  String get loginLocked =>
      'Your access is temporarily locked after failed attempts. Try again in 15 minutes.';

  @override
  String get mfaTitle => 'Two-step verification';

  @override
  String get mfaEnrollTitle => 'Turn on verification';

  @override
  String get mfaInstructions =>
      'Open your authenticator app and enter the 6-digit Gesto Pago code.';

  @override
  String get mfaEnrollInstructions =>
      'For your security, link an authenticator app (Google or Microsoft Authenticator). You only do this once and use it on mobile and web.';

  @override
  String get mfaOpenAuthenticator => 'Open authenticator app';

  @override
  String get mfaCopyKey => 'Copy key';

  @override
  String get mfaKeyCopied =>
      'Key copied. Paste it into your authenticator app.';

  @override
  String get mfaManualKey => 'Key for manual entry';

  @override
  String get mfaShowQr => 'Show QR code';

  @override
  String get mfaQrHint =>
      'Scan it with the authenticator app on another device.';

  @override
  String get mfaCodeLabel => '6-digit code';

  @override
  String get mfaVerify => 'Verify and sign in';

  @override
  String get mfaInvalidCode =>
      'Wrong or already used code. Wait for the next code.';

  @override
  String get mfaCodeIncomplete =>
      'Enter the 6 digits from your authenticator app.';

  @override
  String get mfaExpired => 'Verification expired. Enter your password again.';

  @override
  String mfaExpiresIn(String time) {
    return 'This verification expires in $time';
  }

  @override
  String get mfaNoAuthenticator =>
      'No authenticator app found. Install Google Authenticator or Microsoft Authenticator, or copy the key.';

  @override
  String get mfaChangeAccount => 'Use another account';

  @override
  String get sessionActiveTitle => 'You already have an open session';

  @override
  String get sessionActiveWeb => 'Active session on the web';

  @override
  String get sessionActiveMobile => 'Active session on another phone';

  @override
  String sessionActiveLastActivity(String date) {
    return 'Last activity: $date';
  }

  @override
  String get sessionActiveMessage =>
      'For security you can only have one open session at a time. If you continue, the other session will be closed immediately.';

  @override
  String get sessionActiveNotYou =>
      'Wasn\'t you? Cancel and change your password from a trusted device.';

  @override
  String get sessionActiveConfirm => 'Close the other session and sign in';

  @override
  String get sessionActiveCancelled =>
      'You did not sign in. Your other session is still open.';

  @override
  String get pagoPinTitle => 'Authorize with your PIN';

  @override
  String pagoPinMessage(String account) {
    return 'Enter the 4-digit PIN for your account $account.';
  }

  @override
  String get pagoPinLabel => 'Authorization PIN';

  @override
  String get pagoPinInvalid => 'Wrong PIN. Check it and try again.';

  @override
  String get pagoPinFormat => 'The PIN has 4 digits.';

  @override
  String get pagoNoAccount => 'You have no active account to pay with.';

  @override
  String get pagoPayWith => 'Pay with';

  @override
  String get pagoAuthorize => 'Authorize payment';

  @override
  String get inicioBalance => 'Available balance';

  @override
  String inicioAccountType(String type) {
    return '$type account';
  }

  @override
  String get inicioShowBalance => 'Show balance';

  @override
  String get inicioHideBalance => 'Hide balance';

  @override
  String get inicioAccountError => 'We couldn\'t load your account.';

  @override
  String get perfilSecurity => 'Security';

  @override
  String get perfilTwoFactor => 'Two-step verification';

  @override
  String get perfilTwoFactorActive => 'On, with authenticator app';

  @override
  String get perfilSingleSession => 'Single session';

  @override
  String get perfilSingleSessionDesc =>
      'If you sign in on the web, this session will close.';

  @override
  String get perfilPin => 'Purchase PIN';

  @override
  String get perfilPinConfigured => 'Set';

  @override
  String get perfilPinPending => 'Not set';

  @override
  String get perfilChangePin => 'Change purchase PIN';

  @override
  String get perfilCurrentPassword => 'Current password';

  @override
  String get perfilNewPin => 'New PIN';

  @override
  String get perfilConfirmPin => 'Confirm PIN';

  @override
  String get perfilPinMismatch => 'PINs don\'t match.';

  @override
  String get perfilPinSaved => 'PIN updated.';

  @override
  String get perfilWrongPassword => 'The current password is wrong.';

  @override
  String get perfilPersonalData => 'Personal data';

  @override
  String get perfilPhone => 'Phone';

  @override
  String get perfilAddress => 'Address';

  @override
  String get perfilLastAccess => 'Last sign-in';

  @override
  String get perfilAccount => 'Account';

  @override
  String get perfilLogoutServer =>
      'Your session will be closed on the server. To sign in again you will need your password and verification code.';

  @override
  String get registroTitle => 'Open your account';

  @override
  String registroStepOf(String current, String total) {
    return 'Step $current of $total';
  }

  @override
  String get registroStepPersonal => 'Personal data';

  @override
  String get registroStepContact => 'Contact';

  @override
  String get registroStepAddress => 'Address';

  @override
  String get registroStepWork => 'Employment';

  @override
  String get registroStepAccess => 'Access and account';

  @override
  String get registroStepReview => 'Review';

  @override
  String registroOptional(String field) {
    return '$field (optional)';
  }

  @override
  String get registroNombre => 'First name';

  @override
  String get registroSegundoNombre => 'Middle name';

  @override
  String get registroApellidoPaterno => 'Paternal surname';

  @override
  String get registroApellidoMaterno => 'Maternal surname';

  @override
  String get registroFechaNacimiento => 'Date of birth';

  @override
  String get registroSexo => 'Sex';

  @override
  String get registroSexoHombre => 'Male';

  @override
  String get registroSexoMujer => 'Female';

  @override
  String get registroSexoOtro => 'Other';

  @override
  String get registroCurp => 'CURP';

  @override
  String get registroRfc => 'RFC with homoclave';

  @override
  String get registroNacionalidad => 'Nationality';

  @override
  String get registroEstadoCivil => 'Marital status';

  @override
  String get registroEcSoltero => 'Single';

  @override
  String get registroEcCasado => 'Married';

  @override
  String get registroEcDivorciado => 'Divorced';

  @override
  String get registroEcViudo => 'Widowed';

  @override
  String get registroEcUnionLibre => 'Civil union';

  @override
  String get registroEcSeparado => 'Separated';

  @override
  String get registroEcOtro => 'Other';

  @override
  String get registroCorreo => 'Email';

  @override
  String get registroCorreoAyuda => 'It will be your sign-in username.';

  @override
  String get registroTelefono => 'Mobile phone';

  @override
  String get registroTelefonoAlterno => 'Alternate phone';

  @override
  String get registroCalle => 'Street';

  @override
  String get registroNumExt => 'Street number';

  @override
  String get registroNumInt => 'Unit';

  @override
  String get registroColonia => 'Neighborhood';

  @override
  String get registroCp => 'Postal code';

  @override
  String get registroMunicipio => 'Municipality';

  @override
  String get registroEstado => 'State';

  @override
  String get registroPais => 'Country';

  @override
  String get registroOcupacion => 'Occupation';

  @override
  String get registroEmpresa => 'Company';

  @override
  String get registroIngreso => 'Monthly income (MXN)';

  @override
  String get registroContrasenia => 'Password';

  @override
  String get registroConfirmar => 'Confirm password';

  @override
  String get registroPin => 'Purchase PIN (4 digits)';

  @override
  String get registroPinAyuda => 'You\'ll use it to authorize each purchase.';

  @override
  String get registroTipoCuenta => 'Account type';

  @override
  String get registroTcAhorro => 'Savings';

  @override
  String get registroTcCorriente => 'Checking';

  @override
  String get registroTcNomina => 'Payroll';

  @override
  String get registroTcInversion => 'Investment';

  @override
  String get registroReglaLongitud => 'At least 8 characters';

  @override
  String get registroReglaMayuscula => 'One uppercase letter';

  @override
  String get registroReglaMinuscula => 'One lowercase letter';

  @override
  String get registroReglaNumero => 'One number';

  @override
  String get registroReglaEspecial => 'One special character';

  @override
  String get registroCuentaInfo =>
      'Your ACTIVE bank account will be created with the system-assigned opening balance, along with your sign-in user.';

  @override
  String get registroTerminos =>
      'I declare the information is true and accept the privacy notice.';

  @override
  String get registroTerminosRequerido => 'You must accept the privacy notice.';

  @override
  String get registroAnterior => 'Back';

  @override
  String get registroContinuar => 'Continue';

  @override
  String get registroEnviar => 'Open my account';

  @override
  String get registroEditar => 'Edit';

  @override
  String get registroError => 'We could not complete your registration';

  @override
  String registroExitoTitulo(String name) {
    return 'Welcome, $name!';
  }

  @override
  String get registroExitoMensaje =>
      'Your registration is complete and your account is ready.';

  @override
  String get registroExitoSiguiente =>
      'When you sign in you will turn on two-step verification.';

  @override
  String get registroNumeroCuenta => 'Account number';

  @override
  String get registroSaldoInicial => 'Opening balance';

  @override
  String get registroUsuario => 'Sign-in user';

  @override
  String get registroYaTengoCuenta => 'I already have an account';

  @override
  String get campoObligatorio => 'Required field';

  @override
  String get campoNombreInvalido => 'Letters and spaces only (2 to 50).';

  @override
  String get campoLongitud => 'Invalid length.';

  @override
  String get campoFechaFutura => 'Cannot be a future date.';

  @override
  String get campoMenorDeEdad => 'You must be over 18.';

  @override
  String get campoCurpInvalida => 'Invalid CURP (18 characters).';

  @override
  String get campoRfcInvalido => 'Invalid RFC (13 characters with homoclave).';

  @override
  String get campoCurpFecha =>
      'The CURP date doesn\'t match your date of birth.';

  @override
  String get campoRfcFecha => 'The RFC date doesn\'t match your date of birth.';

  @override
  String get campoCorreoInvalido => 'Invalid email.';

  @override
  String get campoTelefonoInvalido => 'Must have 10 digits.';

  @override
  String get campoCpInvalido => 'Must have 5 digits.';

  @override
  String get campoIngresoInvalido =>
      'Must be greater than zero (2 decimals max).';

  @override
  String get campoContraseniaDebil =>
      'The password doesn\'t meet the requirements.';

  @override
  String get campoContraseniasDistintas => 'Passwords don\'t match.';

  @override
  String get campoPinInvalido => 'The PIN must have 4 digits.';

  @override
  String get campoPinesDistintos => 'PINs don\'t match.';

  @override
  String get notificacionesTitulo => 'Notifications';

  @override
  String get notificacionesVacias => 'You have no notifications';

  @override
  String get notificacionesMarcarTodas => 'Mark all';

  @override
  String get notificacionesMarcarLeida => 'Mark read';

  @override
  String get notificacionesTodas => 'All';

  @override
  String get notificacionesNoLeidas => 'Unread';

  @override
  String get notificacionesMotivoRechazo => 'Reason for rejection';

  @override
  String get notificacionesEstadoSaldo => 'Balance status';

  @override
  String get historialResumenCompras => 'Purchases';

  @override
  String get historialResumenTotal => 'Total paid';

  @override
  String get historialSoloExitosas =>
      'Purchases confirmed as successful by Gesto Pago.';

  @override
  String pagoSaldoInsuficiente(String saldo, String monto) {
    return 'Your available balance ($saldo) does not cover this $monto payment.';
  }

  @override
  String get pagoSaldoDespues => 'Balance after payment';

  @override
  String get pagoSinCancelacion =>
      'Once authorized with your PIN, the payment cannot be cancelled.';

  @override
  String get pagoMontoAyuda => 'Up to 2 decimals.';

  @override
  String get inicioRepetirCompra => 'Buy again';

  @override
  String inicioRepetirSemantica(
    String producto,
    String referencia,
    String monto,
  ) {
    return 'Repeat $producto for $referencia for $monto';
  }

  @override
  String get comprobanteCompartir => 'Share receipt';

  @override
  String get comprobanteCompartirImagen => 'As image';

  @override
  String get comprobanteCompartirImagenDetalle =>
      'Great for WhatsApp or social apps';

  @override
  String get comprobanteCompartirPdf => 'As PDF';

  @override
  String get comprobanteCompartirPdfDetalle =>
      'Formal document to print or email';

  @override
  String get comprobanteCompartirError =>
      'The receipt could not be generated. Please try again.';

  @override
  String get comprobanteDocumento => 'Purchase receipt';

  @override
  String get comprobanteGenerado => 'Receipt generated by Gesto Pago';

  @override
  String get comprobanteFolio => 'Folio';

  @override
  String get comprobanteServicio => 'Service';

  @override
  String get comprobanteProducto => 'Product';

  @override
  String get comprobanteComision => 'Fee';

  @override
  String get comprobanteTotal => 'Total';
}
