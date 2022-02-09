import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/metronome_settings.dart';
import 'metronome_interface.dart';

abstract class MetronomeBase implements MetronomeInterface {
  int? _currentBarBeat;
  bool _isPlaying = false;
  late StreamSubscription<dynamic> _currentBarBeatSubscription;

  @override
  bool get isPlaying => _isPlaying;

  @override
  int? get currentBarBeat => _currentBarBeat;

  @override
  void start(MetronomeSettings settings) {
    _performIfIsPlayingEquals(false, () => _setupAndStart(settings));
  }

  @override
  void change(MetronomeSettings newSettings, {bool immediate = true}) {
    _performIfIsPlayingEquals(
        true, () => _change(newSettings, immediate: immediate));
  }

  @override
  void stop({bool immediate = true}) {
    _performIfIsPlayingEquals(true, () => _resetAndStop(immediate: immediate));
  }

  void copy(MetronomeBase other) {
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
  void onChange(MetronomeSettings settings, {bool immediate = true});
  @protected
  void onStop({bool immediate = true});

  void _performIfIsPlayingEquals(bool value, Function action) {
    if (value == _isPlaying) {
      action();
    }
  }

  void _setupAndStart(MetronomeSettings settings) {
    _isPlaying = true;

    _currentBarBeatSubscription = getCurrentBarBeatStream().listen((barBeat) {
      _currentBarBeat = barBeat;

      print('_currentBarBeat: $_currentBarBeat');
    });

    onStart(settings);
  }

  void _change(MetronomeSettings settings, {bool immediate = true}) {
    onChange(settings, immediate: immediate);
  }

  void _resetAndStop({bool immediate = true}) {
    if (immediate) {
      _isPlaying = false;
      _currentBarBeat = 0;

      _currentBarBeatSubscription.cancel();
    }

    onStop(immediate: immediate);
  }
}
