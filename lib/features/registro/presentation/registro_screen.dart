import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format/gp_money.dart';
import '../../../core/format/message_de_error.dart';
import '../../../core/network/app_exception.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/gp_theme.dart';
import '../../../core/widgets/fondo_auth.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/solicitud_registro.dart';
import '../domain/validaciones_onboarding.dart';

/// Alta de cliente persona física (onboarding): datos personales, contacto,
/// domicilio, información laboral, acceso y confirmación. Al terminar el
/// servidor crea la cuenta ACTIVA y el usuario de acceso.
class RegistroScreen extends ConsumerStatefulWidget {
  const RegistroScreen({super.key});

  @override
  ConsumerState<RegistroScreen> createState() => _RegistroScreenState();
}

enum _Paso { personal, contacto, domicilio, laboral, acceso, revision }

class _RegistroScreenState extends ConsumerState<RegistroScreen> {
  final _solicitud = SolicitudRegistro();
  final _formularios = {for (final p in _Paso.values) p: GlobalKey<FormState>()};
  final _scroll = ScrollController();
  var _paso = _Paso.personal;
  bool _aceptaTerminos = false;
  bool _enviando = false;
  String? _error;
  RegistroCompletado? _completado;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _irA(_Paso paso) {
    setState(() {
      _paso = paso;
      _error = null;
    });
    if (_scroll.hasClients) {
      _scroll.jumpTo(0);
    }
  }

  void _siguiente() {
    FocusScope.of(context).unfocus();
    if (_paso == _Paso.acceso && !_aceptaTerminos) {
      setState(() => _error = AppLocalizations.of(context).registroTerminosRequerido);
      return;
    }
    if (_formularios[_paso]!.currentState?.validate() ?? true) {
      _formularios[_paso]!.currentState?.save();
      _irA(_Paso.values[_paso.index + 1]);
    }
  }

