import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'notificador_sistema.dart';

/// Avisos nativos de Android e iOS con `flutter_local_notifications`.
class NotificadorLocal implements NotificadorSistema {
  NotificadorLocal([FlutterLocalNotificationsPlugin? plugin]) : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  static const _canal = AndroidNotificationChannel(
    'gestopago_movimientos',
    'Movimientos y seguridad',
    description: 'Compras, pagos y avisos de seguridad de tu cuenta',
    importance: Importance.high,
  );

  @override
  Future<void> inicializar({required void Function(String ruta) alTocar}) async {
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@drawable/ic_stat_gestopago'),
        // El permiso se pide en contexto, después del login, no al abrir la app.
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (respuesta) {
        final ruta = respuesta.payload;
        if (ruta != null && ruta.startsWith('/')) {
          alTocar(ruta);
        }
      },
    );
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_canal);
  }

  @override
  Future<bool> solicitarPermiso() async {
    try {
      final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (android != null) {
        return await android.requestNotificationsPermission() ?? false;
      }
      final ios = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      return await ios?.requestPermissions(alert: true, badge: true, sound: true) ?? false;
    } catch (e) {
      debugPrint('No se pudo solicitar el permiso de notificaciones: $e');
      return false;
    }
  }

  @override
  Future<void> mostrar({required int id, required String titulo, required String cuerpo, required String ruta}) {
    return _plugin.show(
      id: id,
      title: titulo,
      body: cuerpo,
      payload: ruta,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _canal.id,
          _canal.name,
          channelDescription: _canal.description,
          importance: Importance.high,
          priority: Priority.high,
          color: const Color(0xFF1A56DB),
          category: AndroidNotificationCategory.message,
          // Información bancaria: en la pantalla bloqueada no se muestra el contenido.
          visibility: NotificationVisibility.private,
          styleInformation: BigTextStyleInformation(cuerpo),
        ),
        iOS: const DarwinNotificationDetails(presentAlert: true, presentBanner: true, presentSound: true),
      ),
    );
  }
}
