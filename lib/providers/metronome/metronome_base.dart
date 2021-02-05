import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metronom/providers/remote/device_synchronization_mode_notifier.dart';
import 'package:metronom/screens/setlists/setlist_screen.dart';

import '../remote/remote_synchronization.dart';
import 'client_synchronized_metronome.dart';
import 'client_synchronized_track_metronome.dart';
import 'host_synchronized_metronome.dart';
import 'metronome.dart';
import 'metronome_interface.dart';
import 'metronome_settings.dart';
import 'notifier_metronome.dart';

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

final metronomeImplProvider = Provider<MetronomeBase>((ref) {
  ref.watch(deviceSynchronizationModeNotifierProvider);
  final synchronization = ref.read(synchronizationProvider);
  final isRemoteSetlistScreen = ref.watch(isRemoteSetlistScreenProvider.state);

  switch (synchronization.synchronizationMode.mode) {
    case DeviceSynchronizationMode.Host:
      return isRemoteSetlistScreen
          ? ClientSynchronizedTrackMetronome(synchronization)
          : ClientSynchronizedMetronome(synchronization);
    case DeviceSynchronizationMode.Client:
      return HostSynchronizedMetronome(synchronization);
    case DeviceSynchronizationMode.None:
      return Metronome();
    default:
      throw Exception('Not supported Metronome type');
  }
});

MetronomeBase _metronomeCopy;

final metronomeProvider = ChangeNotifierProvider<NotifierMetronome>(
  (ref) {
    final metronomeImpl = ref.watch(metronomeImplProvider);

    if (_metronomeCopy != null) {
      metronomeImpl.copy(_metronomeCopy);
    }
    _metronomeCopy = metronomeImpl;

    return NotifierMetronome(metronomeImpl);
  },
);

final isMetronomePlayingProvider =
    Provider((ref) => ref.watch(metronomeProvider).isPlaying ? true : false);

final currentBeatBarProvider = Provider((ref) => ref.watch(metronomeProvider).currentBarBeat);