  Future<void> _enviar() async {
    setState(() {
      _enviando = true;
      _error = null;
    });
    try {
      final r = await ref.read(registroRemoteProvider).registrar(_solicitud);
      if (mounted) {
        setState(() => _completado = r);
      }
    } on AppException catch (e) {
      if (!mounted) {
        return;
      }
      final destino = switch (e.code) {
        'curp_duplicada' ||
        'rfc_duplicado' ||
        'curp_invalida' ||
        'rfc_invalido' ||
        'cliente_menor_de_edad' => _Paso.personal,
        'correo_duplicado' || 'correo_duplicado_usuario' => _Paso.contacto,
        'contrasena_invalida' => _Paso.acceso,
        _ => null,
      };
      if (destino != null) {
        _irA(destino);
      }
      setState(() => _error = messageDeError(context, e));
    } finally {
      if (mounted) {
        setState(() => _enviando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final completado = _completado;
    if (completado != null) {
      return _Exito(datos: completado);
    }
    final titulos = {
      _Paso.personal: l.registroStepPersonal,
      _Paso.contacto: l.registroStepContact,
      _Paso.domicilio: l.registroStepAddress,
      _Paso.laboral: l.registroStepWork,
      _Paso.acceso: l.registroStepAccess,
      _Paso.revision: l.registroStepReview,
    };
    final total = _Paso.values.length;
    return PopScope(
      canPop: _paso == _Paso.personal && !_enviando,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !_enviando) {
          _irA(_Paso.values[_paso.index - 1]);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.registroTitle),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4),
            child: LinearProgressIndicator(value: (_paso.index + 1) / total),
          ),
        ),
        body: SafeArea(
          child: ListView(
            controller: _scroll,
            padding: const EdgeInsets.all(GpSpacing.xl),
            children: [
              Text(
                l.registroStepOf('${_paso.index + 1}', '$total'),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(height: 4),
              Text(titulos[_paso]!, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 20),
              if (_error != null) ...[AvisoBanner(mensaje: _error!), const SizedBox(height: 16)],
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: KeyedSubtree(key: ValueKey(_paso), child: _contenido(l)),
              ),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(GpSpacing.xl, 8, GpSpacing.xl, 16),
            child: Row(
              children: [
                if (_paso != _Paso.personal) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _enviando ? null : () => _irA(_Paso.values[_paso.index - 1]),
                      child: Text(l.registroAnterior),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: _enviando ? null : (_paso == _Paso.revision ? _enviar : _siguiente),
                    child: _enviando
                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4))
                        : Text(_paso == _Paso.revision ? l.registroEnviar : l.registroContinuar),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _contenido(AppLocalizations l) {
    final s = _solicitud;
    final form = _formularios[_paso]!;
    switch (_paso) {
      case _Paso.personal:
        return Form(
          key: form,
          child: Column(
            children: [
              _Campo(
                l.registroNombre,
                s.nombre,
                (v) => s.nombre = v,
                (v) => ValidacionesOnboarding.nombre(v),
                capitalizar: true,
                autofill: AutofillHints.givenName,
              ),
              _Campo(
                l.registroOptional(l.registroSegundoNombre),
                s.segundoNombre,
                (v) => s.segundoNombre = v,
                (v) => ValidacionesOnboarding.nombre(v, opcional: true),
                capitalizar: true,
                autofill: AutofillHints.middleName,
              ),
              _Campo(
                l.registroApellidoPaterno,
                s.apellidoPaterno,
                (v) => s.apellidoPaterno = v,
                (v) => ValidacionesOnboarding.nombre(v),
                capitalizar: true,
                autofill: AutofillHints.familyName,
              ),
              _Campo(
                l.registroApellidoMaterno,
                s.apellidoMaterno,
                (v) => s.apellidoMaterno = v,
                (v) => ValidacionesOnboarding.nombre(v),
                capitalizar: true,
              ),
              _CampoFecha(
                etiqueta: l.registroFechaNacimiento,
                valor: s.fechaNacimiento,
                onCambio: (f) => setState(() => s.fechaNacimiento = f),
              ),
              _Selector(l.registroSexo, s.sexo, {
                'HOMBRE': l.registroSexoHombre,
                'MUJER': l.registroSexoMujer,
                'OTRO': l.registroSexoOtro,
              }, (v) => s.sexo = v),
              _Campo(
                l.registroCurp,
                s.curp,
                (v) => s.curp = v.toUpperCase(),
                (v) => ValidacionesOnboarding.curp(v, s.fechaNacimiento),
                mayusculas: true,
                maxLength: 18,
                formatos: [FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]'))],
              ),
              _Campo(
                l.registroRfc,
                s.rfc,
                (v) => s.rfc = v.toUpperCase(),
                (v) => ValidacionesOnboarding.rfc(v, s.fechaNacimiento),
                mayusculas: true,
                maxLength: 13,
                formatos: [FilteringTextInputFormatter.allow(RegExp(r'[A-Za-zÑñ&0-9]'))],
              ),
              _Campo(
                l.registroNacionalidad,
                s.nacionalidad,
                (v) => s.nacionalidad = v,
                (v) => ValidacionesOnboarding.texto(v, 2, 50),
                capitalizar: true,
              ),
              _Selector(l.registroEstadoCivil, s.estadoCivil, {
                'SOLTERO': l.registroEcSoltero,
                'CASADO': l.registroEcCasado,
                'DIVORCIADO': l.registroEcDivorciado,
                'VIUDO': l.registroEcViudo,
                'UNION_LIBRE': l.registroEcUnionLibre,
                'SEPARADO': l.registroEcSeparado,
                'OTRO': l.registroEcOtro,
              }, (v) => s.estadoCivil = v),
            ],
          ),
        );
      case _Paso.contacto:
        return Form(
          key: form,
          child: Column(
            children: [
              _Campo(
                l.registroCorreo,
                s.correo,
                (v) => s.correo = v.trim(),
                ValidacionesOnboarding.correo,
                teclado: TextInputType.emailAddress,
                autofill: AutofillHints.email,
                ayuda: l.registroCorreoAyuda,
                maxLength: 100,
              ),
              _Campo(
                l.registroTelefono,
                s.telefonoMovil,
                (v) => s.telefonoMovil = v,
                (v) => ValidacionesOnboarding.telefono(v),
                teclado: TextInputType.phone,
                autofill: AutofillHints.telephoneNumberNational,
                maxLength: 10,
                formatos: [FilteringTextInputFormatter.digitsOnly],
              ),
              _Campo(
                l.registroOptional(l.registroTelefonoAlterno),
                s.telefonoAlterno,
                (v) => s.telefonoAlterno = v,
                (v) => ValidacionesOnboarding.telefono(v, opcional: true),
                teclado: TextInputType.phone,
                maxLength: 10,
                formatos: [FilteringTextInputFormatter.digitsOnly],
              ),
            ],
          ),
        );
      case _Paso.domicilio:
        return Form(
          key: form,
          child: Column(
            children: [
              _Campo(
                l.registroCalle,
                s.calle,
                (v) => s.calle = v,
                (v) => ValidacionesOnboarding.texto(v, 3, 100),
                autofill: AutofillHints.streetAddressLine1,
                capitalizar: true,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _Campo(
                      l.registroNumExt,
                      s.numeroExterior,
                      (v) => s.numeroExterior = v,
                      (v) => ValidacionesOnboarding.texto(v, 1, 10),
                      maxLength: 10,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _Campo(
                      l.registroOptional(l.registroNumInt),
                      s.numeroInterior,
                      (v) => s.numeroInterior = v,
                      (v) => ValidacionesOnboarding.texto(v, 1, 10, opcional: true),
                      maxLength: 10,
                    ),
                  ),
                ],
              ),
              _Campo(
                l.registroColonia,
                s.colonia,
                (v) => s.colonia = v,
                (v) => ValidacionesOnboarding.texto(v, 2, 100),
                capitalizar: true,
              ),
              _Campo(
                l.registroCp,
                s.codigoPostal,
                (v) => s.codigoPostal = v,
                ValidacionesOnboarding.codigoPostal,
                teclado: TextInputType.number,
                autofill: AutofillHints.postalCode,
                maxLength: 5,
                formatos: [FilteringTextInputFormatter.digitsOnly],
              ),
              _Campo(
                l.registroMunicipio,
                s.municipio,
                (v) => s.municipio = v,
                (v) => ValidacionesOnboarding.texto(v, 2, 100),
                capitalizar: true,
              ),
              _Campo(
                l.registroEstado,
                s.estado,
                (v) => s.estado = v,
                (v) => ValidacionesOnboarding.texto(v, 2, 50),
                capitalizar: true,
              ),
              _Campo(
                l.registroPais,
                s.pais,
                (v) => s.pais = v,
                (v) => ValidacionesOnboarding.texto(v, 2, 50),
                capitalizar: true,
              ),
            ],
          ),
        );
      case _Paso.laboral:
        return Form(
          key: form,
          child: Column(
            children: [
              _Campo(
                l.registroOcupacion,
                s.ocupacion,
                (v) => s.ocupacion = v,
                (v) => ValidacionesOnboarding.texto(v, 2, 100),
                capitalizar: true,
              ),
              _Campo(
                l.registroOptional(l.registroEmpresa),
                s.empresa,
                (v) => s.empresa = v,
                (v) => ValidacionesOnboarding.texto(v, 1, 100, opcional: true),
                capitalizar: true,
              ),
              _Campo(
                l.registroIngreso,
                s.ingresoMensual,
                (v) => s.ingresoMensual = v,
                ValidacionesOnboarding.ingreso,
                teclado: const TextInputType.numberWithOptions(decimal: true),
                formatos: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
              ),
            ],
          ),
        );
      case _Paso.acceso:
        return Form(
          key: form,
          child: _PasoAcceso(
            solicitud: s,
            aceptaTerminos: _aceptaTerminos,
            onTerminos: (v) => setState(() {
              _aceptaTerminos = v;
              _error = null;
            }),
          ),
        );
      case _Paso.revision:
        return _Revision(solicitud: s, onEditar: (i) => _irA(_Paso.values[i]));
    }
  }
}

extension on ErrorCampo {
  String mensaje(AppLocalizations l) => switch (this) {
    ErrorCampo.obligatorio => l.campoObligatorio,
    ErrorCampo.nombreInvalido => l.campoNombreInvalido,
    ErrorCampo.longitud => l.campoLongitud,
    ErrorCampo.fechaFutura => l.campoFechaFutura,
    ErrorCampo.menorDeEdad => l.campoMenorDeEdad,
    ErrorCampo.curpInvalida => l.campoCurpInvalida,
    ErrorCampo.rfcInvalido => l.campoRfcInvalido,
    ErrorCampo.curpNoCoincideFecha => l.campoCurpFecha,
    ErrorCampo.rfcNoCoincideFecha => l.campoRfcFecha,
    ErrorCampo.correoInvalido => l.campoCorreoInvalido,
    ErrorCampo.telefonoInvalido => l.campoTelefonoInvalido,
    ErrorCampo.codigoPostalInvalido => l.campoCpInvalido,
    ErrorCampo.ingresoInvalido => l.campoIngresoInvalido,
    ErrorCampo.contraseniaDebil => l.campoContraseniaDebil,
    ErrorCampo.contraseniasDistintas => l.campoContraseniasDistintas,
    ErrorCampo.pinInvalido => l.campoPinInvalido,
    ErrorCampo.pinesDistintos => l.campoPinesDistintos,
  };
}

class _Campo extends StatelessWidget {
  const _Campo(
    this.etiqueta,
    this.valor,
    this.onGuardar,
    this.validar, {
    this.teclado,
    this.autofill,
    this.ayuda,
    this.maxLength,
    this.formatos,
    this.capitalizar = false,
    this.mayusculas = false,
  });

  final String etiqueta;
  final String valor;
  final ValueChanged<String> onGuardar;
  final ErrorCampo? Function(String?) validar;
  final TextInputType? teclado;
  final String? autofill;
  final String? ayuda;
  final int? maxLength;
  final List<TextInputFormatter>? formatos;
  final bool capitalizar;
  final bool mayusculas;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        initialValue: valor,
        keyboardType: teclado,
        autofillHints: autofill == null ? null : [autofill!],
        maxLength: maxLength,
        inputFormatters: formatos,
        textInputAction: TextInputAction.next,
        textCapitalization: mayusculas
            ? TextCapitalization.characters
            : capitalizar
            ? TextCapitalization.words
            : TextCapitalization.none,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: InputDecoration(labelText: etiqueta, helperText: ayuda, counterText: ''),
        validator: (v) => validar(v)?.mensaje(l),
        onChanged: onGuardar,
        onSaved: (v) => onGuardar(v ?? ''),
      ),
    );
  }
}

