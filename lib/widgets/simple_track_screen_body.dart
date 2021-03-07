import 'package:flutter/material.dart';
import 'package:metronom/controllers/metronome_settings_controller.dart';

import 'metronome_settings_panel.dart';

class SimpleTrackScreenBody extends StatelessWidget {
  final MetronomeSettingsController controller;

  SimpleTrackScreenBody(this.controller);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.vertical(top: Radius.circular(10))),
            child: ListTile(
              title: Text('Wybierz tempo'),
            ),
          ),
          MetronomeSettingsPanel(controller),
        ],
      ),
    );
  }
}
