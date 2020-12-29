import 'dart:async';

import 'package:flutter/material.dart';

import 'metronome_impl.dart';
import 'metronome_interface.dart';
import 'metronome_settings.dart';

class NotifierMetronome with ChangeNotifier implements MetronomeInterface {
  final MetronomeImpl metronomeImpl;

  NotifierMetronome(this.metronomeImpl) {
    _previousIsPlayingValue = metronomeImpl.isPlaying;
  }

  bool _previousIsPlayingValue;
  StreamSubscription<dynamic> _currentBarBeatStreamSubscription;

  bool get isPlaying => metronomeImpl.isPlaying;
  int get currentBarBeat => metronomeImpl.currentBarBeat;

  @override
  void start(MetronomeSettings settings) {
    metronomeImpl.start(settings);

    _subscribeToBarBeatChange();
    _notifyListenersIfIsPlayingValueChanged();
  }

  @override
  void change(MetronomeSettings newSettings) {
    metronomeImpl.change(newSettings);

    _notifyListenersIfIsPlayingValueChanged();
  }

  @override
  void stop() {
    metronomeImpl.stop();

    _cancelBarBeatSubscription();
    _notifyListenersIfIsPlayingValueChanged();
  }

  void _notifyListenersIfIsPlayingValueChanged() {
    if (_previousIsPlayingValue != metronomeImpl.isPlaying) {
      _previousIsPlayingValue = metronomeImpl.isPlaying;
      notifyListeners();
    }
  }

  void _subscribeToBarBeatChange() {
    final stream = metronomeImpl.getCurrentBarBeatStream();
    _currentBarBeatStreamSubscription = stream.listen(_onBarBeatChange);
  }

  void _onBarBeatChange(_) {
    notifyListeners();
  }

  void _cancelBarBeatSubscription() {
    _currentBarBeatStreamSubscription.cancel();
  }
}
