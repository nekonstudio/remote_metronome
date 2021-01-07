import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../remote/remote_synchronization.dart';
import 'metronome.dart';
import 'metronome_interface.dart';
import 'metronome_settings.dart';
import 'notifier_metronome.dart';
import 'remote_synchronized_metronome_impl.dart';

abstract class MetronomeBase implements MetronomeInterface {
  MetronomeSettings _settings;
  int _currentBarBeat;
  bool _isPlaying = false;
  StreamSubscription<dynamic> _currentBarBeatSubscription;

  MetronomeSettings get settings => _settings;
  bool get isPlaying => _isPlaying;
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

  void _performIfIsPlayingEquals(bool value, Function action) {
    if (value == _isPlaying) {
      action();
    }
  }

  Stream<dynamic> getCurrentBarBeatStream();

  @protected
  void onStart(MetronomeSettings settings);
  @protected
  void onChange(MetronomeSettings settings);
  @protected
  void onStop();

  void _setupAndStart(MetronomeSettings settings) {
    _settings = settings;
    _isPlaying = true;

    _currentBarBeatSubscription = getCurrentBarBeatStream()
        .listen((barBeat) => _currentBarBeat = barBeat);

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

final metronomeProvider = ChangeNotifierProvider<NotifierMetronome>(
  (ref) {
    // final deviceMode = ref.watch(synchronizationProvider).deviceMode;
    // final metronomeImpl = deviceMode == DeviceSynchronizationMode.Host
    //     ? RemoteSynchronizedMetronomeImpl(ref.read(synchronizationProvider))
    //     : Metronome();

    // final metronomeImpl = Metronome();

    // return NotifierMetronome(metronomeImpl);
    return NotifierMetronome();
  },
);

final isMetronomePlayingProvider =
    Provider((ref) => ref.watch(metronomeProvider).isPlaying ? true : false);

final currentBeatBarProvider =
    Provider((ref) => ref.watch(metronomeProvider).currentBarBeat);
