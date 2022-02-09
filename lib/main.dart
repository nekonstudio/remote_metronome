import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'modules/local_storage/local_storage.dart';
import 'modules/metronome/models/metronome_settings.dart';
import 'modules/metronome/screens/simple_metronome_screen.dart';

void main() async {
  await Hive.initFlutter();

  Hive.registerAdapter(MetronomeSettingsAdapter());
  await Hive.openBox(LocalStorage.BoxName);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = ThemeData(
      primarySwatch: Colors.lightBlue,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      brightness: Brightness.dark,
    );
    return ProviderScope(
      child: GetMaterialApp(
        title: 'Metronom',
        defaultTransition: Transition.rightToLeft,
        theme: theme.copyWith(
          colorScheme:
              theme.colorScheme.copyWith(secondary: Colors.lightBlueAccent),
        ),
        home: SimpleMetronomeScreen(),
      ),
    );
  }
}
