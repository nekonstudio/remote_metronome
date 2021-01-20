import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:metronom/providers/metronome/metronome_settings.dart';
import 'package:metronom/providers/storage.dart';

import 'screens/simple_metronome_screen.dart';

void main() async {
  await Hive.initFlutter();

  Hive.registerAdapter(MetronomeSettingsAdapter());
  await Hive.openBox(Storage.BoxName);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: GetMaterialApp(
        title: 'Metronom',
        defaultTransition: Transition.rightToLeft,
        theme: ThemeData(
          primarySwatch: Colors.lightBlue,
          accentColor: Colors.lightBlueAccent,
          // canvasColor: Color.fromRGBO(35, 35, 35, 1),
          visualDensity: VisualDensity.adaptivePlatformDensity,
          brightness: Brightness.dark,
        ),
        home: SimpleMetronomeScreen(),
      ),
    );
  }
}
