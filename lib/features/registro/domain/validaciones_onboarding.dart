/// Validaciones del alta de cliente, espejo de las del backend
/// (RegistrarClienteRequest y value objects). El servidor sigue siendo la
/// fuente de verdad; aquí solo se adelanta el error al usuario.
///
/// Cada validador devuelve un [ErrorCampo] (o null) en lugar de un texto, para
/// que la presentación lo traduzca y estas reglas se puedan probar sin Flutter.
library;

enum ErrorCampo {
  obligatorio,
  nombreInvalido,
  longitud,
  fechaFutura,
  menorDeEdad,
  curpInvalida,
  rfcInvalido,
  curpNoCoincideFecha,
  rfcNoCoincideFecha,
  correoInvalido,
  telefonoInvalido,
  codigoPostalInvalido,
  ingresoInvalido,
  contraseniaDebil,
  contraseniasDistintas,
  pinInvalido,
  pinesDistintos,
}

final _nombre = RegExp(r'^[A-Za-zÁÉÍÓÚÜÑáéíóúüñ\s]+$');
final _curp = RegExp(r'^[A-Z]{4}[0-9]{6}[A-Z]{6}[0-9A-Z]{2}$');
final _rfc = RegExp(r'^[A-ZÑ&]{4}[0-9]{6}[0-9A-Z]{3}$');
final _correo = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');
final _telefono = RegExp(r'^[0-9]{10}$');
final _cp = RegExp(r'^[0-9]{5}$');
final _pin = RegExp(r'^[0-9]{4}$');
final _importe = RegExp(r'^\d+(\.\d{1,2})?$');

class ValidacionesOnboarding {
  const ValidacionesOnboarding._();

  static ErrorCampo? nombre(String? v, {bool opcional = false}) {
    final t = (v ?? '').trim();
    if (t.isEmpty) {
      return opcional ? null : ErrorCampo.obligatorio;
    }
    if (t.length < 2 || t.length > 50 || !_nombre.hasMatch(t)) {
      return ErrorCampo.nombreInvalido;
    }
    return null;
  }

  static ErrorCampo? texto(String? v, int min, int max, {bool opcional = false}) {
    final t = (v ?? '').trim();
    if (t.isEmpty) {
      return opcional ? null : ErrorCampo.obligatorio;
    }
    return t.length < min || t.length > max ? ErrorCampo.longitud : null;
  }

  static int edad(DateTime nacimiento, DateTime hoy) {
    var anios = hoy.year - nacimiento.year;
    if (hoy.month < nacimiento.month || (hoy.month == nacimiento.month && hoy.day < nacimiento.day)) {
      anios--;
    }
    return anios;
  }

  static ErrorCampo? fechaNacimiento(DateTime? fecha, DateTime hoy) {
    if (fecha == null) {
      return ErrorCampo.obligatorio;
    }
    if (fecha.isAfter(hoy)) {
      return ErrorCampo.fechaFutura;
    }
    return edad(fecha, hoy) < 18 ? ErrorCampo.menorDeEdad : null;
  }

  /// CURP de 18 caracteres; la fecha AAMMDD embebida debe coincidir con la de
  /// nacimiento (regla del dominio Curp.exigeCoincidirCon).
  static ErrorCampo? curp(String? v, DateTime? nacimiento) {
    final t = (v ?? '').trim().toUpperCase();
    if (t.isEmpty) {
      return ErrorCampo.obligatorio;
    }
    if (!_curp.hasMatch(t)) {
      return ErrorCampo.curpInvalida;
    }
    if (nacimiento != null && t.substring(4, 10) != _aammdd(nacimiento)) {
      return ErrorCampo.curpNoCoincideFecha;
    }
    return null;
  }

  /// RFC de persona física (13 caracteres con homoclave); misma regla de fecha.
  static ErrorCampo? rfc(String? v, DateTime? nacimiento) {
    final t = (v ?? '').trim().toUpperCase();
    if (t.isEmpty) {
      return ErrorCampo.obligatorio;
    }
    if (!_rfc.hasMatch(t)) {
      return ErrorCampo.rfcInvalido;
    }
    if (nacimiento != null && t.substring(4, 10) != _aammdd(nacimiento)) {
      return ErrorCampo.rfcNoCoincideFecha;
    }
    return null;
  }

  static ErrorCampo? correo(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty) {
      return ErrorCampo.obligatorio;
    }
    return t.length > 100 || !_correo.hasMatch(t) ? ErrorCampo.correoInvalido : null;
  }

  static ErrorCampo? telefono(String? v, {bool opcional = false}) {
    final t = (v ?? '').trim();
    if (t.isEmpty) {
      return opcional ? null : ErrorCampo.obligatorio;
    }
    return _telefono.hasMatch(t) ? null : ErrorCampo.telefonoInvalido;
  }

  static ErrorCampo? codigoPostal(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty) {
      return ErrorCampo.obligatorio;
    }
    return _cp.hasMatch(t) ? null : ErrorCampo.codigoPostalInvalido;
  }

  static ErrorCampo? ingreso(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty) {
      return ErrorCampo.obligatorio;
    }
    final n = double.tryParse(t);
    return n == null || n <= 0 || !_importe.hasMatch(t) ? ErrorCampo.ingresoInvalido : null;
  }

  /// Política de contraseñas: 8+ caracteres, mayúscula, minúscula, número y especial.
  static List<ReglaContrasenia> reglasIncumplidas(String p) =>
      ReglaContrasenia.values.where((r) => !r.cumple(p)).toList();

  static ErrorCampo? contrasenia(String? v) {
    final p = v ?? '';
    if (p.isEmpty) {
      return ErrorCampo.obligatorio;
    }
    return reglasIncumplidas(p).isEmpty ? null : ErrorCampo.contraseniaDebil;
  }

  static ErrorCampo? confirmacion(String? confirmacion, String original) =>
      confirmacion == original ? null : ErrorCampo.contraseniasDistintas;

  static ErrorCampo? pin(String? v) => _pin.hasMatch(v ?? '') ? null : ErrorCampo.pinInvalido;

  static String _aammdd(DateTime f) =>
      '${(f.year % 100).toString().padLeft(2, '0')}${f.month.toString().padLeft(2, '0')}${f.day.toString().padLeft(2, '0')}';
}

enum ReglaContrasenia {
  longitud,
  mayuscula,
  minuscula,
  numero,
  especial;

  bool cumple(String p) => switch (this) {
    ReglaContrasenia.longitud => p.length >= 8,
    ReglaContrasenia.mayuscula => RegExp(r'[A-ZÁÉÍÓÚÑ]').hasMatch(p),
    ReglaContrasenia.minuscula => RegExp(r'[a-záéíóúñ]').hasMatch(p),
    ReglaContrasenia.numero => RegExp(r'[0-9]').hasMatch(p),
    ReglaContrasenia.especial => RegExp(r'[^A-Za-z0-9ÁÉÍÓÚÑáéíóúñ\s]').hasMatch(p),
  };
}
