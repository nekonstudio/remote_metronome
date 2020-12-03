import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

import 'screens/simple_metronome_screen.dart';

void main() {
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
