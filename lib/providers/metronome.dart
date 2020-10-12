import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:metronom/sound_manager.dart';

class Metronome with ChangeNotifier {
  final SoundManager soundManager = SoundManager();
  int _currentTempo;
  int _beatsPerBar = 4;
  int _clicksPerBeat = 1;

  bool _isPlaying = false;
  int _currentBarBeat = 0;
  int _currentClickPerBeat = 1;
  double _tempoMultiplier = 1.0;

  Timer _clickTimer;
  Function _onBarCompleted;

  static int _counter = 0;
  static int _previousTime = 0;

  get currentTempo => _currentTempo;
  get beatsPerBar => _beatsPerBar;
  get clicksPerBeat => _clicksPerBeat;
  get currentBarBeat => _currentBarBeat;
  get tempoMultiplier => _tempoMultiplier;

  int get clickDuration {
    print('current tempo: $_currentTempo');
    print('current _clicksPerBeat: $_clicksPerBeat');
    print('current _tempoMultiplier: $_tempoMultiplier');
    return (((1 / (_currentTempo / 60) * 1000) ~/ _clicksPerBeat) ~/
        _tempoMultiplier);
  }

  bool get isPlaying {
    return _isPlaying;
  }

  void setup(int tempo,
      {int beatsPerBar = 4,
      int clicksPerBeat = 1,
      double tempoMultiplier = 1.0}) {
    _currentTempo = tempo;
    _beatsPerBar = beatsPerBar;
    _clicksPerBeat = clicksPerBeat;
    _tempoMultiplier = tempoMultiplier;
  }

  void change(
      {int tempo,
      int beatsPerBar,
      int clicksPerBeat,
      double tempoMultiplier,
      bool play}) {
    tempo ??= _currentTempo;
    beatsPerBar ??= _beatsPerBar;
    clicksPerBeat ??= _clicksPerBeat;
    tempoMultiplier ??= _tempoMultiplier;

    if (tempo == _currentTempo &&
        beatsPerBar == _beatsPerBar &&
        clicksPerBeat == _clicksPerBeat &&
        tempoMultiplier == _tempoMultiplier) return;

    terminate();
    setup(tempo,
        beatsPerBar: beatsPerBar,
        clicksPerBeat: clicksPerBeat,
        tempoMultiplier: tempoMultiplier);

    notifyListeners();

    _isPlaying = play ?? _isPlaying;
    print(play);
    print(_isPlaying);
    if (_isPlaying) {
      start();
    }
  }

  void start() {
    if (_currentBarBeat == 0) {
      _currentBarBeat++;
    }

    if (!_isPlaying) {
      _playSound();
    }

    _clickTimer =
        Timer.periodic(Duration(milliseconds: clickDuration), _onTimerExpired);

    _isPlaying = true;

    notifyListeners();
  }

  void stop() {
    if (_isPlaying) {
      if (_clickTimer != null) {
        _clickTimer.cancel();
        _reset();

        notifyListeners();
      }
    }
  }

  void terminate() {
    if (_isPlaying) {
      // _reset();
      _clickTimer.cancel();
    }
  }

  void setBarCompletedCallback(Function handler) {
    _onBarCompleted = handler;
  }

  void _onTimerExpired(Timer timer) {
    _currentClickPerBeat++;

    if (_currentClickPerBeat > _clicksPerBeat) {
      _currentClickPerBeat = 1;
    }

    if (_currentClickPerBeat <= 1) {
      _currentBarBeat++;
      if (_currentBarBeat > _beatsPerBar) {
        _currentBarBeat = 1;

        if (_onBarCompleted != null) {
          _onBarCompleted();
        }
      }
    }

    notifyListeners();

    if (_isPlaying) {
      _playSound();
    }

    final currentTime = DateTime.now().millisecondsSinceEpoch;
    print('${(currentTime - _previousTime)}ms');

    _previousTime = currentTime;
  }

  void _reset() {
    _currentBarBeat = 0;
    _currentClickPerBeat = 1;
    _isPlaying = false;
  }

  void _playSound() {
    int soundId = _currentBarBeat <= 1
        ? _currentClickPerBeat <= 1
            ? soundManager.highClickSoundId
            : soundManager.lowClickSoundId
        : _currentClickPerBeat <= 1
            ? soundManager.mediumClickSoundId
            : soundManager.lowClickSoundId;

    soundManager.playSound(soundId);
  }
}
