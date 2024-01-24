// ignore_for_file: library_private_types_in_public_api

import 'package:fintracker/providers/app_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:pdftron_flutter/pdftron_flutter.dart';

class TawafCounter extends StatefulWidget {
  const TawafCounter({super.key});

  @override
  _TawafCounterState createState() => _TawafCounterState();
}

class _TawafCounterState extends State<TawafCounter> {
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

  void _incrementTawafCount() {
    final counterProvider = Provider.of<AppProvider>(context, listen: false);
    counterProvider.incrementTawafCount();
    _startTimer(); // Reset the timer
    _hideUpdateOptions();
  }

  void resetTawafCount() {
    final counterProvider = Provider.of<AppProvider>(context, listen: false);
    counterProvider.resetTawafCount();
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
        "https://firebasestorage.googleapis.com/v0/b/fypdatabase-c8728.appspot.com/o/tawaf.pdf?alt=media&token=4092a817-643c-41a9-a3d5-45bef5f68feb";
    if (Platform.isAndroid) {
      var status = await Permission.manageExternalStorage.request();
      if (!status.isGranted) {
        return;
      }
    }

    try {
      PdftronFlutter.openDocument(documentPath);
    } catch (e) {
      print("Error opening document: $e");
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
            'Tawaf Count: ${counterProvider.tawafCount}',
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _incrementTawafCount,
                child: const Text('+Round'),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: resetTawafCount,
                child: const Text('Reset'),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: _openPdfViewer,
            child: const Text('View Guideline'),
          ),
          if (showUpdateOptions) ...[
            const SizedBox(height: 20),
            const Text(
              'Did you forget to press the Tawaf counter button?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _incrementTawafCount,
                  child: const Text('Yes, Update'),
                ),
                const SizedBox(width: 10),
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
