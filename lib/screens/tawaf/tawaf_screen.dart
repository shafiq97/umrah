import 'package:fintracker/providers/app_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:pdftron_flutter/pdftron_flutter.dart';

class TawafCounter extends StatefulWidget {
  @override
  _TawafCounterState createState() => _TawafCounterState();
}

class _TawafCounterState extends State<TawafCounter> {
  Timer? _timer;
  bool isDialogShowing = false; // Flag to track if dialog is open

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // routeObserver.subscribe(this as RouteAware, ModalRoute.of(context) as PageRoute);
  }

  void _openPdfViewer() async {
    String documentPath =
        "https://firebasestorage.googleapis.com/v0/b/fypdatabase-c8728.appspot.com/o/tawaf.pdf?alt=media&token=4092a817-643c-41a9-a3d5-45bef5f68feb"; // Replace with your file path or URL

    if (Platform.isAndroid) {
      // Request storage permission for Android
      var status = await Permission.manageExternalStorage.request();
      if (!status.isGranted) {
        return; // Exit if permission not granted
      }
    }

    try {
      PdftronFlutter.openDocument(documentPath);
    } catch (e) {
      print("Error opening document: $e");
    }
  }

  @override
  void dispose() {
    if (isDialogShowing) {
      Navigator.of(context, rootNavigator: true)
          .pop(); // Dismiss dialog if open
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
    // _timer = Timer(const Duration(minutes: 10), _showUpdatePopup);
  }

  void _showUpdatePopup() {
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Reminder"),
          content:
              const Text("Did you forget to press the Tawaf counter button?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _incrementTawafCount();
              },
              child: const Text("Update Counter"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _startTimer();
              },
              child: const Text("No, Thanks"),
            ),
          ],
        ),
      ).then((_) =>
          isDialogShowing = false); // Reset flag when dialog is dismissed

      isDialogShowing = true; // Set flag when showing the dialog
    }
  }

  void _incrementTawafCount() {
    final counterProvider = Provider.of<AppProvider>(context, listen: false);
    counterProvider.incrementTawafCount();
    _startTimer(); // Reset the timer
  }

  void resetTawafCount() {
    final counterProvider = Provider.of<AppProvider>(context, listen: false);
    counterProvider.resetTawafCount();
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
        ],
      ),
    );
  }
}
