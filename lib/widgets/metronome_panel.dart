import 'package:flutter/material.dart';
import 'package:metronom/providers/metronome/metronome_settings.dart';

class MetronomePanel extends StatefulWidget {
  MetronomePanel({Key key}) : super(key: key);

  int _tempo = 120;
  int _beatsPerBar = 4;
  int _clicksPerBeat = 1;

  MetronomeSettings _settings = MetronomeSettings(120, 4, 1);

  MetronomePanel setup(MetronomeSettings settings) {
    _settings = settings;
    return this;
  }

  @override
  MetronomePanelState createState() => MetronomePanelState();
}

class MetronomePanelState extends State<MetronomePanel> {
  bool _isPlaying = false;
  int currentTempo = 120;
  int beatsPerBar = 4;
  int clicksPerBeat = 1;
  int _currentBarBeat = 0;
  int _currentClickPerBeat = 1;
  double _tempoMultiplier = 1.0;

  @override
  void initState() {
    super.initState();

    currentTempo = widget._tempo;
    beatsPerBar = widget._beatsPerBar;
    clicksPerBeat = widget._clicksPerBeat;
  }

  void _decreaseBeatsPerBar() {
    if (beatsPerBar > 1) {
      setState(() {
        beatsPerBar--;
      });
    }
  }

  void _increaseBeatsPerBar() {
    if (beatsPerBar < 16) {
      setState(() {
        beatsPerBar++;
      });
    }
  }

  void _decreaseClicksPerBeat() {
    if (clicksPerBeat > 1) {
      setState(() {
        clicksPerBeat--;
      });
    }
  }

  void _increaseClicksPerBeat() {
    if (clicksPerBeat < 16) {
      setState(() {
        clicksPerBeat++;
      });
    }
  }

  void _changeTempoBy(int value) {
    setState(() {
      currentTempo += value;
    });
  }

  Widget _buildChangeTempoButton(int value) {
    return SizedBox(
      width: 40,
      height: 40,
      child: FlatButton(
        padding: const EdgeInsets.all(0),
        onPressed: () {
          _changeTempoBy(value);
        },
        child: Text((value >= 0) ? '+$value' : '$value'),
        shape: Border.all(color: Colors.lightBlue),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print("Current tempo w metronomie: $currentTempo");
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
                      Text(
                        '$currentTempo',
                        style: TextStyle(fontSize: 60),
                      ),
                      _buildChangeTempoButton(5),
                      _buildChangeTempoButton(1),
                    ],
                  ),
                ),
                Slider(
                  value: currentTempo.toDouble(),
                  min: 10,
                  max: 300,
                  onChanged: (value) {
                    setState(() {
                      currentTempo = value.toInt();
                    });
                  },
                  onChangeEnd: (value) {},
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
                            onTap: _decreaseBeatsPerBar,
                            child: CircleAvatar(
                              radius: 13,
                              child: Text('-'),
                            ),
                          ),
                          Text(
                            '$beatsPerBar',
                            style: TextStyle(fontSize: 26),
                          ),
                          GestureDetector(
                            onTap: _increaseBeatsPerBar,
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
                            onTap: _decreaseClicksPerBeat,
                            child: CircleAvatar(
                              radius: 13,
                              child: Text('-'),
                            ),
                          ),
                          Text(
                            '$clicksPerBeat',
                            style: TextStyle(fontSize: 26),
                          ),
                          GestureDetector(
                            onTap: _increaseClicksPerBeat,
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
