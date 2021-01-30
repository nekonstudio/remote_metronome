import 'dart:async';

import 'package:flutter/material.dart';

import 'metronome.dart';
import 'metronome_interface.dart';
import 'metronome_settings.dart';

class NotifierMetronome with ChangeNotifier implements MetronomeInterface {
  final MetronomeInterface metronome;
  StreamSubscription<dynamic> _currentBarBeatStreamSubscription;

  NotifierMetronome(this.metronome) {
    _subscribeToBarBeatChange();
  }

  @override
  void dispose() {
    _currentBarBeatStreamSubscription.cancel();

    print('NotifierMetronome dispose');

    super.dispose();
  }

  @override
  bool get isPlaying => metronome.isPlaying;

  @override
  int get currentBarBeat => metronome.currentBarBeat;

  @override
  void start(MetronomeSettings settings) {
    metronome.start(settings);
  }

  @override
  void change(MetronomeSettings newSettings) {
    metronome.change(newSettings);
  }

  @override
  void stop() {
    metronome.stop();
  }

  @override
  void syncStart() {
    metronome.syncStart();
  }

  @override
  void syncStartPrepare(MetronomeSettings settings) {
    metronome.syncStartPrepare(settings);
  }

  void _subscribeToBarBeatChange() {
    final stream = Metronome().getCurrentBarBeatStream();
    _currentBarBeatStreamSubscription = stream.listen(_onBarBeatChange);
  }

  void _onBarBeatChange(_) {
    notifyListeners();
  }
}
