import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<dynamic> _backgroundMessageHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (message.data?.isNotEmpty == true) {
    // Handle data message
    final dynamic data = message.data;
    print('background data: $data');
  }

  if (message.notification != null) {
    // Handle notification message
    final dynamic notification = message.notification;
    print('background notification: $notification');
  }

  // Or do other work.
}

class RemoteNotifications {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  String _token;
  Stream<String> _tokenStream;

  final AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    'This channel is used for important notifications.', // description
    importance: Importance.high,
  );

  Future<RemoteNotifications> init() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);
    await _flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    _token = await FirebaseMessaging.instance.getToken();
    _tokenStream = FirebaseMessaging.instance.onTokenRefresh;
    _tokenStream.listen((String token) => _token = token);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification notification = message.notification;
      AndroidNotification android = message.notification?.android;
      print('onMessage');
      if (notification != null && android != null) {
        _flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channel.description,
                icon: 'app_notification_icon',
              ),
            ));
      }
    });

    return this;
  }

  String get token {
    print('token: $_token');
    return _token;
  }
}
