import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:metronom/providers/metronome.dart';
import 'package:metronom/sound_manager.dart';
import 'package:provider/provider.dart';
import 'package:soundpool/soundpool.dart';

import '../widgets/app_drawer.dart';
import '../widgets/visualization.dart';

class SimpleMetronomeScreen extends StatefulWidget {
  static const String routePath = '/simpleMetronome';
  @override
  _SimpleMetronomeScreenState createState() => _SimpleMetronomeScreenState();
}

class _SimpleMetronomeScreenState extends State<SimpleMetronomeScreen> {
  bool _isPlaying = false;
  int _currentTempo = 120;
  int _beatsPerBar = 4;
  int _clicksPerBeat = 1;
  double _tempoMultiplier = 1.0;
  Stopwatch _tapTempoStopwatch = Stopwatch();

  void _decreaseBeatsPerBar() {
    if (_beatsPerBar > 1) {
      setState(() {
        _beatsPerBar--;
      });
    }
  }

  void _increaseBeatsPerBar() {
    if (_beatsPerBar < 16) {
      setState(() {
        _beatsPerBar++;
      });
    }
  }

  void _decreaseClicksPerBeat() {
    if (_clicksPerBeat > 1) {
      setState(() {
        _clicksPerBeat--;
      });

      _restartTapTempoStopwatch();
    }
  }

  void _increaseClicksPerBeat() {
    if (_clicksPerBeat < 16) {
      setState(() {
        _clicksPerBeat++;
      });

      _restartTapTempoStopwatch();
    }
  }

  void _restartTapTempoStopwatch() {
    _tapTempoStopwatch.stop();
    _tapTempoStopwatch.reset();
  }

  void _changeTempoBy(int value) {
    setState(() {
      _currentTempo += value;
    });

    _restartTapTempoStopwatch();
  }

  void _calculateCurrentTempo(Duration elapsed) {
    setState(() {
      final newTempo = 60 ~/ (elapsed.inMilliseconds / 1000);
      _currentTempo = newTempo <= 300
          ? newTempo >= 10
              ? newTempo
              : 10
          : 300;
    });

    _restartTapTempoStopwatch();
  }

