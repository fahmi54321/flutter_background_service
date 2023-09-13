import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';

class Notification {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  // Future showNotificationWithoutSound(Position position) async {
  //   var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
  //     '1',
  //     'location-bg',
  //     channelDescription: 'fetch location in background',
  //     playSound: false,
  //     importance: Importance.max,
  //     priority: Priority.high,
  //   );
  //   var platformChannelSpecifics = NotificationDetails(
  //     android: androidPlatformChannelSpecifics,
  //   );
  //   await flutterLocalNotificationsPlugin.show(
  //     0,
  //     'Location fetched',
  //     position.toString(),
  //     platformChannelSpecifics,
  //     payload: '',
  //   );
  // }

  // Future showNotificationForeground() async {
  //   var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
  //     'my_foreground',
  //     'FOREGROUND-bg',
  //     channelDescription: 'fetch location in background',
  //     ongoing: true,
  //   );
  //   await flutterLocalNotificationsPlugin.show(
  //     888,
  //     'COOL SERVICE',
  //     'Awesome ${DateTime.now()}',
  //     NotificationDetails(
  //       android: androidPlatformChannelSpecifics,
  //     ),
  //   );
  // }

  // Notification() {
  //   var initializationSettingsAndroid = const AndroidInitializationSettings(
  //     '@mipmap/ic_launcher',
  //   );

  //   var initializationSettings = InitializationSettings(
  //     android: initializationSettingsAndroid,
  //   );
  //   flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  //   flutterLocalNotificationsPlugin.initialize(initializationSettings);
  // }
}
