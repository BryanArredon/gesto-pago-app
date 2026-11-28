/// Datos del alta de cliente persona física (`POST /clientes`).
class SolicitudRegistro {
  SolicitudRegistro();

  // Datos personales
  String nombre = '';
  String segundoNombre = '';
  String apellidoPaterno = '';
  String apellidoMaterno = '';
  DateTime? fechaNacimiento;
  String sexo = '';
  String curp = '';
  String rfc = '';
  String nacionalidad = 'Mexicana';
  String estadoCivil = '';
  // Contacto
  String correo = '';
  String telefonoMovil = '';
  String telefonoAlterno = '';
  // Domicilio
  String calle = '';
  String numeroExterior = '';
  String numeroInterior = '';
  String colonia = '';
  String municipio = '';
  String estado = '';
  String codigoPostal = '';
  String pais = 'México';
  // Laboral
  String ocupacion = '';
  String empresa = '';
  String ingresoMensual = '';
  // Acceso y cuenta
  String contrasenia = '';
  String pin = '';
  String tipoCuenta = 'AHORRO';

  static String? _opcional(String v) => v.trim().isEmpty ? null : v.trim();

  static String _fecha(DateTime f) =>
      '${f.year.toString().padLeft(4, '0')}-${f.month.toString().padLeft(2, '0')}-${f.day.toString().padLeft(2, '0')}';

  /// El saldo inicial lo define el sistema: no se envía.
  Map<String, dynamic> toJson() => {
    'persona': {
      'nombre': nombre.trim(),
      'segundoNombre': _opcional(segundoNombre),
      'apellidoPaterno': apellidoPaterno.trim(),
      'apellidoMaterno': apellidoMaterno.trim(),
      'fechaNacimiento': fechaNacimiento == null ? null : _fecha(fechaNacimiento!),
      'curp': curp.trim().toUpperCase(),
      'rfc': rfc.trim().toUpperCase(),
      'sexo': sexo,
      'nacionalidad': nacionalidad.trim(),
      'estadoCivil': estadoCivil,
    },
    'contacto': {
      'correo': correo.trim().toLowerCase(),
      'telefonoMovil': telefonoMovil.trim(),
      'telefonoAlterno': _opcional(telefonoAlterno),
    },
    'ubicacion': {
      'calle': calle.trim(),
      'numeroExterior': numeroExterior.trim(),
      'numeroInterior': _opcional(numeroInterior),
      'colonia': colonia.trim(),
      'municipio': municipio.trim(),
      'estado': estado.trim(),
      'codigoPostal': codigoPostal.trim(),
      'pais': pais.trim(),
    },
    'laboral': {
      'ocupacion': ocupacion.trim(),
      'empresa': _opcional(empresa),
      'ingresoMensual': ingresoMensual.trim(),
      'monedaIngreso': 'MXN',
    },
    'credenciales': {'contrasenia': contrasenia, 'pin': pin},
    'cuenta': {'tipoCuenta': tipoCuenta, 'monedaCuenta': 'MXN'},
  };

  @override
  String toString() => 'SolicitudRegistro(correo: $correo, contrasenia: ***, pin: ****)';
}

/// Resultado del alta: cuenta creada y usuario de acceso.
class RegistroCompletado {
  const RegistroCompletado({
    required this.nombre,
    required this.nombreCompleto,
    required this.correo,
    required this.numeroCuenta,
    required this.tipoCuenta,
    required this.estatusCuenta,
    required this.saldo,
  });

  final String nombre;
  final String nombreCompleto;
  final String correo;
  final String numeroCuenta;
  final String tipoCuenta;
  final String estatusCuenta;
  final String saldo;
}
