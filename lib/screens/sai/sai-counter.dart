import 'package:fintracker/providers/app_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../../app.dart';

class SaiCounter extends StatefulWidget {
  @override
  _SaiCounterState createState() => _SaiCounterState();
}

class _SaiCounterState extends State<SaiCounter> {
  Timer? _timer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // routeObserver.subscribe(
    //     this as RouteAware, ModalRoute.of(context) as PageRoute);
  }

  @override
  void dispose() {
    // routeObserver.unsubscribe(this as RouteAware);
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
    _timer = Timer(Duration(minutes: 1), _showUpdatePopup);
  }

  void _showUpdatePopup() {
    if (mounted) {
      // Check if the widget is still in the tree
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Reminder"),
          content: Text("Did you forget to press the Sa'i counter button?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _incrementSaiCount(); // Increment the counter
              },
              child: Text("Update Counter"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _startTimer(); // Restart the timer
              },
              child: Text("No, Thanks"),
            ),
          ],
        ),
      );
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

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Sai Count: ${counterProvider.saiCount}',
          style: TextStyle(fontSize: 24),
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _incrementSaiCount,
              child: Text('Increment'),
            ),
            SizedBox(width: 20),
            ElevatedButton(
              onPressed: resetSaiCount,
              child: Text('Reset'),
            ),
          ],
        ),
      ],
    );
  }
}