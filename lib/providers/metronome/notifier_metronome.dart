import 'dart:async';

import 'package:flutter/material.dart';

import 'metronome.dart';
import 'metronome_interface.dart';
import 'metronome_settings.dart';

class NotifierMetronome with ChangeNotifier implements MetronomeInterface {
  final Metronome metronome = Metronome();

  NotifierMetronome() {
    _previousIsPlayingValue = metronome.isPlaying;

    _subscribeToBarBeatChange();
  }

  bool _previousIsPlayingValue;
  StreamSubscription<dynamic> _currentBarBeatStreamSubscription;

  bool get isPlaying => metronome.isPlaying;
  int get currentBarBeat => metronome.currentBarBeat;

  @override
  void start(MetronomeSettings settings) {
    metronome.start(settings);

    _notifyListenersIfIsPlayingValueChanged();
  }

  @override
  void change(MetronomeSettings newSettings) {
    metronome.change(newSettings);

    _notifyListenersIfIsPlayingValueChanged();
  }

  @override
  void stop() {
    metronome.stop();

    _notifyListenersIfIsPlayingValueChanged();
  }

  void _notifyListenersIfIsPlayingValueChanged() {
    if (_previousIsPlayingValue != metronome.isPlaying) {
      _previousIsPlayingValue = metronome.isPlaying;
      notifyListeners();
    }
  }

  void _subscribeToBarBeatChange() {
    final stream = metronome.getCurrentBarBeatStream();
    _currentBarBeatStreamSubscription = stream.listen(_onBarBeatChange);
  }

  void _onBarBeatChange(_) {
    notifyListeners();
  }

  void _cancelBarBeatSubscription() {
    _currentBarBeatStreamSubscription.cancel();
  }
}
