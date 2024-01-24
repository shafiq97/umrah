import 'package:fintracker/providers/app_provider.dart';
import 'package:flutter/material.dart';
import 'package:pdftron_flutter/pdftron_flutter.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class SaiCounter extends StatefulWidget {
  const SaiCounter({super.key});

  @override
  State<SaiCounter> createState() => _SaiCounterState();
}

class _SaiCounterState extends State<SaiCounter> {
  Timer? _timer;
  bool showUpdateOptions =
      false; // Flag to control the visibility of update options

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer(const Duration(minutes: 1), () {
      setState(() {
        showUpdateOptions = true; // Show the inline update options
      });
    });
  }

  void _incrementSaiCount() {
    final counterProvider = Provider.of<AppProvider>(context, listen: false);
    counterProvider.incrementSaiCount();
    _startTimer(); // Reset the timer
    _hideUpdateOptions();
  }

  void resetSaiCount() {
    final counterProvider = Provider.of<AppProvider>(context, listen: false);
    counterProvider.resetSaiCount();
    _startTimer(); // Reset the timer
    _hideUpdateOptions();
  }

  void _hideUpdateOptions() {
    setState(() {
      showUpdateOptions = false; // Hide the update options
    });
  }

  void _openPdfViewer() async {
    String documentPath =
        "https://firebasestorage.googleapis.com/v0/b/fypdatabase-c8728.appspot.com/o/sai.pdf?alt=media&token=82792cad-d4b2-4483-9657-9c4079c4a0ce";

    if (Platform.isAndroid) {
      var status = await Permission.manageExternalStorage.request();
      if (status.isGranted) {
        try {
          PdftronFlutter.openDocument(documentPath);
        } catch (e) {
          print("Error opening document: $e");
        }
      } else if (status.isPermanentlyDenied) {
        openAppSettings();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final counterProvider = Provider.of<AppProvider>(context);

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/background.jpeg"),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Sai Count: ${counterProvider.saiCount}',
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _incrementSaiCount,
                child: const Text('+Round'),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: resetSaiCount,
                child: const Text('Reset'),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: _openPdfViewer,
            child: const Text('View Sai Guide'),
          ),
          if (showUpdateOptions) ...[
            SizedBox(height: 20),
            Text(
              'Do you want to update the Sai count?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _incrementSaiCount,
                  child: const Text('Yes, Update'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _hideUpdateOptions,
                  child: const Text('No, Thanks'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
