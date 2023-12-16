import 'package:fintracker/app.dart';
import 'package:fintracker/helpers/db.helper.dart';
import 'package:fintracker/providers/app_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await getDBInstance();

  AppProvider appProvider = await AppProvider.getInstance();

  runApp(MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => appProvider)],
      child: const App()));
}
