import 'package:fintracker/app.dart';
import 'package:fintracker/helpers/db.helper.dart';
import 'package:fintracker/providers/app_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pdftron_flutter/pdftron_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await getDBInstance();

  AppProvider appProvider = await AppProvider.getInstance();
  PdftronFlutter.initialize(
      "demo:1702801992392:7c8d81f503000000007f998fdad456a7600bc407865e66f78592f5433c"); // Add your license key

  runApp(MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => appProvider)],
      child: const App()));
}
