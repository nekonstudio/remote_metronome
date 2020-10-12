import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'providers/metronome.dart';
import 'providers/setlists_manager.dart';
import 'screens/simple_metronome_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SetlistManager(),
        ),
        ChangeNotifierProvider(
          create: (_) => Metronome(),
        ),
      ],
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
