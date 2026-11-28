import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../../../core/format/gp_fecha.dart';
import '../../../core/format/gp_money.dart';
import '../../../core/theme/gp_assets.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/transaccion.dart';

/// Genera el comprobante de una compra como imagen o PDF y abre la hoja de
/// compartir del sistema (WhatsApp, correo, Drive…).
abstract final class CompartirComprobante {
  /// Captura el ticket ya dibujado en pantalla (envuelto en un [RepaintBoundary]).
  static Future<Uint8List> imagen(GlobalKey clave, {double densidad = 3}) async {
    final frontera = clave.currentContext?.findRenderObject();
    if (frontera is! RenderRepaintBoundary) {
      throw StateError('El comprobante no está en pantalla');
    }
    final imagen = await frontera.toImage(pixelRatio: densidad);
    try {
      final datos = await imagen.toByteData(format: ui.ImageByteFormat.png);
      if (datos == null) {
        throw StateError('No se pudo codificar la imagen');
      }
      return datos.buffer.asUint8List();
    } finally {
      imagen.dispose();
    }
  }

  /// PDF de texto real (seleccionable y nítido a cualquier zoom), como el de un banco.
  static Future<Uint8List> pdf(Transaccion tx, AppLocalizations l) async {
    pw.MemoryImage? logo;
    try {
      logo = pw.MemoryImage((await rootBundle.load(GpAssets.logo)).buffer.asUint8List());
    } catch (_) {
      logo = null; // sin logo el documento sigue siendo válido
    }
    const azul = PdfColor.fromInt(0xFF1A56DB);
    const gris = PdfColor.fromInt(0xFF64748B);
    final comision = double.tryParse(tx.comision) ?? 0;
    final total = (double.tryParse(tx.monto) ?? 0) + comision;

    final filas = <(String, String)>[
      (l.comprobanteServicio, tx.servicio),
      (l.comprobanteProducto, tx.producto),
      (l.pagoConfirmReference, tx.referencia),
      (l.comprobanteFecha, formatFecha(tx.fecha)),
      (l.pagoConfirmAmount, GpMoney.format(tx.monto)),
      if (comision > 0) (l.comprobanteComision, GpMoney.format(tx.comision)),
      if (tx.numeroAutorizacion.isNotEmpty) (l.pagoAuthorization, tx.numeroAutorizacion),
      if (tx.upc.isNotEmpty) (l.comprobanteFolio, tx.upc),
      if (tx.idTx.isNotEmpty) (l.pagoTransactionId, tx.idTx),
      if (tx.pin.isNotEmpty) ('PIN', tx.pin),
    ];

    final doc = pw.Document(title: l.comprobanteDocumento, author: 'Gesto Pago', creator: 'Gesto Pago');
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5,
        margin: const pw.EdgeInsets.all(32),
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            pw.Row(
              children: [
                if (logo != null) pw.Image(logo, width: 34, height: 34),
                pw.SizedBox(width: 10),
                pw.Text('Gesto Pago', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: azul)),
                pw.Spacer(),
                pw.Text(_latin1(l.comprobanteDocumento), style: const pw.TextStyle(fontSize: 10, color: gris)),
              ],
            ),
            pw.SizedBox(height: 24),
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(vertical: 18),
              decoration: const pw.BoxDecoration(
                color: PdfColor.fromInt(0xFFEFF6FF),
                borderRadius: pw.BorderRadius.all(pw.Radius.circular(10)),
              ),
              child: pw.Column(
                children: [
                  pw.Text(_latin1(l.pagoSuccess), style: const pw.TextStyle(fontSize: 11, color: gris)),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    GpMoney.format(total.toStringAsFixed(2)),
                    style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold, color: azul),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 18),
            for (final (etiqueta, valor) in filas)
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(vertical: 7),
                decoration: const pw.BoxDecoration(
                  border: pw.Border(bottom: pw.BorderSide(color: PdfColor.fromInt(0xFFE2E8F0), width: 0.6)),
                ),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.SizedBox(
                      width: 110,
                      child: pw.Text(_latin1(etiqueta), style: const pw.TextStyle(fontSize: 10, color: gris)),
                    ),
                    pw.Expanded(
                      child: pw.Text(
                        _latin1(valor),
                        textAlign: pw.TextAlign.right,
                        style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            pw.Spacer(),
            if (tx.legend != null && tx.legend!.trim().isNotEmpty)
              pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 10),
                child: pw.Text(_latin1(tx.legend!.trim()), style: const pw.TextStyle(fontSize: 8, color: gris)),
              ),
            pw.Text(
              _latin1('${l.comprobanteGenerado} · ID ${tx.id}'),
              textAlign: pw.TextAlign.center,
              style: const pw.TextStyle(fontSize: 8, color: gris),
            ),
          ],
        ),
      ),
    );
    return doc.save();
  }

  static Future<void> compartir({
    required Uint8List bytes,
    required String nombre,
    required String tipo,
    required String texto,
    Rect? origen,
  }) async {
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile.fromData(bytes, mimeType: tipo, name: nombre)],
        fileNameOverrides: [nombre],
        text: texto,
        subject: texto,
        // iPad: la hoja de compartir se ancla al botón que la abrió.
        sharePositionOrigin: origen,
      ),
    );
  }

  /// Nombre de archivo estable y sin caracteres raros.
  static String nombreArchivo(Transaccion tx, String extension) {
    final folio = (tx.upc.isNotEmpty ? tx.upc : '${tx.id}').replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '');
    return 'comprobante-gestopago-$folio.$extension';
  }

  /// Las fuentes estándar del PDF solo cubren Latin-1 (incluye acentos y ñ):
  /// comillas tipográficas y otros símbolos se normalizan para no romper el documento.
  static String _latin1(String texto) {
    const reemplazos = {'‘': "'", '’': "'", '“': '"', '”': '"', '–': '-', '—': '-', '…': '...', '•': '*'};
    final b = StringBuffer();
    for (final ch in texto.characters) {
      final r = reemplazos[ch];
      if (r != null) {
        b.write(r);
      } else if (ch.runes.length == 1 && ch.runes.first <= 0xFF) {
        b.write(ch);
      }
    }
    return b.toString();
  }
}