class _Selector extends StatelessWidget {
  const _Selector(this.etiqueta, this.valor, this.opciones, this.onCambio);

  final String etiqueta;
  final String valor;
  final Map<String, String> opciones;
  final ValueChanged<String> onCambio;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        initialValue: valor.isEmpty ? null : valor,
        decoration: InputDecoration(labelText: etiqueta),
        items: [for (final e in opciones.entries) DropdownMenuItem(value: e.key, child: Text(e.value))],
        validator: (v) => v == null || v.isEmpty ? l.campoObligatorio : null,
        onChanged: (v) => onCambio(v ?? ''),
      ),
    );
  }
}

class _CampoFecha extends FormField<DateTime> {
  _CampoFecha({required String etiqueta, required DateTime? valor, required ValueChanged<DateTime> onCambio})
    : super(
        initialValue: valor,
        validator: (f) {
          final error = ValidacionesOnboarding.fechaNacimiento(f, DateTime.now());
          return error?.name;
        },
        builder: (estado) {
          final context = estado.context;
          final l = AppLocalizations.of(context);
          final hoy = DateTime.now();
          final limite = DateTime(hoy.year - 18, hoy.month, hoy.day);
          final f = estado.value;
          final texto = f == null
              ? ''
              : '${f.day.toString().padLeft(2, '0')}/${f.month.toString().padLeft(2, '0')}/${f.year}';
          final error = ErrorCampo.values.where((e) => e.name == estado.errorText).firstOrNull;
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: InkWell(
              borderRadius: BorderRadius.circular(GpRadii.campo),
              onTap: () async {
                final elegida = await showDatePicker(
                  context: context,
                  initialDate: f ?? DateTime(limite.year - 7, limite.month, limite.day),
                  firstDate: DateTime(1900),
                  lastDate: limite,
                  helpText: l.registroFechaNacimiento,
                );
                if (elegida != null) {
                  estado.didChange(elegida);
                  onCambio(elegida);
                }
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: etiqueta,
                  errorText: error?.mensaje(l),
                  suffixIcon: const Icon(Icons.calendar_today_outlined),
                ),
                isEmpty: f == null,
                child: Text(texto),
              ),
            ),
          );
        },
      );
}

