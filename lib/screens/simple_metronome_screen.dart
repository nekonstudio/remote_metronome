import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/metronome_settings_controller.dart';
import '../providers/metronome/metronome_base.dart';
import '../providers/metronome/metronome_settings.dart';
import '../providers/nearby/nearby_devices.dart';
import '../providers/remote/remote_command.dart';
import '../providers/remote/remote_synchronization.dart';
import '../widgets/app_drawer.dart';
import '../widgets/remote_mode_screen.dart';
import '../widgets/visualization.dart';

class SimpleMetronomeScreen extends StatefulWidget {
  static const String routePath = '/simpleMetronome';
  @override
  _SimpleMetronomeScreenState createState() => _SimpleMetronomeScreenState();
}

class _SimpleMetronomeScreenState extends State<SimpleMetronomeScreen> {
  static const MinTempo = 10;
  static const MaxTempo = 300;

  static const MinTempoMultiplier = 0.5;
  static const DefaultTempoMultiplier = 1.0;
  static const MaxTempoMultiplier = 2.0;

  double _tempoMultiplier = DefaultTempoMultiplier;
  Stopwatch _tapTempoStopwatch = Stopwatch();

  final _controller = MetronomeSettingsController(MetronomeSettings(120, 4, 1));

  @override
  void initState() {
    super.initState();

    if (context.read(synchronizationProvider).isSynchronized) {
      final settings = _controller.value;
      context.read(nearbyDevicesProvider).broadcastCommand(
            RemoteCommand.setMetronomeSettings(settings),
          );
    }
  }

  void changeRemoteMetronomeProperty(
      Function changeFunction, RemoteCommandType commandType) {
    if (context.read(synchronizationProvider).isSynchronized) {
      if (!context.read(metronomeProvider).isPlaying) {
        final MetronomeSettings value = changeFunction();
        print('value: $value');
        if (value != null) {
          context.read(nearbyDevicesProvider).broadcastCommand(
                RemoteCommand(commandType, jsonParameters: value.toJson()),
              );
        }
      } else {
        // TODO: showSnackbar
        print('tak nie można!');
      }
    } else {
      changeFunction();
      context.read(metronomeProvider).change(_controller.value);
    }
  }

  Widget _buildChangeTempoButton(BuildContext context, int value) {
    return SizedBox(
      width: 40,
      height: 40,
      child: FlatButton(
        padding: const EdgeInsets.all(0),
        onPressed: () {
          changeRemoteMetronomeProperty(
            () {
              _controller.changeTempoBy(value);
              return _controller.value;
            },
            RemoteCommandType.SetMetronomeSettings,
          );
        },
        child: Text((value >= 0) ? '+$value' : '$value'),
        shape: Border.all(color: Colors.lightBlue),
      ),
    );
  }