  Widget _buildChangeTempoButton(int value) {
    return SizedBox(
      width: 40,
      height: 40,
      child: FlatButton(
        padding: const EdgeInsets.all(0),
        onPressed: () {
          _changeTempoBy(value);

          final metronome = Provider.of<Metronome>(context, listen: false);
          metronome.change(tempo: _currentTempo);
        },
        child: Text((value >= 0) ? '+$value' : '$value'),
        shape: Border.all(color: Colors.lightBlue),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Metronom'),
      ),
      drawer: AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Visualization(
                  _beatsPerBar, Provider.of<Metronome>(context).currentBarBeat),
            ),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildChangeTempoButton(-1),
                    SizedBox(
                      width: 50,
                    ),
                    _buildChangeTempoButton(1),
                  ],
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _tempoMultiplier =
                                _tempoMultiplier >= 1 ? 0.5 : 1.0;
                          });

                          final metronome =
                              Provider.of<Metronome>(context, listen: false);
                          metronome.change(tempoMultiplier: _tempoMultiplier);

                          _restartTapTempoStopwatch();
                        },
                        child: CircleAvatar(
                          radius: 26,
                          child: Text('x0.5',
                              style: TextStyle(
                                color: Colors.white,
                              )),
                          backgroundColor: _tempoMultiplier < 1.0
                              ? Colors.blue
                              : Colors.black,
                        ),
                      ),
                      Text(
                        '$_currentTempo',
                        style: TextStyle(fontSize: 60),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _tempoMultiplier =
                                _tempoMultiplier <= 1 ? 2.0 : 1.0;
                          });

                          final metronome =
                              Provider.of<Metronome>(context, listen: false);
                          metronome.change(tempoMultiplier: _tempoMultiplier);

                          _restartTapTempoStopwatch();
                        },
                        child: CircleAvatar(
                          radius: 26,
                          child: Text('x2',
                              style: TextStyle(
                                color: Colors.white,
                              )),
                          backgroundColor: _tempoMultiplier > 1.0
                              ? Colors.blue
                              : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildChangeTempoButton(-5),
                    SizedBox(
                      width: 50,
                    ),
                    _buildChangeTempoButton(5),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Slider(
                  value: _currentTempo.toDouble(),
                  min: 10,
                  max: 300,
                  onChanged: (value) {
                    setState(() {
                      _currentTempo = value.toInt();
                    });
                  },
                  onChangeEnd: (value) {
                    final metronome =
                        Provider.of<Metronome>(context, listen: false);
                    metronome.change(tempo: _currentTempo);

                    _restartTapTempoStopwatch();
                  },
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      'Uderzeń na takt',
                      style: TextStyle(fontSize: 12),
                    ),
                    SizedBox(
                      height: 6,
                    ),
                    SizedBox(
                      width: 120,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          GestureDetector(
                            onTap: () {
                              _decreaseBeatsPerBar();

                              final metronome = Provider.of<Metronome>(context,
                                  listen: false);
                              metronome.change(beatsPerBar: _beatsPerBar);
                            },
                            child: CircleAvatar(
                              radius: 13,
                              child: Text('-'),
                            ),
                          ),
                          Text(
                            '$_beatsPerBar',
                            style: TextStyle(fontSize: 26),
                          ),
                          GestureDetector(
                            onTap: () {
                              _increaseBeatsPerBar();

                              final metronome = Provider.of<Metronome>(context,
                                  listen: false);
                              metronome.change(beatsPerBar: _beatsPerBar);
                            },
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
                Column(
                  children: [
                    Text(
                      'Kliknięć na uderzenie',
                      style: TextStyle(fontSize: 12),
                    ),
                    SizedBox(
                      height: 6,
                    ),
                    SizedBox(
                      width: 120,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          GestureDetector(
                            onTap: () {
                              _decreaseClicksPerBeat();

                              final metronome = Provider.of<Metronome>(context,
                                  listen: false);
                              metronome.change(clicksPerBeat: _clicksPerBeat);
                            },
                            child: CircleAvatar(
                              radius: 13,
                              child: Text('-'),
                            ),
                          ),
                          Text(
                            '$_clicksPerBeat',
                            style: TextStyle(fontSize: 26),
                          ),
                          GestureDetector(
                            onTap: () {
                              _increaseClicksPerBeat();

                              final metronome = Provider.of<Metronome>(context,
                                  listen: false);
                              metronome.change(clicksPerBeat: _clicksPerBeat);
                            },
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
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: Consumer<Metronome>(
                    builder: (context, metronome, child) => GestureDetector(
                      onTap: () {
                        if (metronome.isPlaying) {
                          metronome.stop();
                        } else {
                          // metronome.start();
                          metronome.change(
                            tempo: _currentTempo,
                            beatsPerBar: _beatsPerBar,
                            clicksPerBeat: _clicksPerBeat,
                            play: false,
                          );
                          metronome.start();

                          _tapTempoStopwatch.stop();
                          _tapTempoStopwatch.reset();
                        }
                      },
                      child: CircleAvatar(
                        backgroundColor: Colors.red,
                        child: Icon(
                          metronome.isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                          size: 35,
                        ),
                        radius: 30,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: _tapTempoStopwatch.isRunning
                            ? Colors.white
                            : Colors.blueGrey,
                        child: Material(
                          shape: CircleBorder(),
                          color: Colors.blueGrey,
                          clipBehavior: Clip.hardEdge,
                          child: GestureDetector(
                            onTapDown: (_) {
                              if (!_isPlaying) {
                                if (_tapTempoStopwatch.isRunning) {
                                  _calculateCurrentTempo(
                                      _tapTempoStopwatch.elapsed);
                                  _tapTempoStopwatch.reset();
                                }

                                setState(() {
                                  _tapTempoStopwatch.start();
                                });

                                final soundManager = SoundManager();
                                soundManager
                                    .playSound(soundManager.mediumClickSoundId);
                              }
                            },
                            child: CircleAvatar(
                              backgroundColor: Colors.transparent,
                              radius: 28,
                              child: Icon(
                                Icons.touch_app,
                                color: _isPlaying ? Colors.grey : Colors.white,
                                size: 35,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
