import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class DownloadPage extends StatefulWidget {
  const DownloadPage({super.key});

  @override
  State<DownloadPage> createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> {
  final _progressList = <double>[];

  // double count = 0.0;

  double currentProgress(int index) {
    //fetch the current progress,
    //its in a list because we might want to download
    // multiple files at the same time,
    // so this makes sure the correct download progress
    // is updated.

    try {
      return _progressList[index];
    } catch (e) {
      _progressList.add(0.0);
      return 0;
    }
  }

  void download(int index) async {
    NotificationService notificationService = NotificationService();

    final dio = Dio();

    try {
      dio.download(
        'https://storage.googleapis.com/approachcharts/test/5MB-test.ZIP',
        "/storage/emulated/0/Download/fileeNameeee.zip",
        onReceiveProgress: ((count, total) async {
          await Future.delayed(const Duration(seconds: 1), () {
            setState(() {
              _progressList[index] = (count / total);
              notificationService.createNotification(
                  100, ((count / total) * 100).toInt(), index);
            });
          });
        }),
      );
    } on DioException catch (e) {
      print("error downloading file $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
                onPressed: () async {
                  var status = await Permission.storage.status;
                  if (!status.isGranted) {
                    await Permission.storage.request();
                  }
                  if (status.isGranted) {
                    download(0);
                  }
                },
                child: const Text("Download")),
            CircularProgressIndicator(
              value: currentProgress(0),
            )
          ],
        ),
      ),
    );
  }
}

class NotificationService {
  //Hanle displaying of notifications.
  static final NotificationService _notificationService =
      NotificationService._internal();
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final AndroidInitializationSettings _androidInitializationSettings =
      const AndroidInitializationSettings('@mipmap/ic_launcher');

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal() {
    init();
  }

  void init() async {
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: _androidInitializationSettings,
    );
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void createNotification(int count, int i, int id) {
    //show the notifications.
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'progress channel', 'progress channel',
        channelDescription: 'progress channel description',
        channelShowBadge: false,
        importance: Importance.max,
        priority: Priority.high,
        onlyAlertOnce: true,
        showProgress: true,
        maxProgress: count,
        progress: i);
    var platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    _flutterLocalNotificationsPlugin.show(id, 'progress notification title',
        'progress notification body', platformChannelSpecifics,
        payload: 'item x');
  }
}
