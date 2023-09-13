import 'package:flutter/material.dart';
import 'package:flutter_background_service_app/background_service_page.dart';
import 'package:flutter_background_service_app/download_page.dart';
import 'package:flutter_background_service_app/work_manager_page.dart';
import 'package:geolocator/geolocator.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const WorkManagerPage(),
                  ),
                );
              },
              child: const Text('Work manager'),
            ),
            ElevatedButton(
              onPressed: () async {
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

                if (permission == LocationPermission.always) {
                  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BackgroundServicePage(),
                      ),
                    );
                  });
                }

                if (permission == LocationPermission.whileInUse) {
                  permission = await Geolocator.requestPermission();
                }
              },
              child: const Text('Background service'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DownloadPage(),
                  ),
                );
              },
              child: const Text('Download'),
            ),
          ],
        ),
      ),
    );
  }
}
