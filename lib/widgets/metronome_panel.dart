import 'package:flutter/material.dart';
import 'package:metronom/controllers/metronome_settings_controller.dart';
import 'package:metronom/providers/metronome/metronome_settings.dart';

class MetronomePanel extends StatelessWidget {
  final MetronomeSettingsController controller;

  MetronomePanel(this.controller);

  Widget _buildWithController(
      Widget Function(
              BuildContext context, MetronomeSettings settings, Widget child)
          builder,
      {Widget child}) {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: builder,
      child: child,
    );
  }

  Widget _buildChangeTempoButton(int value) {
    return SizedBox(
      width: 40,
      height: 40,
      child: FlatButton(
        padding: const EdgeInsets.all(0),
        onPressed: () => controller.changeTempoBy(value),
        child: Text((value >= 0) ? '+$value' : '$value'),
        shape: Border.all(color: Colors.lightBlue),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // print("Current tempo w metronomie: $currentTempo");
    return Container(
      // padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildChangeTempoButton(-1),
                      _buildChangeTempoButton(-5),
                      _buildWithController(
                        (context, settings, child) => Text(
                          '${settings.tempo}',
                          style: TextStyle(fontSize: 60),
                        ),
                      ),
                      _buildChangeTempoButton(5),
                      _buildChangeTempoButton(1),
                    ],
                  ),
                ),
                _buildWithController(
                  (context, settings, child) => Slider(
                    value: settings.tempo.toDouble(),
                    min: settings.minTempo.toDouble(),
                    max: settings.maxTempo.toDouble(),
                    onChanged: (value) => controller.changeTempo(value.toInt()),
                    // onChangeEnd: (value) {},
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                child: Column(
                  children: [
                    Text(
                      'Uderzeń na takt',
                      style: TextStyle(fontSize: 12),
                    ),
                    SizedBox(
                      height: 6,
                    ),
                    Container(
                      width: 120,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          GestureDetector(
                            onTap: controller.decreaseBeatsPerBarBy1,
                            child: CircleAvatar(
                              radius: 13,
                              child: Text('-'),
                            ),
                          ),
                          _buildWithController(
                            (context, settings, child) => Text(
                              '${settings.beatsPerBar}',
                              style: TextStyle(fontSize: 26),
                            ),
                          ),
                          GestureDetector(
                            onTap: controller.increaseBeatsPerBarBy1,
                            child: CircleAvatar(
                              radius: 13,
                              child: Text('+'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                child: Column(
                  children: [
                    Text(
                      'Kliknięć na uderzenie',
                      style: TextStyle(fontSize: 12),
                    ),
                    SizedBox(
                      height: 6,
                    ),
                    Container(
                      width: 120,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          GestureDetector(
                            onTap: controller.decreaseClicksPerBeatBy1,
                            child: CircleAvatar(
                              radius: 13,
                              child: Text('-'),
                            ),
                          ),
                          _buildWithController(
                            (context, settings, child) => Text(
                              '${settings.clicksPerBeat}',
                              style: TextStyle(fontSize: 26),
                            ),
                          ),
                          GestureDetector(
                            onTap: controller.increaseClicksPerBeatBy1,
                            child: CircleAvatar(
                              radius: 13,
                              child: Text('+'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
