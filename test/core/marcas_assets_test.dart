import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gesto_pago_app/core/theme/gp_assets.dart';

void main() {
  testWidgets('todos los PNG de marcas se decodifican correctamente',
      (tester) async {
    await tester.runAsync(() async {
      for (final entry in GpAssets.marcas.entries) {
        final bytes = await rootBundle.load(entry.value);
        final codec = await ui.instantiateImageCodec(bytes.buffer.asUint8List());
        final frame = await codec.getNextFrame();
        expect(frame.image.width, greaterThan(0),
            reason: '${entry.key} no decodificó (${entry.value})');
      }
    });
  });
}