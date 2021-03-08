import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/metronome_settings.dart';
import 'metronome_interface.dart';

abstract class MetronomeBase implements MetronomeInterface {
  MetronomeSettings _settings;
  int _currentBarBeat;
  bool _isPlaying = false;
  StreamSubscription<dynamic> _currentBarBeatSubscription;

  MetronomeSettings get settings => _settings;

  @override
  bool get isPlaying => _isPlaying;

  @override
  int get currentBarBeat => _currentBarBeat;

  @override
  void start(MetronomeSettings settings) {
    _performIfIsPlayingEquals(false, () => _setupAndStart(settings));
  }

  @override
  void change(MetronomeSettings newSettings) {
    _performIfIsPlayingEquals(true, () => _change(newSettings));
  }

  @override
  void stop() {
    _performIfIsPlayingEquals(true, _resetAndStop);
  }

  void copy(MetronomeBase other) {
    _settings = other.settings;
    _currentBarBeat = other.currentBarBeat;
    _isPlaying = other.isPlaying;

    if (_isPlaying) {
      _currentBarBeatSubscription = getCurrentBarBeatStream().listen((barBeat) {
        _currentBarBeat = barBeat;
      });
    }
  }

  Stream<dynamic> getCurrentBarBeatStream();

  @protected
  void onStart(MetronomeSettings settings);
  @protected
  void onChange(MetronomeSettings settings);
  @protected
  void onStop();

  void _performIfIsPlayingEquals(bool value, Function action) {
    if (value == _isPlaying) {
      action();
    }
  }

  void _setupAndStart(MetronomeSettings settings) {
    _settings = settings;
    _isPlaying = true;

    _currentBarBeatSubscription = getCurrentBarBeatStream().listen((barBeat) {
      _currentBarBeat = barBeat;
    });

    onStart(_settings);
  }

  void _change(MetronomeSettings newSettings) {
    _settings = newSettings;

    onChange(_settings);
  }

  void _resetAndStop() {
    _settings = null;
    _isPlaying = false;
    _currentBarBeat = 0;

    _currentBarBeatSubscription.cancel();

    onStop();
  }
}
