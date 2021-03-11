import 'package:flutter/material.dart';

import '../../../widgets/text_circle_button.dart';
import '../../../widgets/value_choice_panel.dart';
import '../controllers/metronome_settings_controller.dart';
import 'change_tempo_button.dart';

class MetronomeSettingsPanel extends StatelessWidget {
  final MetronomeSettingsController metronomeSettingsController;
  final bool compactLayout;

  const MetronomeSettingsPanel({
    Key key,
    @required this.metronomeSettingsController,
    this.compactLayout = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (compactLayout)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ChangeTempoButton(
                metronomeSettingsController: metronomeSettingsController,
                value: -1,
              ),
              ChangeTempoButton(
                metronomeSettingsController: metronomeSettingsController,
                value: -5,
              ),
              ValueListenableBuilder(
                  valueListenable: metronomeSettingsController,
                  builder: (context, metronomeSettings, child) => Text(
                        '${metronomeSettings.tempo}',
                        style: TextStyle(fontSize: 60),
                      )),
              ChangeTempoButton(
                metronomeSettingsController: metronomeSettingsController,
                value: 5,
              ),
              ChangeTempoButton(
                metronomeSettingsController: metronomeSettingsController,
                value: 1,
              ),
            ],
          )
        else ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ChangeTempoButton(
                metronomeSettingsController: metronomeSettingsController,
                value: -1,
              ),
              SizedBox(width: 50),
              ChangeTempoButton(
                metronomeSettingsController: metronomeSettingsController,
                value: 1,
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextCircleButton(
                  'x0.5',
                  size: 26,
                  onPressed: metronomeSettingsController.halfTempo,
                ),
                ValueListenableBuilder(
                    valueListenable: metronomeSettingsController,
                    builder: (context, metronomeSettings, child) => Text(
                          '${metronomeSettings.tempo}',
                          style: TextStyle(fontSize: 60),
                        )),
                TextCircleButton(
                  'x2',
                  size: 26,
                  onPressed: metronomeSettingsController.doubleTempo,
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ChangeTempoButton(
                metronomeSettingsController: metronomeSettingsController,
                value: -5,
              ),
              SizedBox(width: 50),
              ChangeTempoButton(
                metronomeSettingsController: metronomeSettingsController,
                value: 5,
              ),
            ],
          ),
        ],
        SizedBox(height: 20),
        ValueListenableBuilder(
          valueListenable: metronomeSettingsController,
          builder: (context, metronomeSettings, child) => Slider(
            value: metronomeSettings.tempo.toDouble(),
            min: metronomeSettings.minTempo.toDouble(),
            max: metronomeSettings.maxTempo.toDouble(),
            onChanged: (value) => metronomeSettingsController.setTempo(value.toInt()),
          ),
        ),
        if (!compactLayout) SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ValueListenableBuilder(
              valueListenable: metronomeSettingsController,
              builder: (context, metronomeSettings, child) => ValueChoicePanel(
                value: metronomeSettings.beatsPerBar,
                title: 'Uderzeń na takt',
                onValueDecrement: metronomeSettingsController.decreaseBeatsPerBarBy1,
                onValueIncrement: metronomeSettingsController.increaseBeatsPerBarBy1,
              ),
            ),
            ValueListenableBuilder(
              valueListenable: metronomeSettingsController,
              builder: (context, metronomeSettings, child) => ValueChoicePanel(
                value: metronomeSettings.clicksPerBeat,
                title: 'Kliknięć na uderzenie',
                onValueDecrement: metronomeSettingsController.decreaseClicksPerBeatBy1,
                onValueIncrement: metronomeSettingsController.increaseClicksPerBeatBy1,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
