import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  int _currentBarBeat = 0;
  int _currentClickPerBeat = 1;
  double _tempoMultiplier = 1.0;
  int _highClickSoundId;
  int _mediumClickSoundId;
  int _lowClickSoundId;
  int _streamId;
  Timer _clickTimer;
  Stopwatch _tapTempoStopwatch = Stopwatch();

  int _tickCounter = 1;
  int _timestamp1 = 0;
  int _timestamp2 = 0;

  final soundPool = Soundpool(streamType: StreamType.music);

  int get clickDuration {
    return (((1 / (_currentTempo / 60) * 1000) ~/ _clicksPerBeat) ~/
        _tempoMultiplier);
  }

  @override
  void initState() {
    super.initState();

    rootBundle.load('assets/sounds/click_high.ogg').then((data) {
      soundPool.load(data).then((value) {
        _highClickSoundId = value;
        print('High sound id: $_highClickSoundId');
      });
    });
    rootBundle.load('assets/sounds/click_medium.ogg').then((data) {
      soundPool.load(data).then((value) {
        _mediumClickSoundId = value;
        print('Medium sound id: $_mediumClickSoundId');
      });
    });
    rootBundle.load('assets/sounds/click_low.ogg').then((data) {
      soundPool.load(data).then((value) {
        _lowClickSoundId = value;
        print('Low sound id: $_lowClickSoundId');
      });
    });
  }

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

      _restartClickTimer();
    }
  }

  void _increaseClicksPerBeat() {
    if (_clicksPerBeat < 16) {
      setState(() {
        _clicksPerBeat++;
      });

      _restartClickTimer();
    }
  }

  void _resetCurrentVariables() {
    _currentBarBeat = 0;
    _currentClickPerBeat = 1;
  }

  void _startClickTimer(Duration duration) {
    if (_currentBarBeat == 0) {
      setState(() {
        _currentBarBeat++;
      });
    }

    if (!_isPlaying) {
      _playSound();
    }

    _clickTimer = Timer.periodic(duration, (timer) {
      setState(() {
        _currentClickPerBeat++;

        if (_currentClickPerBeat > _clicksPerBeat) {
          _currentClickPerBeat = 1;
        }

        if (_currentClickPerBeat <= 1) {
          _currentBarBeat++;
          if (_currentBarBeat > _beatsPerBar) {
            _currentBarBeat = 1;
          }
        }
      });

      _playSound();
    });

    setState(() {
      _isPlaying = true;
    });
  }

  void _stopClickTimer() {
    if (_clickTimer != null) {
      _clickTimer.cancel();
      _resetCurrentVariables();
      setState(() {
        _isPlaying = false;
      });
    }
  }

  void _restartClickTimer() {
    if (_isPlaying) {
      _clickTimer.cancel();
      _startClickTimer(Duration(milliseconds: clickDuration));
    }

    _tapTempoStopwatch.stop();
    _tapTempoStopwatch.reset();
  }

  // void _restartAll() {
  //   _resetCurrentVariables();
  //   _restartClickTimer();
  // }

  void _changeTempoBy(int value) {
    setState(() {
      _currentTempo += value;
    });

    _restartClickTimer();
  }

  void _calculateCurrentTempo(Duration elapsed) {
    setState(() {
      final newTempo = 60 ~/ (elapsed.inMilliseconds / 1000);
      _currentTempo = newTempo <= 300 ? newTempo >= 10 ? newTempo : 10 : 300;
    });

    _restartClickTimer();
  }

  void _playSound() {
    int soundId = _currentBarBeat <= 1
        ? _currentClickPerBeat <= 1 ? _highClickSoundId : _lowClickSoundId
        : _currentClickPerBeat <= 1 ? _mediumClickSoundId : _lowClickSoundId;

    soundPool.play(soundId);
    // int now = DateTime.now().millisecondsSinceEpoch;
    // _timestamp1 = now - _timestamp1;
    // print(now);
    // print(_timestamp1);
    // print('[${_tickCounter++}]' +
    //     (DateTime.now().millisecondsSinceEpoch - _timestamp1).toString());
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Metronom'),
      ),
      drawer: AppDrawer(),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Visualization(_beatsPerBar, _currentBarBeat),
            ),
            Container(
              child: Column(
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
                            _restartClickTimer();
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
                            _restartClickTimer();
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
                      // _restartClickTimer();
                    },
                    onChangeEnd: (value) {
                      _restartClickTimer();
                    },
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
                              '$_beatsPerBar',
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
                              '$_clicksPerBeat',
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Spacer(),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (_isPlaying) {
                        _stopClickTimer();
                      } else {
                        _startClickTimer(Duration(milliseconds: clickDuration));
                        _tapTempoStopwatch.stop();
                        _tapTempoStopwatch.reset();
                      }
                    },
                    child: CircleAvatar(
                      backgroundColor: Colors.red,
                      child: Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 35,
                      ),
                      radius: 30,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      // Text('Nabij tempo'),
                      CircleAvatar(
                        radius: 30,
                        // backgroundColor: Colors.blueGrey,
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

                                _playSound();
                              }
                            },
                            child: CircleAvatar(
                              // backgroundColor: Colors.lightGreen,
                              backgroundColor: Colors.transparent,
                              radius: 28,
                              child: Icon(
                                Icons.touch_app,
                                color: _isPlaying ? Colors.grey : Colors.white,
                                size: 35,
                              ),
                            ),
                          ),
                          // InkWell(
                          //   highlightColor:
                          //       _isPlaying ? Colors.transparent : null,
                          //   splashColor: _isPlaying ? Colors.transparent : null,
                          // onTap: () {
                          //   if (!_isPlaying) {
                          //     if (_tapTempoStopwatch.isRunning) {
                          //       _calculateCurrentTempo(
                          //           _tapTempoStopwatch.elapsed);
                          //       _tapTempoStopwatch.reset();
                          //     }

                          //     setState(() {
                          //       _tapTempoStopwatch.start();
                          //     });

                          //     _playSound();
                          //   }
                          // },
                          //   child: CircleAvatar(
                          //     // backgroundColor: Colors.lightGreen,
                          //     backgroundColor: Colors.transparent,
                          //     radius: 28,
                          //     child: Icon(
                          //       Icons.touch_app,
                          //       color: _isPlaying ? Colors.grey : Colors.white,
                          //       size: 35,
                          //     ),
                          //   ),
                          // ),
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
