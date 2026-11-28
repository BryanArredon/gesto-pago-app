import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'GestoPago'**
  String get appTitle;

  /// No description provided for @commonLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get commonLoading;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get commonConfirm;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// No description provided for @commonDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get commonDone;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Unable to reach the server. Check your connection.'**
  String get errorNetwork;

  /// No description provided for @errorTimeout.
  ///
  /// In en, this message translates to:
  /// **'The server took too long to respond. Please try again.'**
  String get errorTimeout;

  /// No description provided for @errorUnauthorized.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please log in again.'**
  String get errorUnauthorized;

  /// No description provided for @errorForbidden.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have permission to perform this action.'**
  String get errorForbidden;

  /// No description provided for @errorNotFound.
  ///
  /// In en, this message translates to:
  /// **'The requested information was not found.'**
  String get errorNotFound;

  /// No description provided for @errorRateLimit.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please try again shortly.'**
  String get errorRateLimit;

  /// No description provided for @errorServer.
  ///
  /// In en, this message translates to:
  /// **'Server error. Please try again later.'**
  String get errorServer;

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'Pay your services in one place'**
  String get splashTagline;

  /// No description provided for @splashRestoring.
  ///
  /// In en, this message translates to:
  /// **'Restoring your session...'**
  String get splashRestoring;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to pay your services'**
  String get loginSubtitle;

  /// No description provided for @loginEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get loginEmailLabel;

  /// No description provided for @loginPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPasswordLabel;

  /// No description provided for @loginEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get loginEmailRequired;

  /// No description provided for @loginEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get loginEmailInvalid;

  /// No description provided for @loginPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get loginPasswordRequired;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginButton;

  /// No description provided for @loginInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password.'**
  String get loginInvalidCredentials;

  /// No description provided for @loginGenericError.
  ///
  /// In en, this message translates to:
  /// **'Unable to sign in. Please try again.'**
  String get loginGenericError;

  /// No description provided for @loginNoAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get loginNoAccount;

  /// No description provided for @loginCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get loginCreateAccount;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Register to get started'**
  String get registerSubtitle;

  /// No description provided for @registerNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get registerNameLabel;

  /// No description provided for @registerEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get registerEmailLabel;

  /// No description provided for @registerPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get registerPasswordLabel;

  /// No description provided for @registerConfirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get registerConfirmPasswordLabel;

  /// No description provided for @registerNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get registerNameRequired;

  /// No description provided for @registerPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Use at least 6 characters'**
  String get registerPasswordTooShort;

  /// No description provided for @registerButton.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get registerButton;

  /// No description provided for @registerPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get registerPasswordMismatch;

  /// No description provided for @registerAlreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get registerAlreadyHaveAccount;

  /// No description provided for @registerSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get registerSignIn;

  /// No description provided for @registerGenericError.
  ///
  /// In en, this message translates to:
  /// **'Unable to create the account. Please try again.'**
  String get registerGenericError;

  /// No description provided for @homeWelcome.
  ///
  /// In en, this message translates to:
  /// **'What would you like to pay today?'**
  String get homeWelcome;

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hi, {nombre}!'**
  String homeGreeting(Object nombre);

  /// No description provided for @navInicio.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navInicio;

  /// No description provided for @navHistorial.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get navHistorial;

  /// No description provided for @navPerfil.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navPerfil;

  /// No description provided for @homeCatalog.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get homeCatalog;

  /// No description provided for @homeProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get homeProfile;

  /// No description provided for @catalogTitle.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get catalogTitle;

  /// No description provided for @catalogAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get catalogAll;

  /// No description provided for @catalogSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search services...'**
  String get catalogSearchHint;

  /// No description provided for @catalogEmpty.
  ///
  /// In en, this message translates to:
  /// **'No services available.'**
  String get catalogEmpty;

  /// No description provided for @catalogPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get catalogPrice;

  /// No description provided for @catalogCommission.
  ///
  /// In en, this message translates to:
  /// **'Commission'**
  String get catalogCommission;

  /// No description provided for @catalogDetails.
  ///
  /// In en, this message translates to:
  /// **'Service details'**
  String get catalogDetails;

  /// No description provided for @catalogReferenceTypeA.
  ///
  /// In en, this message translates to:
  /// **'Mobile number'**
  String get catalogReferenceTypeA;

  /// No description provided for @catalogReferenceTypeB.
  ///
  /// In en, this message translates to:
  /// **'Customer / contract number'**
  String get catalogReferenceTypeB;

  /// No description provided for @catalogReferenceTypeC.
  ///
  /// In en, this message translates to:
  /// **'Barcode / reference'**
  String get catalogReferenceTypeC;

  /// No description provided for @catalogReferenceDefault.
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get catalogReferenceDefault;

  /// No description provided for @catalogDigitoVerificador.
  ///
  /// In en, this message translates to:
  /// **'Check digit'**
  String get catalogDigitoVerificador;

  /// No description provided for @catalogHelp.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get catalogHelp;

  /// No description provided for @catalogError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load the catalog.'**
  String get catalogError;

  /// No description provided for @homeSectionPopular.
  ///
  /// In en, this message translates to:
  /// **'Most popular'**
  String get homeSectionPopular;

  /// No description provided for @homeSectionRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get homeSectionRecent;

  /// No description provided for @homeSectionCatalog.
  ///
  /// In en, this message translates to:
  /// **'Full catalog'**
  String get homeSectionCatalog;

  /// No description provided for @pagoReferenceLabel.
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get pagoReferenceLabel;

  /// No description provided for @pagoReferenceHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 6241234567'**
  String get pagoReferenceHint;

  /// No description provided for @pagoReferenceRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter the reference'**
  String get pagoReferenceRequired;

  /// No description provided for @pagoServicioNoDisponible.
  ///
  /// In en, this message translates to:
  /// **'This service is not available.'**
  String get pagoServicioNoDisponible;

  /// No description provided for @pagoAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount to pay'**
  String get pagoAmountLabel;

  /// No description provided for @pagoAmountHint.
  ///
  /// In en, this message translates to:
  /// **'0.00'**
  String get pagoAmountHint;

  /// No description provided for @pagoServiceLabel.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get pagoServiceLabel;

  /// No description provided for @pagoVerifyReference.
  ///
  /// In en, this message translates to:
  /// **'Verify reference'**
  String get pagoVerifyReference;

  /// No description provided for @pagoVerifying.
  ///
  /// In en, this message translates to:
  /// **'Verifying reference...'**
  String get pagoVerifying;

  /// No description provided for @pagoVerifyValid.
  ///
  /// In en, this message translates to:
  /// **'Valid reference'**
  String get pagoVerifyValid;

  /// No description provided for @pagoValidReferenceMessage.
  ///
  /// In en, this message translates to:
  /// **'Valid reference. Balance: {saldo}.'**
  String pagoValidReferenceMessage(Object saldo);

  /// No description provided for @pagoVerifyInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid reference. Check it and try again.'**
  String get pagoVerifyInvalid;

  /// No description provided for @pagoVerifyError.
  ///
  /// In en, this message translates to:
  /// **'Unable to verify the reference.'**
  String get pagoVerifyError;

  /// No description provided for @pagoInvalidAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount.'**
  String get pagoInvalidAmount;

  /// No description provided for @pagoConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm payment'**
  String get pagoConfirmTitle;

  /// No description provided for @pagoConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'You are about to pay {service} reference {reference} for {amount}. Confirm that the data is correct.'**
  String pagoConfirmMessage(Object amount, Object reference, Object service);

  /// No description provided for @pagoConfirmService.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get pagoConfirmService;

  /// No description provided for @pagoConfirmReference.
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get pagoConfirmReference;

  /// No description provided for @pagoConfirmAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get pagoConfirmAmount;

  /// No description provided for @pagoConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Pay now'**
  String get pagoConfirmButton;

  /// No description provided for @pagoEnviado.
  ///
  /// In en, this message translates to:
  /// **'Payment sent. Waiting for provider confirmation...'**
  String get pagoEnviado;

  /// No description provided for @pagoProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing payment... You will be able to check the result at any time from your history.'**
  String get pagoProcessing;

  /// No description provided for @pagoCheckingResult.
  ///
  /// In en, this message translates to:
  /// **'Checking result with the provider...'**
  String get pagoCheckingResult;

  /// No description provided for @pagoSuccess.
  ///
  /// In en, this message translates to:
  /// **'Payment completed successfully'**
  String get pagoSuccess;

  /// No description provided for @pagoAuthorization.
  ///
  /// In en, this message translates to:
  /// **'Authorization'**
  String get pagoAuthorization;

  /// No description provided for @pagoTransactionId.
  ///
  /// In en, this message translates to:
  /// **'Transaction'**
  String get pagoTransactionId;

  /// No description provided for @pagoFailed.
  ///
  /// In en, this message translates to:
  /// **'The payment was not completed'**
  String get pagoFailed;

  /// No description provided for @pagoPending.
  ///
  /// In en, this message translates to:
  /// **'Payment in process. We will confirm it with the provider.'**
  String get pagoPending;

  /// No description provided for @pagoReceipt.
  ///
  /// In en, this message translates to:
  /// **'Receipt'**
  String get pagoReceipt;

  /// No description provided for @pagoSeeHistory.
  ///
  /// In en, this message translates to:
  /// **'View history'**
  String get pagoSeeHistory;

  /// No description provided for @pagoDoNotDoubleSubmit.
  ///
  /// In en, this message translates to:
  /// **'Please wait, do not close the app.'**
  String get pagoDoNotDoubleSubmit;

  /// No description provided for @comprobanteTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment receipt'**
  String get comprobanteTitle;

  /// No description provided for @comprobanteFecha.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get comprobanteFecha;

  /// No description provided for @comprobanteEstado.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get comprobanteEstado;

  /// No description provided for @comprobanteVolverInicio.
  ///
  /// In en, this message translates to:
  /// **'Back to home'**
  String get comprobanteVolverInicio;

  /// No description provided for @historialTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment history'**
  String get historialTitle;

  /// No description provided for @historialEmpty.
  ///
  /// In en, this message translates to:
  /// **'No payments yet.'**
  String get historialEmpty;

  /// No description provided for @historialError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load history.'**
  String get historialError;

  /// No description provided for @historialFecha.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get historialFecha;

  /// No description provided for @historialVerComprobante.
  ///
  /// In en, this message translates to:
  /// **'View receipt'**
  String get historialVerComprobante;

  /// No description provided for @historialStateApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get historialStateApproved;

  /// No description provided for @historialStateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get historialStateFailed;

  /// No description provided for @historialStateProcessing.
  ///
  /// In en, this message translates to:
  /// **'In process'**
  String get historialStateProcessing;

  /// No description provided for @historialStatePending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get historialStatePending;

  /// No description provided for @perfilTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get perfilTitle;

  /// No description provided for @perfilName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get perfilName;

  /// No description provided for @perfilEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get perfilEmail;

  /// No description provided for @perfilEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit profile data'**
  String get perfilEdit;

  /// No description provided for @perfilPersonaName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get perfilPersonaName;

  /// No description provided for @perfilPersonaPaternal.
  ///
  /// In en, this message translates to:
  /// **'Paternal last name'**
  String get perfilPersonaPaternal;

  /// No description provided for @perfilPersonaMaternal.
  ///
  /// In en, this message translates to:
  /// **'Maternal last name'**
  String get perfilPersonaMaternal;

  /// No description provided for @perfilSaveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile data saved correctly.'**
  String get perfilSaveSuccess;

  /// No description provided for @perfilTheme.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get perfilTheme;

  /// No description provided for @perfilThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get perfilThemeSystem;

  /// No description provided for @perfilThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get perfilThemeLight;

  /// No description provided for @perfilThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get perfilThemeDark;

  /// No description provided for @perfilLogout.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get perfilLogout;

  /// No description provided for @perfilLogoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get perfilLogoutConfirm;

  /// No description provided for @perfilLogoutConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'You will need your password to sign back in.'**
  String get perfilLogoutConfirmMessage;

  /// No description provided for @loginContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get loginContinue;

  /// No description provided for @loginClosedRevoked.
  ///
  /// In en, this message translates to:
  /// **'Your session was closed because you signed in on another device.'**
  String get loginClosedRevoked;

  /// No description provided for @loginClosedExpired.
  ///
  /// In en, this message translates to:
  /// **'Your session expired due to inactivity. Please sign in again.'**
  String get loginClosedExpired;

  /// No description provided for @loginClosedManual.
  ///
  /// In en, this message translates to:
  /// **'You signed out successfully.'**
  String get loginClosedManual;

  /// No description provided for @loginUserInactive.
  ///
  /// In en, this message translates to:
  /// **'Your user is inactive. Contact your account executive.'**
  String get loginUserInactive;

  /// No description provided for @loginLocked.
  ///
  /// In en, this message translates to:
  /// **'Your access is temporarily locked after failed attempts. Try again in 15 minutes.'**
  String get loginLocked;

  /// No description provided for @mfaTitle.
  ///
  /// In en, this message translates to:
  /// **'Two-step verification'**
  String get mfaTitle;

  /// No description provided for @mfaEnrollTitle.
  ///
  /// In en, this message translates to:
  /// **'Turn on verification'**
  String get mfaEnrollTitle;

  /// No description provided for @mfaInstructions.
  ///
  /// In en, this message translates to:
  /// **'Open your authenticator app and enter the 6-digit Gesto Pago code.'**
  String get mfaInstructions;

  /// No description provided for @mfaEnrollInstructions.
  ///
  /// In en, this message translates to:
  /// **'For your security, link an authenticator app (Google or Microsoft Authenticator). You only do this once and use it on mobile and web.'**
  String get mfaEnrollInstructions;

  /// No description provided for @mfaOpenAuthenticator.
  ///
  /// In en, this message translates to:
  /// **'Open authenticator app'**
  String get mfaOpenAuthenticator;

  /// No description provided for @mfaCopyKey.
  ///
  /// In en, this message translates to:
  /// **'Copy key'**
  String get mfaCopyKey;

  /// No description provided for @mfaKeyCopied.
  ///
  /// In en, this message translates to:
  /// **'Key copied. Paste it into your authenticator app.'**
  String get mfaKeyCopied;

  /// No description provided for @mfaManualKey.
  ///
  /// In en, this message translates to:
  /// **'Key for manual entry'**
  String get mfaManualKey;

  /// No description provided for @mfaShowQr.
  ///
  /// In en, this message translates to:
  /// **'Show QR code'**
  String get mfaShowQr;

  /// No description provided for @mfaQrHint.
  ///
  /// In en, this message translates to:
  /// **'Scan it with the authenticator app on another device.'**
  String get mfaQrHint;

  /// No description provided for @mfaCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'6-digit code'**
  String get mfaCodeLabel;

  /// No description provided for @mfaVerify.
  ///
  /// In en, this message translates to:
  /// **'Verify and sign in'**
  String get mfaVerify;

  /// No description provided for @mfaInvalidCode.
  ///
  /// In en, this message translates to:
  /// **'Wrong or already used code. Wait for the next code.'**
  String get mfaInvalidCode;

  /// No description provided for @mfaCodeIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6 digits from your authenticator app.'**
  String get mfaCodeIncomplete;

  /// No description provided for @mfaExpired.
  ///
  /// In en, this message translates to:
  /// **'Verification expired. Enter your password again.'**
  String get mfaExpired;

  /// No description provided for @mfaExpiresIn.
  ///
  /// In en, this message translates to:
  /// **'This verification expires in {time}'**
  String mfaExpiresIn(String time);

  /// No description provided for @mfaNoAuthenticator.
  ///
  /// In en, this message translates to:
  /// **'No authenticator app found. Install Google Authenticator or Microsoft Authenticator, or copy the key.'**
  String get mfaNoAuthenticator;

  /// No description provided for @mfaChangeAccount.
  ///
  /// In en, this message translates to:
  /// **'Use another account'**
  String get mfaChangeAccount;

  /// No description provided for @sessionActiveTitle.
  ///
  /// In en, this message translates to:
  /// **'You already have an open session'**
  String get sessionActiveTitle;

  /// No description provided for @sessionActiveWeb.
  ///
  /// In en, this message translates to:
  /// **'Active session on the web'**
  String get sessionActiveWeb;

  /// No description provided for @sessionActiveMobile.
  ///
  /// In en, this message translates to:
  /// **'Active session on another phone'**
  String get sessionActiveMobile;

  /// No description provided for @sessionActiveLastActivity.
  ///
  /// In en, this message translates to:
  /// **'Last activity: {date}'**
  String sessionActiveLastActivity(String date);

  /// No description provided for @sessionActiveMessage.
  ///
  /// In en, this message translates to:
  /// **'For security you can only have one open session at a time. If you continue, the other session will be closed immediately.'**
  String get sessionActiveMessage;

  /// No description provided for @sessionActiveNotYou.
  ///
  /// In en, this message translates to:
  /// **'Wasn\'t you? Cancel and change your password from a trusted device.'**
  String get sessionActiveNotYou;

  /// No description provided for @sessionActiveConfirm.
  ///
  /// In en, this message translates to:
  /// **'Close the other session and sign in'**
  String get sessionActiveConfirm;

  /// No description provided for @sessionActiveCancelled.
  ///
  /// In en, this message translates to:
  /// **'You did not sign in. Your other session is still open.'**
  String get sessionActiveCancelled;

  /// No description provided for @pagoPinTitle.
  ///
  /// In en, this message translates to:
  /// **'Authorize with your PIN'**
  String get pagoPinTitle;

  /// No description provided for @pagoPinMessage.
  ///
  /// In en, this message translates to:
  /// **'Enter the 4-digit PIN for your account {account}.'**
  String pagoPinMessage(String account);

  /// No description provided for @pagoPinLabel.
  ///
  /// In en, this message translates to:
  /// **'Authorization PIN'**
  String get pagoPinLabel;

  /// No description provided for @pagoPinInvalid.
  ///
  /// In en, this message translates to:
  /// **'Wrong PIN. Check it and try again.'**
  String get pagoPinInvalid;

  /// No description provided for @pagoPinFormat.
  ///
  /// In en, this message translates to:
  /// **'The PIN has 4 digits.'**
  String get pagoPinFormat;

  /// No description provided for @pagoNoAccount.
  ///
  /// In en, this message translates to:
  /// **'You have no active account to pay with.'**
  String get pagoNoAccount;

  /// No description provided for @pagoPayWith.
  ///
  /// In en, this message translates to:
  /// **'Pay with'**
  String get pagoPayWith;

  /// No description provided for @pagoAuthorize.
  ///
  /// In en, this message translates to:
  /// **'Authorize payment'**
  String get pagoAuthorize;

  /// No description provided for @inicioBalance.
  ///
  /// In en, this message translates to:
  /// **'Available balance'**
  String get inicioBalance;

  /// No description provided for @inicioAccountType.
  ///
  /// In en, this message translates to:
  /// **'{type} account'**
  String inicioAccountType(String type);

  /// No description provided for @inicioShowBalance.
  ///
  /// In en, this message translates to:
  /// **'Show balance'**
  String get inicioShowBalance;

  /// No description provided for @inicioHideBalance.
  ///
  /// In en, this message translates to:
  /// **'Hide balance'**
  String get inicioHideBalance;

  /// No description provided for @inicioAccountError.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load your account.'**
  String get inicioAccountError;

  /// No description provided for @perfilSecurity.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get perfilSecurity;

  /// No description provided for @perfilTwoFactor.
  ///
  /// In en, this message translates to:
  /// **'Two-step verification'**
  String get perfilTwoFactor;

  /// No description provided for @perfilTwoFactorActive.
  ///
  /// In en, this message translates to:
  /// **'On, with authenticator app'**
  String get perfilTwoFactorActive;

  /// No description provided for @perfilSingleSession.
  ///
  /// In en, this message translates to:
  /// **'Single session'**
  String get perfilSingleSession;

  /// No description provided for @perfilSingleSessionDesc.
  ///
  /// In en, this message translates to:
  /// **'If you sign in on the web, this session will close.'**
  String get perfilSingleSessionDesc;

  /// No description provided for @perfilPin.
  ///
  /// In en, this message translates to:
  /// **'Purchase PIN'**
  String get perfilPin;

  /// No description provided for @perfilPinConfigured.
  ///
  /// In en, this message translates to:
  /// **'Set'**
  String get perfilPinConfigured;

  /// No description provided for @perfilPinPending.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get perfilPinPending;

  /// No description provided for @perfilChangePin.
  ///
  /// In en, this message translates to:
  /// **'Change purchase PIN'**
  String get perfilChangePin;

  /// No description provided for @perfilCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get perfilCurrentPassword;

  /// No description provided for @perfilNewPin.
  ///
  /// In en, this message translates to:
  /// **'New PIN'**
  String get perfilNewPin;

  /// No description provided for @perfilConfirmPin.
  ///
  /// In en, this message translates to:
  /// **'Confirm PIN'**
  String get perfilConfirmPin;

  /// No description provided for @perfilPinMismatch.
  ///
  /// In en, this message translates to:
  /// **'PINs don\'t match.'**
  String get perfilPinMismatch;

  /// No description provided for @perfilPinSaved.
  ///
  /// In en, this message translates to:
  /// **'PIN updated.'**
  String get perfilPinSaved;

  /// No description provided for @perfilWrongPassword.
  ///
  /// In en, this message translates to:
  /// **'The current password is wrong.'**
  String get perfilWrongPassword;

  /// No description provided for @perfilPersonalData.
  ///
  /// In en, this message translates to:
  /// **'Personal data'**
  String get perfilPersonalData;

  /// No description provided for @perfilPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get perfilPhone;

  /// No description provided for @perfilAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get perfilAddress;

  /// No description provided for @perfilLastAccess.
  ///
  /// In en, this message translates to:
  /// **'Last sign-in'**
  String get perfilLastAccess;

  /// No description provided for @perfilAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get perfilAccount;

  /// No description provided for @perfilLogoutServer.
  ///
  /// In en, this message translates to:
  /// **'Your session will be closed on the server. To sign in again you will need your password and verification code.'**
  String get perfilLogoutServer;

  /// No description provided for @registroTitle.
  ///
  /// In en, this message translates to:
  /// **'Open your account'**
  String get registroTitle;

  /// No description provided for @registroStepOf.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String registroStepOf(String current, String total);

  /// No description provided for @registroStepPersonal.
  ///
  /// In en, this message translates to:
  /// **'Personal data'**
  String get registroStepPersonal;

  /// No description provided for @registroStepContact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get registroStepContact;

  /// No description provided for @registroStepAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get registroStepAddress;

  /// No description provided for @registroStepWork.
  ///
  /// In en, this message translates to:
  /// **'Employment'**
  String get registroStepWork;

  /// No description provided for @registroStepAccess.
  ///
  /// In en, this message translates to:
  /// **'Access and account'**
  String get registroStepAccess;

  /// No description provided for @registroStepReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get registroStepReview;

  /// No description provided for @registroOptional.
  ///
  /// In en, this message translates to:
  /// **'{field} (optional)'**
  String registroOptional(String field);

  /// No description provided for @registroNombre.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get registroNombre;

  /// No description provided for @registroSegundoNombre.
  ///
  /// In en, this message translates to:
  /// **'Middle name'**
  String get registroSegundoNombre;

  /// No description provided for @registroApellidoPaterno.
  ///
  /// In en, this message translates to:
  /// **'Paternal surname'**
  String get registroApellidoPaterno;

  /// No description provided for @registroApellidoMaterno.
  ///
  /// In en, this message translates to:
  /// **'Maternal surname'**
  String get registroApellidoMaterno;

  /// No description provided for @registroFechaNacimiento.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get registroFechaNacimiento;

  /// No description provided for @registroSexo.
  ///
  /// In en, this message translates to:
  /// **'Sex'**
  String get registroSexo;

  /// No description provided for @registroSexoHombre.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get registroSexoHombre;

  /// No description provided for @registroSexoMujer.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get registroSexoMujer;

  /// No description provided for @registroSexoOtro.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get registroSexoOtro;

  /// No description provided for @registroCurp.
  ///
  /// In en, this message translates to:
  /// **'CURP'**
  String get registroCurp;

  /// No description provided for @registroRfc.
  ///
  /// In en, this message translates to:
  /// **'RFC with homoclave'**
  String get registroRfc;

  /// No description provided for @registroNacionalidad.
  ///
  /// In en, this message translates to:
  /// **'Nationality'**
  String get registroNacionalidad;

  /// No description provided for @registroEstadoCivil.
  ///
  /// In en, this message translates to:
  /// **'Marital status'**
  String get registroEstadoCivil;

  /// No description provided for @registroEcSoltero.
  ///
  /// In en, this message translates to:
  /// **'Single'**
  String get registroEcSoltero;

  /// No description provided for @registroEcCasado.
  ///
  /// In en, this message translates to:
  /// **'Married'**
  String get registroEcCasado;

  /// No description provided for @registroEcDivorciado.
  ///
  /// In en, this message translates to:
  /// **'Divorced'**
  String get registroEcDivorciado;

  /// No description provided for @registroEcViudo.
  ///
  /// In en, this message translates to:
  /// **'Widowed'**
  String get registroEcViudo;

  /// No description provided for @registroEcUnionLibre.
  ///
  /// In en, this message translates to:
  /// **'Civil union'**
  String get registroEcUnionLibre;

  /// No description provided for @registroEcSeparado.
  ///
  /// In en, this message translates to:
  /// **'Separated'**
  String get registroEcSeparado;

  /// No description provided for @registroEcOtro.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get registroEcOtro;

  /// No description provided for @registroCorreo.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get registroCorreo;

  /// No description provided for @registroCorreoAyuda.
  ///
  /// In en, this message translates to:
  /// **'It will be your sign-in username.'**
  String get registroCorreoAyuda;

  /// No description provided for @registroTelefono.
  ///
  /// In en, this message translates to:
  /// **'Mobile phone'**
  String get registroTelefono;

  /// No description provided for @registroTelefonoAlterno.
  ///
  /// In en, this message translates to:
  /// **'Alternate phone'**
  String get registroTelefonoAlterno;

  /// No description provided for @registroCalle.
  ///
  /// In en, this message translates to:
  /// **'Street'**
  String get registroCalle;

  /// No description provided for @registroNumExt.
  ///
  /// In en, this message translates to:
  /// **'Street number'**
  String get registroNumExt;

  /// No description provided for @registroNumInt.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get registroNumInt;

  /// No description provided for @registroColonia.
  ///
  /// In en, this message translates to:
  /// **'Neighborhood'**
  String get registroColonia;

  /// No description provided for @registroCp.
  ///
  /// In en, this message translates to:
  /// **'Postal code'**
  String get registroCp;

  /// No description provided for @registroMunicipio.
  ///
  /// In en, this message translates to:
  /// **'Municipality'**
  String get registroMunicipio;

  /// No description provided for @registroEstado.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get registroEstado;

  /// No description provided for @registroPais.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get registroPais;

  /// No description provided for @registroOcupacion.
  ///
  /// In en, this message translates to:
  /// **'Occupation'**
  String get registroOcupacion;

  /// No description provided for @registroEmpresa.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get registroEmpresa;

  /// No description provided for @registroIngreso.
  ///
  /// In en, this message translates to:
  /// **'Monthly income (MXN)'**
  String get registroIngreso;

  /// No description provided for @registroContrasenia.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get registroContrasenia;

  /// No description provided for @registroConfirmar.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get registroConfirmar;

  /// No description provided for @registroPin.
  ///
  /// In en, this message translates to:
  /// **'Purchase PIN (4 digits)'**
  String get registroPin;

  /// No description provided for @registroPinAyuda.
  ///
  /// In en, this message translates to:
  /// **'You\'ll use it to authorize each purchase.'**
  String get registroPinAyuda;

  /// No description provided for @registroTipoCuenta.
  ///
  /// In en, this message translates to:
  /// **'Account type'**
  String get registroTipoCuenta;

  /// No description provided for @registroTcAhorro.
  ///
  /// In en, this message translates to:
  /// **'Savings'**
  String get registroTcAhorro;

  /// No description provided for @registroTcCorriente.
  ///
  /// In en, this message translates to:
  /// **'Checking'**
  String get registroTcCorriente;

  /// No description provided for @registroTcNomina.
  ///
  /// In en, this message translates to:
  /// **'Payroll'**
  String get registroTcNomina;

  /// No description provided for @registroTcInversion.
  ///
  /// In en, this message translates to:
  /// **'Investment'**
  String get registroTcInversion;

  /// No description provided for @registroReglaLongitud.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get registroReglaLongitud;

  /// No description provided for @registroReglaMayuscula.
  ///
  /// In en, this message translates to:
  /// **'One uppercase letter'**
  String get registroReglaMayuscula;

  /// No description provided for @registroReglaMinuscula.
  ///
  /// In en, this message translates to:
  /// **'One lowercase letter'**
  String get registroReglaMinuscula;

  /// No description provided for @registroReglaNumero.
  ///
  /// In en, this message translates to:
  /// **'One number'**
  String get registroReglaNumero;

  /// No description provided for @registroReglaEspecial.
  ///
  /// In en, this message translates to:
  /// **'One special character'**
  String get registroReglaEspecial;

  /// No description provided for @registroCuentaInfo.
  ///
  /// In en, this message translates to:
  /// **'Your ACTIVE bank account will be created with the system-assigned opening balance, along with your sign-in user.'**
  String get registroCuentaInfo;

  /// No description provided for @registroTerminos.
  ///
  /// In en, this message translates to:
  /// **'I declare the information is true and accept the privacy notice.'**
  String get registroTerminos;

  /// No description provided for @registroTerminosRequerido.
  ///
  /// In en, this message translates to:
  /// **'You must accept the privacy notice.'**
  String get registroTerminosRequerido;

  /// No description provided for @registroAnterior.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get registroAnterior;

  /// No description provided for @registroContinuar.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get registroContinuar;

  /// No description provided for @registroEnviar.
  ///
  /// In en, this message translates to:
  /// **'Open my account'**
  String get registroEnviar;

  /// No description provided for @registroEditar.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get registroEditar;

  /// No description provided for @registroError.
  ///
  /// In en, this message translates to:
  /// **'We could not complete your registration'**
  String get registroError;

  /// No description provided for @registroExitoTitulo.
  ///
  /// In en, this message translates to:
  /// **'Welcome, {name}!'**
  String registroExitoTitulo(String name);

  /// No description provided for @registroExitoMensaje.
  ///
  /// In en, this message translates to:
  /// **'Your registration is complete and your account is ready.'**
  String get registroExitoMensaje;

  /// No description provided for @registroExitoSiguiente.
  ///
  /// In en, this message translates to:
  /// **'When you sign in you will turn on two-step verification.'**
  String get registroExitoSiguiente;

  /// No description provided for @registroNumeroCuenta.
  ///
  /// In en, this message translates to:
  /// **'Account number'**
  String get registroNumeroCuenta;

  /// No description provided for @registroSaldoInicial.
  ///
  /// In en, this message translates to:
  /// **'Opening balance'**
  String get registroSaldoInicial;

  /// No description provided for @registroUsuario.
  ///
  /// In en, this message translates to:
  /// **'Sign-in user'**
  String get registroUsuario;

  /// No description provided for @registroYaTengoCuenta.
  ///
  /// In en, this message translates to:
  /// **'I already have an account'**
  String get registroYaTengoCuenta;

  /// No description provided for @campoObligatorio.
  ///
  /// In en, this message translates to:
  /// **'Required field'**
  String get campoObligatorio;

  /// No description provided for @campoNombreInvalido.
  ///
  /// In en, this message translates to:
  /// **'Letters and spaces only (2 to 50).'**
  String get campoNombreInvalido;

  /// No description provided for @campoLongitud.
  ///
  /// In en, this message translates to:
  /// **'Invalid length.'**
  String get campoLongitud;

  /// No description provided for @campoFechaFutura.
  ///
  /// In en, this message translates to:
  /// **'Cannot be a future date.'**
  String get campoFechaFutura;

  /// No description provided for @campoMenorDeEdad.
  ///
  /// In en, this message translates to:
  /// **'You must be over 18.'**
  String get campoMenorDeEdad;

  /// No description provided for @campoCurpInvalida.
  ///
  /// In en, this message translates to:
  /// **'Invalid CURP (18 characters).'**
  String get campoCurpInvalida;

  /// No description provided for @campoRfcInvalido.
  ///
  /// In en, this message translates to:
  /// **'Invalid RFC (13 characters with homoclave).'**
  String get campoRfcInvalido;

  /// No description provided for @campoCurpFecha.
  ///
  /// In en, this message translates to:
  /// **'The CURP date doesn\'t match your date of birth.'**
  String get campoCurpFecha;

  /// No description provided for @campoRfcFecha.
  ///
  /// In en, this message translates to:
  /// **'The RFC date doesn\'t match your date of birth.'**
  String get campoRfcFecha;

  /// No description provided for @campoCorreoInvalido.
  ///
  /// In en, this message translates to:
  /// **'Invalid email.'**
  String get campoCorreoInvalido;

  /// No description provided for @campoTelefonoInvalido.
  ///
  /// In en, this message translates to:
  /// **'Must have 10 digits.'**
  String get campoTelefonoInvalido;

  /// No description provided for @campoCpInvalido.
  ///
  /// In en, this message translates to:
  /// **'Must have 5 digits.'**
  String get campoCpInvalido;

  /// No description provided for @campoIngresoInvalido.
  ///
  /// In en, this message translates to:
  /// **'Must be greater than zero (2 decimals max).'**
  String get campoIngresoInvalido;

  /// No description provided for @campoContraseniaDebil.
  ///
  /// In en, this message translates to:
  /// **'The password doesn\'t meet the requirements.'**
  String get campoContraseniaDebil;

  /// No description provided for @campoContraseniasDistintas.
  ///
  /// In en, this message translates to:
  /// **'Passwords don\'t match.'**
  String get campoContraseniasDistintas;

  /// No description provided for @campoPinInvalido.
  ///
  /// In en, this message translates to:
  /// **'The PIN must have 4 digits.'**
  String get campoPinInvalido;

  /// No description provided for @campoPinesDistintos.
  ///
  /// In en, this message translates to:
  /// **'PINs don\'t match.'**
  String get campoPinesDistintos;

  /// No description provided for @notificacionesTitulo.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificacionesTitulo;

  /// No description provided for @notificacionesVacias.
  ///
  /// In en, this message translates to:
  /// **'You have no notifications'**
  String get notificacionesVacias;

  /// No description provided for @notificacionesMarcarTodas.
  ///
  /// In en, this message translates to:
  /// **'Mark all'**
  String get notificacionesMarcarTodas;

  /// No description provided for @notificacionesMarcarLeida.
  ///
  /// In en, this message translates to:
  /// **'Mark read'**
  String get notificacionesMarcarLeida;

  /// No description provided for @notificacionesTodas.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get notificacionesTodas;

  /// No description provided for @notificacionesNoLeidas.
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get notificacionesNoLeidas;

  /// No description provided for @notificacionesMotivoRechazo.
  ///
  /// In en, this message translates to:
  /// **'Reason for rejection'**
  String get notificacionesMotivoRechazo;

  /// No description provided for @notificacionesEstadoSaldo.
  ///
  /// In en, this message translates to:
  /// **'Balance status'**
  String get notificacionesEstadoSaldo;

  /// No description provided for @historialResumenCompras.
  ///
  /// In en, this message translates to:
  /// **'Purchases'**
  String get historialResumenCompras;

  /// No description provided for @historialResumenTotal.
  ///
  /// In en, this message translates to:
  /// **'Total paid'**
  String get historialResumenTotal;

  /// No description provided for @historialSoloExitosas.
  ///
  /// In en, this message translates to:
  /// **'Purchases confirmed as successful by Gesto Pago.'**
  String get historialSoloExitosas;

  /// No description provided for @pagoSaldoInsuficiente.
  ///
  /// In en, this message translates to:
  /// **'Your available balance ({saldo}) does not cover this {monto} payment.'**
  String pagoSaldoInsuficiente(String saldo, String monto);

  /// No description provided for @pagoSaldoDespues.
  ///
  /// In en, this message translates to:
  /// **'Balance after payment'**
  String get pagoSaldoDespues;

  /// No description provided for @pagoSinCancelacion.
  ///
  /// In en, this message translates to:
  /// **'Once authorized with your PIN, the payment cannot be cancelled.'**
  String get pagoSinCancelacion;

  /// No description provided for @pagoMontoAyuda.
  ///
  /// In en, this message translates to:
  /// **'Up to 2 decimals.'**
  String get pagoMontoAyuda;

  /// No description provided for @inicioRepetirCompra.
  ///
  /// In en, this message translates to:
  /// **'Buy again'**
  String get inicioRepetirCompra;

  /// No description provided for @inicioRepetirSemantica.
  ///
  /// In en, this message translates to:
  /// **'Repeat {producto} for {referencia} for {monto}'**
  String inicioRepetirSemantica(
    String producto,
    String referencia,
    String monto,
  );

  /// No description provided for @comprobanteCompartir.
  ///
  /// In en, this message translates to:
  /// **'Share receipt'**
  String get comprobanteCompartir;

  /// No description provided for @comprobanteCompartirImagen.
  ///
  /// In en, this message translates to:
  /// **'As image'**
  String get comprobanteCompartirImagen;

  /// No description provided for @comprobanteCompartirImagenDetalle.
  ///
  /// In en, this message translates to:
  /// **'Great for WhatsApp or social apps'**
  String get comprobanteCompartirImagenDetalle;

  /// No description provided for @comprobanteCompartirPdf.
  ///
  /// In en, this message translates to:
  /// **'As PDF'**
  String get comprobanteCompartirPdf;

  /// No description provided for @comprobanteCompartirPdfDetalle.
  ///
  /// In en, this message translates to:
  /// **'Formal document to print or email'**
  String get comprobanteCompartirPdfDetalle;

  /// No description provided for @comprobanteCompartirError.
  ///
  /// In en, this message translates to:
  /// **'The receipt could not be generated. Please try again.'**
  String get comprobanteCompartirError;

  /// No description provided for @comprobanteDocumento.
  ///
  /// In en, this message translates to:
  /// **'Purchase receipt'**
  String get comprobanteDocumento;

  /// No description provided for @comprobanteGenerado.
  ///
  /// In en, this message translates to:
  /// **'Receipt generated by Gesto Pago'**
  String get comprobanteGenerado;

  /// No description provided for @comprobanteFolio.
  ///
  /// In en, this message translates to:
  /// **'Folio'**
  String get comprobanteFolio;

  /// No description provided for @comprobanteServicio.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get comprobanteServicio;

  /// No description provided for @comprobanteProducto.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get comprobanteProducto;

  /// No description provided for @comprobanteComision.
  ///
  /// In en, this message translates to:
  /// **'Fee'**
  String get comprobanteComision;

  /// No description provided for @comprobanteTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get comprobanteTotal;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
