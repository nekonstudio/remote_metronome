import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/track.dart';
import '../remote/remote_synchronization.dart';
import 'remote_synchronized_metronome.dart';

class Metronome with ChangeNotifier {
  static const platform = const MethodChannel('com.example.metronom/metronom');
  static const _channel =
      const EventChannel('com.example.metronom/barBeatChannel');

  StreamSubscription<dynamic> _subscription;

  int _currentTempo;
  int _beatsPerBar = 4;
  int _clicksPerBeat = 1;

  bool _isPlaying = false;
  int _currentBarBeat = 0;
  double _tempoMultiplier = 1.0;

  get currentTempo => _currentTempo;
  get beatsPerBar => _beatsPerBar;
  get clicksPerBeat => _clicksPerBeat;
  get currentBarBeat => _currentBarBeat;
  get tempoMultiplier => _tempoMultiplier;

  bool get isPlaying {
    return _isPlaying;
  }

  @override
  void dispose() {
    print('METRONOME DISPOSE!!!!!');

    super.dispose();
  }

  // TODO: remove
  void setup(int tempo,
      {int beatsPerBar = 4,
      int clicksPerBeat = 1,
      double tempoMultiplier = 1.0}) {
    _currentTempo = tempo;
    _beatsPerBar = beatsPerBar;
    _clicksPerBeat = clicksPerBeat;
    _tempoMultiplier = tempoMultiplier;
  }

  void startTrack(Track track) {
    start(track.tempo, track.beatsPerBar, track.clicksPerBeat);
  }

  void test() {
    var timestamp = DateTime.now();
    platform.invokeMethod('test').then((value) => print(
        'test(): ${DateTime.now().difference(timestamp).inMilliseconds} ms'));
  }

  void start(int tempo, int beatsPerBar, int clicksPerBeat,
      {double tempoMultiplier = 1.0}) {
    test();
    var timestamp = DateTime.now();
    print('metronom.start(): ${timestamp}');
    // Timeline.startSync('interesting function');
    platform.invokeMethod('start', {
      'tempo': tempo,
      'beatsPerBar': beatsPerBar,
      'clicksPerBeat': clicksPerBeat,
      'tempoMultiplier': tempoMultiplier
    }).then((value) {
      // Timeline.finishSync();
      print(
          'wykonano w: ${DateTime.now().difference(timestamp).inMilliseconds} ms');
    });

    print('Metronome start!');

    _currentTempo = tempo;
    _beatsPerBar = beatsPerBar;
    _clicksPerBeat = clicksPerBeat;
    _tempoMultiplier = tempoMultiplier;

    _subscription = _channel.receiveBroadcastStream().listen((value) {
      _currentBarBeat = value;

      // print('_currentBarBeat: $_currentBarBeat');

      notifyListeners();
    });

    _isPlaying = true;
    notifyListeners();
  }

  void stop() {
    if (_isPlaying) {
      platform.invokeMethod('stop');

      _subscription.cancel();
      _currentBarBeat = 0;
      _isPlaying = false;
      notifyListeners();
    }
  }

  void change(
      {int tempo,
      int beatsPerBar,
      int clicksPerBeat,
      double tempoMultiplier,
      bool smooth = true}) {
    if (!_isPlaying) return;

    _currentTempo = tempo ?? _currentTempo;
    _beatsPerBar = beatsPerBar ?? _beatsPerBar;
    _clicksPerBeat = clicksPerBeat ?? _clicksPerBeat;
    _tempoMultiplier = tempoMultiplier ?? _tempoMultiplier;

    if (tempo == _currentTempo &&
        beatsPerBar == _beatsPerBar &&
        clicksPerBeat == _clicksPerBeat &&
        tempoMultiplier == _tempoMultiplier) return;

    smooth == false
        ? platform.invokeMethod('change', {
            'tempo': _currentTempo,
            'beatsPerBar': _beatsPerBar,
            'clicksPerBeat': _clicksPerBeat,
            'tempoMultiplier': _tempoMultiplier,
          })
        : platform.invokeMethod('smoothChange', {
            'tempo': _currentTempo,
            'beatsPerBar': _beatsPerBar,
            'clicksPerBeat': _clicksPerBeat,
            'tempoMultiplier': _tempoMultiplier,
          });
  }
}

final metronomeProvider = ChangeNotifierProvider<Metronome>((ref) {
  return ref.watch(synchronizationProvider).deviceMode ==
          DeviceSynchronizationMode.Host
      ? RemoteSynchronizedMetronome(ref.read(synchronizationProvider))
      : Metronome();
});
