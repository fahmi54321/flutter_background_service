import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'notif.dart' as notif;

class WorkManagerPage extends StatefulWidget {
  const WorkManagerPage({super.key});

  @override
  State<WorkManagerPage> createState() => _WorkManagerPageState();
}

class _WorkManagerPageState extends State<WorkManagerPage> {
  static const simpleTaskKey = "be.tramckrijte.workmanagerExample.simpleTask";
  static const rescheduledTaskKey =
      "be.tramckrijte.workmanagerExample.rescheduledTask";
  static const failedTaskKey = "be.tramckrijte.workmanagerExample.failedTask";
  static const simpleDelayedTask =
      "be.tramckrijte.workmanagerExample.simpleDelayedTask";
  static const simplePeriodicTask =
      "be.tramckrijte.workmanagerExample.simplePeriodicTask";
  static const simplePeriodic1HourTask =
      "be.tramckrijte.workmanagerExample.simplePeriodic1HourTask";
  static const fetchLocationKey =
      "be.tramckrijte.workmanagerExample.fetchLocation";

  @pragma(
      'vm:entry-point') // Mandatory if the App is obfuscated or using Flutter 3.1+
  void callbackDispatcher() {
    Workmanager().executeTask((task, inputData) async {
      switch (task) {
        case simpleTaskKey:
          debugPrint("$simpleTaskKey was executed. inputData = $inputData");
          final prefs = await SharedPreferences.getInstance();
          prefs.setBool("test", true);
          debugPrint("Bool from prefs: ${prefs.getBool("test")}");
          break;
        case rescheduledTaskKey:
          final key = inputData!['key']!;
          final prefs = await SharedPreferences.getInstance();
          if (prefs.containsKey('unique-$key')) {
            debugPrint('has been running before, task is successful');
            return true;
          } else {
            await prefs.setBool('unique-$key', true);
            debugPrint('reschedule task');
            return false;
          }
        case failedTaskKey:
          debugPrint('failed task');
          return Future.error('failed');
        case simpleDelayedTask:
          debugPrint("$simpleDelayedTask was executed");
          break;
        case simplePeriodicTask:
          debugPrint("$simplePeriodicTask was executed");
          break;
        case simplePeriodic1HourTask:
          debugPrint("$simplePeriodic1HourTask was executed");
          break;
        case fetchLocationKey:
          final userPosition = await Geolocator.getCurrentPosition();

          notif.Notification notification = notif.Notification();
          notification.showNotificationWithoutSound(userPosition);
          break;
        case Workmanager.iOSBackgroundTask:
          debugPrint("The iOS background fetch was triggered");
          Directory? tempDir = await getTemporaryDirectory();
          String? tempPath = tempDir.path;
          debugPrint(
              "You can access other plugins in the background, for example Directory.getTemporaryDirectory(): $tempPath");
          break;
      }

      return Future.value(true);
    });
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Flutter WorkManager Example"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                "Plugin initialization",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              ElevatedButton(
                child: const Text("Start the Flutter background service"),
                onPressed: () {
                  Workmanager().initialize(
                    callbackDispatcher,
                    isInDebugMode: true,
                  );
                },
              ),
              const SizedBox(height: 16),

              //This task runs once.
              //Most likely this will trigger immediately
              ElevatedButton(
                child: const Text("Register OneOff Task"),
                onPressed: () {
                  Workmanager().registerOneOffTask(
                    simpleTaskKey,
                    simpleTaskKey,
                    inputData: <String, dynamic>{
                      'int': 1,
                      'bool': true,
                      'double': 1.0,
                      'string': 'string',
                      'array': [1, 2, 3],
                    },
                  );
                },
              ),
              ElevatedButton(
                child: const Text("Register rescheduled Task"),
                onPressed: () {
                  Workmanager().registerOneOffTask(
                    rescheduledTaskKey,
                    rescheduledTaskKey,
                    inputData: <String, dynamic>{
                      'key': Random().nextInt(64000),
                    },
                  );
                },
              ),
              ElevatedButton(
                child: const Text("Register failed Task"),
                onPressed: () {
                  Workmanager().registerOneOffTask(
                    failedTaskKey,
                    failedTaskKey,
                  );
                },
              ),
              //This task runs once
              //This wait at least 10 seconds before running
              ElevatedButton(
                  child: const Text("Register Delayed OneOff Task"),
                  onPressed: () {
                    Workmanager().registerOneOffTask(
                      simpleDelayedTask,
                      simpleDelayedTask,
                      initialDelay: const Duration(seconds: 10),
                    );
                  }),
              const SizedBox(height: 8),
              //This task runs periodically
              //It will wait at least 10 seconds before its first launch
              //Since we have not provided a frequency it will be the default 15 minutes
              ElevatedButton(
                  onPressed: Platform.isAndroid
                      ? () {
                          Workmanager().registerPeriodicTask(
                            simplePeriodicTask,
                            simplePeriodicTask,
                            initialDelay: const Duration(seconds: 10),
                          );
                        }
                      : null,
                  child: const Text("Register Periodic Task (Android)")),
              //This task runs periodically
              //It will run about every hour
              ElevatedButton(
                  onPressed: Platform.isAndroid
                      ? () {
                          Workmanager().registerPeriodicTask(
                            simplePeriodicTask,
                            simplePeriodic1HourTask,
                            frequency: const Duration(minutes: 16),
                          );
                        }
                      : null,
                  child: const Text("Register 1 hour Periodic Task (Android)")),
              const SizedBox(height: 8.0),
              ElevatedButton(
                  onPressed: Platform.isAndroid
                      ? () {
                          Workmanager().registerPeriodicTask(
                            simplePeriodicTask,
                            fetchLocationKey,
                            frequency: const Duration(minutes: 16),
                          );
                        }
                      : null,
                  child: const Text("Fetch location")),
              const SizedBox(height: 16),
              Text(
                "Task cancellation",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              ElevatedButton(
                child: const Text("Cancel All"),
                onPressed: () async {
                  await Workmanager().cancelAll();
                  print('Cancel all tasks completed');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