  Widget _buildWithController(
      Widget Function(
              BuildContext context, MetronomeSettings settings, Widget child)
          builder,
      {Widget child}) {
    return ValueListenableBuilder(
      valueListenable: _controller,
      builder: builder,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return RemoteModeScreen(
      title: Text('Metronom'),
      drawer: AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: _buildWithController(
                (context, metronomeSettings, child) =>
                    Visualization(metronomeSettings.beatsPerBar),
              ),
            ),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildChangeTempoButton(context, -1),
                    SizedBox(
                      width: 50,
                    ),
                    _buildChangeTempoButton(context, 1),
                  ],
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      GestureDetector(
                        onTap: () {
                          // setState(() {
                          //   _tempoMultiplier =
                          //       _tempoMultiplier >= DefaultTempoMultiplier
                          //           ? MinTempoMultiplier
                          //           : DefaultTempoMultiplier;
                          // });

                          changeRemoteMetronomeProperty(
                            () {
                              setState(() {
                                _tempoMultiplier =
                                    _tempoMultiplier >= DefaultTempoMultiplier
                                        ? MinTempoMultiplier
                                        : DefaultTempoMultiplier;
                              });
                              // _restartTapTempoStopwatch();

                              return _controller.value;
                            },
                            RemoteCommandType.SetMetronomeSettings,
                          );
                        },
                        child: CircleAvatar(
                          radius: 26,
                          child: Text('x0.5',
                              style: TextStyle(
                                color: Colors.white,
                              )),
                          backgroundColor:
                              _tempoMultiplier < DefaultTempoMultiplier
                                  ? Colors.blue
                                  : Colors.black,
                        ),
                      ),
                      _buildWithController(
                        (context, metronomeSettings, child) => Text(
                          '${metronomeSettings.tempo}',
                          style: TextStyle(fontSize: 60),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // setState(() {
                          //   _tempoMultiplier =
                          //       _tempoMultiplier <= DefaultTempoMultiplier
                          //           ? MaxTempoMultiplier
                          //           : DefaultTempoMultiplier;
                          // });

                          changeRemoteMetronomeProperty(
                            () {
                              setState(() {
                                _tempoMultiplier =
                                    _tempoMultiplier <= DefaultTempoMultiplier
                                        ? MaxTempoMultiplier
                                        : DefaultTempoMultiplier;
                              });
                              // _restartTapTempoStopwatch();

                              return _controller.value.tempo;
                            },
                            RemoteCommandType.SetMetronomeSettings,
                          );
                        },
                        child: CircleAvatar(
                          radius: 26,
                          child: Text('x2',
                              style: TextStyle(
                                color: Colors.white,
                              )),
                          backgroundColor:
                              _tempoMultiplier > DefaultTempoMultiplier
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
                    _buildChangeTempoButton(context, -5),
                    SizedBox(
                      width: 50,
                    ),
                    _buildChangeTempoButton(context, 5),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                _buildWithController(
                  (context, metronomeSettings, child) => Slider(
                    value: metronomeSettings.tempo.toDouble(),
                    min: MinTempo.toDouble(),
                    max: MaxTempo.toDouble(),
                    onChanged: (value) {
                      changeRemoteMetronomeProperty(() {
                        _controller.changeTempo(value.toInt());
                        // _restartTapTempoStopwatch();
                        return _controller.value;
                      }, RemoteCommandType.SetMetronomeSettings);
                    },
                  ),
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
                              changeRemoteMetronomeProperty(
                                () {
                                  _controller.decreaseBeatsPerBarBy1();
                                  return _controller.value;
                                },
                                RemoteCommandType.SetMetronomeSettings,
                              );
                            },
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
                            onTap: () {
                              changeRemoteMetronomeProperty(
                                () {
                                  _controller.increaseBeatsPerBarBy1();
                                  return _controller.value;
                                },
                                RemoteCommandType.SetMetronomeSettings,
                              );
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
                              _controller.decreaseClicksPerBeatBy1();

                              context
                                  .read(metronomeProvider)
                                  .change(_controller.value);
                            },
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
                            onTap: () {
                              _controller.increaseClicksPerBeatBy1();

                              context
                                  .read(metronomeProvider)
                                  .change(_controller.value);
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
                  child: Consumer(
                    builder: (context, watch, child) {
                      final isPlaying = watch(isMetronomePlayingProvider);
                      return GestureDetector(
                        onTap: () {
                          final metronome = context.read(metronomeProvider);
                          if (!metronome.isPlaying) {
                            print('current time: ${DateTime.now()}');

                            metronome.start(_controller.value);

                            // _restartTapTempoStopwatch();
                          } else {
                            metronome.stop();
                          }
                        },
                        child: CircleAvatar(
                          backgroundColor: Colors.red,
                          child: Icon(
                            isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                            size: 35,
                          ),
                          radius: 30,
                        ),
                      );
                    },
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
                              // if (context.read(metronomeProvider).isPlaying) {
                              //   if (_tapTempoStopwatch.isRunning) {
                              //     _calculateCurrentTempo(
                              //         _tapTempoStopwatch.elapsed);
                              //     _tapTempoStopwatch.reset();
                              //   }

                              //   setState(() {
                              //     _tapTempoStopwatch.start();
                              //   });

                              //   final soundManager = SoundManager();
                              //   soundManager
                              //       .playSound(soundManager.mediumClickSoundId);
                              // }
                            },
                            child: CircleAvatar(
                              backgroundColor: Colors.transparent,
                              radius: 28,
                              child: Consumer(
                                builder: (context, watch, child) => Icon(
                                  Icons.touch_app,
                                  color: watch(metronomeProvider).isPlaying
                                      ? Colors.grey
                                      : Colors.white,
                                  size: 35,
                                ),
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
