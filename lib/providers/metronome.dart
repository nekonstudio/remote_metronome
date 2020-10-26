import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

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

  void start(int tempo, int beatsPerBar, int clicksPerBeat,
      {double tempoMultiplier = 1.0}) {
    platform.invokeMethod('start', {
      'tempo': tempo,
      'beatsPerBar': beatsPerBar,
      'clicksPerBeat': clicksPerBeat,
      'tempoMultiplier': tempoMultiplier
    });

    _currentTempo = tempo;
    _beatsPerBar = beatsPerBar;
    _clicksPerBeat = clicksPerBeat;
    _tempoMultiplier = tempoMultiplier;

    _subscription = _channel.receiveBroadcastStream().listen((value) {
      _currentBarBeat = value;

      print('_currentBarBeat: $_currentBarBeat');

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

  void terminate() {
    if (_isPlaying) {
      // _reset();
      // _clickTimer.cancel();
    }
  }

  void setBarCompletedCallback(Function handler) {
    // _onBarCompleted = handler;
  }
}