class _PasoAcceso extends StatefulWidget {
  const _PasoAcceso({required this.solicitud, required this.aceptaTerminos, required this.onTerminos});

  final SolicitudRegistro solicitud;
  final bool aceptaTerminos;
  final ValueChanged<bool> onTerminos;

  @override
  State<_PasoAcceso> createState() => _PasoAccesoState();
}

class _PasoAccesoState extends State<_PasoAcceso> {
  bool _oculta = true;
  String _confirmacion = '';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final s = widget.solicitud;
    final tema = Theme.of(context);
    final reglas = {
      ReglaContrasenia.longitud: l.registroReglaLongitud,
      ReglaContrasenia.mayuscula: l.registroReglaMayuscula,
      ReglaContrasenia.minuscula: l.registroReglaMinuscula,
      ReglaContrasenia.numero: l.registroReglaNumero,
      ReglaContrasenia.especial: l.registroReglaEspecial,
    };
    final ojo = IconButton(
      icon: Icon(_oculta ? Icons.visibility_outlined : Icons.visibility_off_outlined),
      onPressed: () => setState(() => _oculta = !_oculta),
    );
    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            initialValue: s.contrasenia,
            obscureText: _oculta,
            autofillHints: const [AutofillHints.newPassword],
            decoration: InputDecoration(labelText: l.registroContrasenia, suffixIcon: ojo),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (v) => ValidacionesOnboarding.contrasenia(v)?.mensaje(l),
            onChanged: (v) => setState(() => s.contrasenia = v),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [for (final e in reglas.entries) _ReglaChip(texto: e.value, cumple: e.key.cumple(s.contrasenia))],
          ),
          const SizedBox(height: 14),
          TextFormField(
            initialValue: _confirmacion,
            obscureText: _oculta,
            autofillHints: const [AutofillHints.newPassword],
            decoration: InputDecoration(labelText: l.registroConfirmar),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (v) => ValidacionesOnboarding.confirmacion(v, s.contrasenia)?.mensaje(l),
            onChanged: (v) => _confirmacion = v,
          ),
          const SizedBox(height: 14),
          TextFormField(
            initialValue: s.pin,
            obscureText: true,
            keyboardType: TextInputType.number,
            maxLength: 4,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(labelText: l.registroPin, helperText: l.registroPinAyuda, counterText: ''),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (v) => ValidacionesOnboarding.pin(v)?.mensaje(l),
            onChanged: (v) => s.pin = v,
          ),
          const SizedBox(height: 14),
          _Selector(l.registroTipoCuenta, s.tipoCuenta, {
            'AHORRO': l.registroTcAhorro,
            'CORRIENTE': l.registroTcCorriente,
            'NOMINA': l.registroTcNomina,
            'INVERSION': l.registroTcInversion,
          }, (v) => s.tipoCuenta = v),
          AvisoBanner(mensaje: l.registroCuentaInfo, esError: false, icono: Icons.account_balance_outlined),
          const SizedBox(height: 8),
          CheckboxListTile(
            value: widget.aceptaTerminos,
            onChanged: (v) => widget.onTerminos(v ?? false),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            title: Text(l.registroTerminos, style: tema.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _ReglaChip extends StatelessWidget {
  const _ReglaChip({required this.texto, required this.cumple});

  final String texto;
  final bool cumple;

  @override
  Widget build(BuildContext context) {
    final color = cumple ? const Color(0xFF047857) : Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(cumple ? Icons.check_circle : Icons.radio_button_unchecked, size: 16, color: color),
        const SizedBox(width: 4),
        Text(texto, style: TextStyle(fontSize: 12, color: color)),
      ],
    );
  }
}

