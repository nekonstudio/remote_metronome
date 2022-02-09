import 'dart:async';

import 'package:flutter/material.dart';

import '../models/metronome_settings.dart';
import 'metronome_base.dart';
import 'metronome_interface.dart';

class NotifierMetronome with ChangeNotifier implements MetronomeInterface {
  final MetronomeBase impl;
  late StreamSubscription<dynamic> _currentBarBeatStreamSubscription;

  NotifierMetronome(this.impl) {
    print('NotifierMetronome()');
    _subscribeToBarBeatChange();
  }

  @override
  void dispose() {
    print('NotifierMetronome dispose');
    _currentBarBeatStreamSubscription.cancel();

    super.dispose();
  }

  @override
  bool get isPlaying => impl.isPlaying;

  @override
  int? get currentBarBeat => impl.currentBarBeat;

  @override
  void start(MetronomeSettings settings) {
    impl.start(settings);
  }

  @override
  void change(MetronomeSettings newSettings, {bool immediate = true}) {
    impl.change(newSettings, immediate: immediate);
  }

  @override
  void stop({bool immediate = true}) {
    impl.stop(immediate: immediate);
  }

  void _subscribeToBarBeatChange() {
    final stream = impl.getCurrentBarBeatStream();
    _currentBarBeatStreamSubscription = stream.listen(_onBarBeatChange);
  }

  void _onBarBeatChange(_) {
    notifyListeners();
  }
}
