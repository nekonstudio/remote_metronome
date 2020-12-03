import 'dart:core';

import 'package:flutter/material.dart';
import 'package:metronom/bluetooth_manager.dart';
import 'package:metronom/bluetooth_message.dart';
import 'package:metronom/providers/metronome.dart';
import 'package:provider/provider.dart';

class ClientControlScreen extends StatefulWidget {
  final BluetoothManager btManager;

  ClientControlScreen(this.btManager);

  @override
  _ClientControlScreenState createState() => _ClientControlScreenState();
}

class _ClientControlScreenState extends State<ClientControlScreen> {
  var _isInitialized = false;

  var isPlaying = false;

  BluetoothManager _btManager;
  Metronome _metronome;

  int _remoteTimeDiff;
  DateTime _storedTime;

  bool get isRemoteSynchronized {
    return _remoteTimeDiff != null;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_isInitialized) return;

    // _btManager = Provider.of<BluetoothManager>(context);
    // _btManager = widget.btManager;
    // _btManager.setInputListenerCallback(_executeBtCommand);

    _metronome = Provider.of<Metronome>(context);
    // _metronome.setup(120, beatsPerBar: 4, clicksPerBeat: 1);

    // _isInitialized = true;
  }

  void _executeBtCommand(BluetoothMessage message) async {
    final command = message.command;
    if (command == BluetoothCommand.Play) {
      final tempo = int.parse(message.parameters[0]);
      final beats = int.parse(message.parameters[1]);
      final clicks = int.parse(message.parameters[2]);

      // _metronome.change(
      //     tempo: tempo, beatsPerBar: beats, clicksPerBeat: clicks, play: false);

      final latency = DateTime.now()
          .difference(DateTime.fromMillisecondsSinceEpoch(message.timestamp)
              .add(Duration(milliseconds: -_remoteTimeDiff)))
          .inMilliseconds;

      print('latency: $latency ms');

      final waitTime = DateTime.fromMillisecondsSinceEpoch(message.timestamp)
          .add(Duration(milliseconds: -_remoteTimeDiff + 500));

      print('currentTime =\t${DateTime.now()}');
      print('waitTime =\t\t$waitTime');

      await Future.doWhile(() => DateTime.now().isBefore(waitTime));

      final hostNowTime =
          DateTime.now().add(Duration(milliseconds: _remoteTimeDiff));
      print('CLIENT START! (host) time: $hostNowTime');
      print('CLIENT START! (client) time: ${DateTime.now()}');
      _metronome.start(tempo, beats, clicks);
    } else if (command == BluetoothCommand.Stop) {
      _metronome.stop();
    } else if (command == BluetoothCommand.LatencyTest) {
      _btManager
          .broadcastMessage(BluetoothMessage(BluetoothCommand.LatencyTest));
    } else if (command == BluetoothCommand.ClockSync) {
      if (message.parameters.isEmpty) {
        _clockSyncRequest();
      } else {
        _remoteTimeDiff = int.parse(message.parameters.first);
        print(
            'Client clock sync success! Remote time difference: $_remoteTimeDiff');
      }
    }
  }

  void _clockSyncRequest() {
    _storedTime = DateTime.now();

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    _btManager.broadcastMessage(BluetoothMessage(BluetoothCommand.ClockSync,
        parameters: [timestamp.toString()]));
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      _btManager = widget.btManager;
      _btManager.setInputListenerCallback(_executeBtCommand);
      _isInitialized = true;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('test'),
      ),
      body: Center(
        // child: Text(isPlaying ? 'Odtwarzanie' : 'Stop'),

        child: Text(_metronome.isPlaying ? 'Odtwarzanie' : 'Stop'),
      ),
    );
  }
}