class _Revision extends StatelessWidget {
  const _Revision({required this.solicitud, required this.onEditar});

  final SolicitudRegistro solicitud;
  final ValueChanged<int> onEditar;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final s = solicitud;
    final f = s.fechaNacimiento;
    final secciones = <(String, int, List<(String, String)>)>[
      (
        l.registroStepPersonal,
        0,
        [
          (
            l.registroNombre,
            [
              s.nombre,
              s.segundoNombre,
              s.apellidoPaterno,
              s.apellidoMaterno,
            ].where((x) => x.trim().isNotEmpty).join(' '),
          ),
          (l.registroFechaNacimiento, f == null ? '' : '${f.day}/${f.month}/${f.year}'),
          (l.registroCurp, s.curp),
          (l.registroRfc, s.rfc),
        ],
      ),
      (l.registroStepContact, 1, [(l.registroCorreo, s.correo), (l.registroTelefono, s.telefonoMovil)]),
      (
        l.registroStepAddress,
        2,
        [
          (
            l.registroCalle,
            '${s.calle} ${s.numeroExterior}${s.numeroInterior.isEmpty ? '' : ' int. ${s.numeroInterior}'}',
          ),
          (l.registroColonia, '${s.colonia}, ${s.municipio}, ${s.estado} ${s.codigoPostal}'),
        ],
      ),
      (
        l.registroStepWork,
        3,
        [(l.registroOcupacion, s.ocupacion), (l.registroIngreso, GpMoney.format(s.ingresoMensual))],
      ),
      (l.registroStepAccess, 4, [(l.registroTipoCuenta, s.tipoCuenta), (l.registroPin, '••••')]),
    ];
    return Column(
      children: [
        for (final (titulo, paso, filas) in secciones)
          Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(titulo, style: Theme.of(context).textTheme.titleSmall)),
                      TextButton.icon(
                        onPressed: () => onEditar(paso),
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: Text(l.registroEditar),
                      ),
                    ],
                  ),
                  for (final (k, v) in filas)
                    Padding(
                      padding: const EdgeInsets.only(top: 4, right: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(width: 120, child: Text(k, style: Theme.of(context).textTheme.bodySmall)),
                          Expanded(child: Text(v)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _Exito extends StatelessWidget {
  const _Exito({required this.datos});

  final RegistroCompletado datos;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final tema = Theme.of(context);
    final numero = datos.numeroCuenta.replaceAllMapped(RegExp(r'(\d{4})(?=\d)'), (m) => '${m[1]} ');
    return Scaffold(
      body: FondoAuth(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: TarjetaAuth(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.verified_rounded, size: 56, color: Color(0xFF059669)),
                    const SizedBox(height: 12),
                    Text(
                      l.registroExitoTitulo(datos.nombre),
                      textAlign: TextAlign.center,
                      style: tema.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(l.registroExitoMensaje, textAlign: TextAlign.center),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(GpRadii.tarjeta),
                        gradient: const LinearGradient(colors: [Color(0xFF1D4ED8), Color(0xFF1E3A8A)]),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${l.registroNumeroCuenta} · ${datos.estatusCuenta}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            numero,
                            style: tema.textTheme.titleLarge?.copyWith(color: Colors.white, letterSpacing: 2),
                          ),
                          const SizedBox(height: 12),
                          Text(l.registroSaldoInicial, style: const TextStyle(color: Colors.white70)),
                          Text(
                            GpMoney.format(datos.saldo),
                            style: tema.textTheme.titleMedium?.copyWith(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.person_outline),
                      title: Text(l.registroUsuario),
                      subtitle: Text(datos.correo),
                    ),
                    AvisoBanner(mensaje: l.registroExitoSiguiente, esError: false, icono: Icons.shield_outlined),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => context.go('/login', extra: datos.correo),
                      child: Text(l.loginButton),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
