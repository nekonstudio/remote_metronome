import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:metronom/sound_manager.dart';

class Metronome with ChangeNotifier {
  final SoundManager soundManager;
  int _currentTempo;
  int _beatsPerBar = 4;
  int _clicksPerBeat = 1;

  bool _isPlaying = false;
  int _currentBarBeat = 0;
  int _currentClickPerBeat = 1;
  double _tempoMultiplier = 1.0;

  Timer _clickTimer;
  Function _onBarCompleted;

  Metronome(this.soundManager);

  int get clickDuration {
    print('current tempo: $_currentTempo');
    return (((1 / (_currentTempo / 60) * 1000) ~/ _clicksPerBeat) ~/
        _tempoMultiplier);
  }

  int get currentBarBeat {
    return _currentBarBeat;
  }

  bool get isPlaying {
    return _isPlaying;
  }

  void setup(int tempo, {int beatsPerBar, int clicksPerBeat}) {
    _currentTempo = tempo;
    _beatsPerBar = beatsPerBar;
    _clicksPerBeat = clicksPerBeat;
  }

  void change(int tempo, bool play, {int beatsPerBar, int clicksPerBeat}) {
    terminate();
    setup(tempo, beatsPerBar: beatsPerBar, clicksPerBeat: clicksPerBeat);
    notifyListeners();
    _isPlaying = play;
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
      _reset();
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
