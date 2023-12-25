import 'package:fintracker/providers/app_provider.dart';
import 'package:flutter/material.dart';
import 'package:pdftron_flutter/pdftron_flutter.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:permission_handler/permission_handler.dart'; // Add this import
import 'dart:io';

class SaiCounter extends StatefulWidget {
  const SaiCounter({super.key});

  @override
  State<SaiCounter> createState() => _SaiCounterState();
}

class _SaiCounterState extends State<SaiCounter> {
  Timer? _timer;
  bool isDialogShowing = false; // Add a flag to track dialog state

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // routeObserver.subscribe(
    //     this as RouteAware, ModalRoute.of(context) as PageRoute);
  }

  @override
  void dispose() {
    if (isDialogShowing) {
      Navigator.of(context, rootNavigator: true)
          .pop(); // Dismiss the dialog if it's showing
    }
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didPushNext() {
    // Called when a new route has been pushed, and this route is no longer visible.
    // Cancel your timer here
  }

  @override
  void didPopNext() {
    // Called when the top route has been popped off, and this route shows up.
    // Restart your timer here
  }

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel(); // Cancel any existing timer
    _timer = Timer(const Duration(minutes: 1), _showUpdatePopup);
  }

  void _openPdfViewer() async {
    String documentPath =
        "https://firebasestorage.googleapis.com/v0/b/fypdatabase-c8728.appspot.com/o/sai.pdf?alt=media&token=82792cad-d4b2-4483-9657-9c4079c4a0ce"; // Replace with your local file path

    if (Platform.isAndroid) {
      // Request storage permission for Android
      var status = await Permission.manageExternalStorage.request();
      PermissionStatus.granted;
      // if (!status.isGranted) {
      //   return; // Exit if permission not granted
      // }

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

  void _showUpdatePopup() {
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          // ... AlertDialog content ...
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _incrementSaiCount(); // Increment the counter
              },
              child: const Text("Update Counter"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _startTimer(); // Restart the timer
              },
              child: const Text("No, Thanks"),
            ),
          ],
        ),
      ).then((_) {
        isDialogShowing = false; // Update the flag when dialog is dismissed
      });

      isDialogShowing = true; // Update the flag when showing the dialog
    }
  }

  void _incrementSaiCount() {
    final counterProvider = Provider.of<AppProvider>(context, listen: false);
    counterProvider.incrementSaiCount();
    _startTimer(); // Reset the timer
  }

  void resetSaiCount() {
    final counterProvider = Provider.of<AppProvider>(context, listen: false);
    counterProvider.resetSaiCount();
    _startTimer(); // Reset the timer
  }

  @override
  Widget build(BuildContext context) {
    final counterProvider = Provider.of<AppProvider>(context);

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
              "assets/images/background.jpeg"), // Replace with your image path
          fit: BoxFit.cover, // This will cover the entire container
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
        ],
      ),
    );
  }
}
