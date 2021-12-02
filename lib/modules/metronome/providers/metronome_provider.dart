import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../remote_synchronization/logic/metronome/client_synchronized_metronome.dart';
import '../../remote_synchronization/logic/metronome/client_synchronized_track_metronome.dart';
import '../../remote_synchronization/logic/metronome/host_synchronized_metronome.dart';
import '../../remote_synchronization/providers/device_synchronization_mode_notifier_provider.dart';
import '../../remote_synchronization/providers/is_remote_setlist_screen_provider.dart';
import '../../remote_synchronization/providers/remote_launch_indicator_controller_provider.dart';
import '../../remote_synchronization/providers/remote_synchronization_provider.dart';
import '../logic/metronome_base.dart';
import '../logic/notifier_metronome.dart';
import '../logic/wakelock_metronome.dart';

final metronomeImplProvider = Provider<MetronomeBase>((ref) {
  ref.watch(deviceSynchronizationModeNotifierProvider);
  final synchronization = ref.read(synchronizationProvider);
  final isRemoteSetlistScreen = ref.watch(isRemoteSetlistScreenProvider);

  switch (synchronization.synchronizationMode.mode) {
    case DeviceSynchronizationMode.Host:
      final remoteLaunchIndicatorController =
          ref.read(remoteLaunchIndicatorControllerProvider);
      return isRemoteSetlistScreen
          ? ClientSynchronizedTrackMetronome(
              synchronization, remoteLaunchIndicatorController)
          : ClientSynchronizedMetronome(
              synchronization, remoteLaunchIndicatorController);
    case DeviceSynchronizationMode.Client:
      return HostSynchronizedMetronome(synchronization);
    case DeviceSynchronizationMode.None:
      return WakelockMetronome();
    default:
      throw Exception('Not supported Metronome type');
  }
});

// copy of metronome is used to allow change metronome type from remote to normal without
// stopping playing it and resetting its settings
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

final currentBeatBarProvider =
    Provider((ref) => ref.watch(metronomeProvider).currentBarBeat);
