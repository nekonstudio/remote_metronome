import 'package:flutter/material.dart';

import '../controllers/metronome_settings_controller.dart';

class ChangeTempoButton extends StatelessWidget {
  final MetronomeSettingsController? metronomeSettingsController;
  final int value;

  const ChangeTempoButton({
    Key? key,
    required this.metronomeSettingsController,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: FlatButton(
        padding: const EdgeInsets.all(0),
        onPressed: () {
          metronomeSettingsController!.changeTempoBy(value);
        },
        child: Text((value >= 0) ? '+$value' : '$value'),
        shape: Border.all(color: Colors.lightBlue),
      ),
    );
  }
}
