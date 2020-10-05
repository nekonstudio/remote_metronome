import 'package:flutter/material.dart';
import 'package:metronom/bluetooth_manager.dart';
import 'package:metronom/bluetooth_message.dart';
import 'package:metronom/providers/metronome.dart';
import 'package:provider/provider.dart';

class HostControlScreen extends StatefulWidget {
  final BluetoothManager btManager;

  HostControlScreen(this.btManager);
  @override
  _HostControlScreenState createState() => _HostControlScreenState();
}

class _HostControlScreenState extends State<HostControlScreen> {
  var _isInitialized = false;

  BluetoothManager _btManager;
  Metronome _metronome;

  var _isPlayRequest = false;
  int _remoteTimeDiff;

  DateTime _storedTime;
  List<double> _latencyList = [];

  double get averageLatency {
    final sum = _latencyList.fold(
        0, (previousValue, element) => previousValue + element);

    return _latencyList.length > 0 ? sum / _latencyList.length : 0;
  }

  bool get isRemoteSynchronized {
    return _remoteTimeDiff != null;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_isInitialized) return;

    _btManager = widget.btManager;
    _btManager.setInputListenerCallback(_onMessageReceived);

    _metronome = Provider.of<Metronome>(context);
    _metronome.setup(120, beatsPerBar: 4, clicksPerBeat: 1);

    _isInitialized = true;
  }

  void _performLatencyTest() {
    _storedTime = DateTime.now();
    var msg = BluetoothMessage(BluetoothCommand.LatencyTest);

    _btManager.broadcastMessage(msg);
  }

  void _onMessageReceived(BluetoothMessage message) async {
    if (message.command == BluetoothCommand.LatencyTest) {
      final currentTime = DateTime.now();
      final latency = currentTime.difference(_storedTime).inMilliseconds / 2;

      print('Current time: ${currentTime.toIso8601String()}');
      print('Stored time: ${_storedTime.toIso8601String()}');
      // print('Connected devices: ${_btManager.connectedDevicesCount + 1}');

      _latencyList.add(latency);

      print('Last latency: $latency ms');
      print('Average latecy: $averageLatency ms');

      if (!_isPlayRequest) return;

      BluetoothMessage newMessage;
      Function action;
      if (latency > 70) {
        print('To big latency ($latency ms), trying again');
        newMessage = BluetoothMessage(BluetoothCommand.LatencyTest);
      } else {
        if (_metronome.isPlaying) {
          newMessage = BluetoothMessage(BluetoothCommand.Stop);
          action = _metronome.stop;
        } else {
          newMessage = BluetoothMessage(BluetoothCommand.Play, parameters: [
            120.toString(),
            4.toString(),
            1.toString(),
          ]);
          action = _metronome.start;
        }
      }

      _storedTime = DateTime.now();
      await _btManager.broadcastMessage(newMessage);
      if (action != null) {
        Future.delayed(Duration(milliseconds: latency.toInt()), action);
        setState(() {
          _isPlayRequest = false;
        });
      }
    } else if (message.command == BluetoothCommand.ClockSync) {
      if (!isRemoteSynchronized) {
        final latency =
            DateTime.now().difference(_storedTime).inMilliseconds / 2;

        print('Latency: ($latency ms)');

        if (latency > 14) {
          // perform clock sync as long as you get satisfying latency for reliable result
          print('To big latency, trying again');
          _clockSync();
        } else {
          final remoteTime = DateTime.fromMillisecondsSinceEpoch(
              int.parse(message.parameters.first));
          _remoteTimeDiff = remoteTime.difference(_storedTime).inMilliseconds -
              latency.toInt();

          print(
              'Host clock sync success! Remote time difference: $_remoteTimeDiff');
        }
      }

      if (isRemoteSynchronized) {
        _btManager.broadcastMessage(BluetoothMessage(BluetoothCommand.ClockSync,
            parameters: [(-_remoteTimeDiff).toString()]));
      }
    }
  }

  void _clockSync() {
    _remoteTimeDiff = null;
    _storedTime = DateTime.now();
    _btManager.broadcastMessage(BluetoothMessage(BluetoothCommand.ClockSync));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          RaisedButton(
            onPressed: _clockSync,
            child: Text('Clock sync'),
          ),
          RaisedButton(
            onPressed: () async {
              BluetoothMessage msg;
              // Function action;

              if (_metronome.isPlaying) {
                msg = BluetoothMessage(BluetoothCommand.Stop);
                _metronome.stop();
              } else {
                msg = BluetoothMessage(BluetoothCommand.Play, parameters: [
                  120.toString(),
                  4.toString(),
                  1.toString(),
                ]);

                Future.delayed(Duration(seconds: 1), _metronome.start);
              }

              msg.timestamp = DateTime.now().millisecondsSinceEpoch;
              _btManager.broadcastMessage(msg);
              // action();
            },
            child: Text(_metronome.isPlaying ? 'Zatrzymaj' : 'Odtwórz'),
          ),
          RaisedButton(
            onPressed: _performLatencyTest,
            child: Text('Test latencji'),
          ),
          RaisedButton(
            onPressed: () {
              print('WSZYSTKIE WYNIKI');
              _latencyList.asMap().forEach((i, value) {
                print('${i + 1}. $value ms');
              });
            },
            child: Text('Wszystkie wyniki'),
          ),
        ],
      ),
    );
  }
}
