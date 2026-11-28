// Certificate pinning solo existe en plataformas con dart:io (Android/iOS/
// escritorio). En web lo resuelve el navegador y se usa el stub.
export 'pinning_stub.dart' if (dart.library.io) 'pinning_io.dart';
