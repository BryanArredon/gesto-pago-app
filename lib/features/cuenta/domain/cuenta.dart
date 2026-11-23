import '../../../core/network/app_exception.dart';

/// Los value objects del backend (NumeroCuenta, Curp, Correo...) se serializan
/// como `{"valor": "..."}`; esta función acepta ambas formas.
String valorDe(Object? x) {
  if (x is Map) {
    return x['valor']?.toString() ?? '';
  }
  return x?.toString() ?? '';
}

/// Cuenta bancaria del cliente (onboarding-clientes). El saldo se conserva como
/// texto para no perder precisión decimal.
class Cuenta {
  const Cuenta({
    required this.id,
    required this.numero,
    required this.tipo,
    required this.moneda,
    required this.saldo,
    required this.estatus,
  });

  factory Cuenta.fromJson(Map<String, dynamic> json) {
    final numero = valorDe(json['numero']);
    if (numero.isEmpty) {
      throw const SerializationException('Cuenta sin número.');
    }
    return Cuenta(
      id: json['id']?.toString() ?? '',
      numero: numero,
      tipo: json['tipo']?.toString() ?? 'AHORRO',
      moneda: json['moneda']?.toString() ?? 'MXN',
      saldo: json['saldo']?.toString() ?? '0',
      estatus: json['estatus']?.toString() ?? '',
    );
  }

  final String id;
  final String numero;
  final String tipo;
  final String moneda;
  final String saldo;
  final String estatus;

  bool get activa => estatus == 'ACTIVA';

  /// `•••• 1234`: nunca se muestra el número completo fuera del detalle.
  String get enmascarada => numero.length >= 4 ? '•••• ${numero.substring(numero.length - 4)}' : numero;

  String get agrupada => numero.replaceAllMapped(RegExp(r'(\d{4})(?=\d)'), (m) => '${m[1]} ');
}

/// Datos del cliente que muestra el perfil (`POST /clientes/detalle`).
class ClienteDetalle {
  const ClienteDetalle({
    required this.id,
    required this.nombre,
    required this.nombreCompleto,
    required this.correo,
    required this.telefonoMovil,
    required this.curp,
    required this.rfc,
    required this.fechaNacimiento,
    required this.domicilio,
    required this.ocupacion,
    required this.activo,
    required this.tienePin,
    required this.ultimoAcceso,
  });

  factory ClienteDetalle.fromJson(Map<String, dynamic> json) {
    final dom = json['domicilio'] is Map ? json['domicilio'] as Map : const {};
    final usuario = json['usuario'] is Map ? json['usuario'] as Map : const {};
    final partes = [
      '${dom['calle'] ?? ''} ${dom['numeroExterior'] ?? ''}'.trim(),
      dom['colonia'],
      dom['municipio'],
      dom['estado'],
      valorDe(dom['codigoPostal']),
    ].whereType<String>().where((p) => p.trim().isNotEmpty);
    return ClienteDetalle(
      id: json['id']?.toString() ?? '',
      nombre: json['nombre']?.toString() ?? '',
      nombreCompleto: json['nombreCompleto']?.toString() ?? '',
      correo: valorDe(json['correo']),
      telefonoMovil: valorDe(json['telefonoMovil']),
      curp: valorDe(json['curp']),
      rfc: valorDe(json['rfc']),
      fechaNacimiento: json['fechaNacimiento']?.toString() ?? '',
      domicilio: partes.join(', '),
      ocupacion: json['ocupacion']?.toString() ?? '',
      activo: json['activo'] == true,
      tienePin: usuario['tienePin'] == true,
      ultimoAcceso: DateTime.tryParse(usuario['ultimoAcceso']?.toString() ?? '')?.toLocal(),
    );
  }

  final String id;
  final String nombre;
  final String nombreCompleto;
  final String correo;
  final String telefonoMovil;
  final String curp;
  final String rfc;
  final String fechaNacimiento;
  final String domicilio;
  final String ocupacion;
  final bool activo;
  final bool tienePin;
  final DateTime? ultimoAcceso;
}
