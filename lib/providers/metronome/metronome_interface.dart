import 'package:metronom/providers/remote/remote_synchronization.dart';

import 'client_synchronized_metronome.dart';
import 'host_synchronized_metronome.dart';
import 'metronome.dart';
import 'metronome_settings.dart';

abstract class MetronomeInterface {
  factory MetronomeInterface.createBySynchronizationMode(RemoteSynchronization synchronization) {
    switch (synchronization.deviceMode) {
      case DeviceSynchronizationMode.Host:
        return ClientSynchronizedMetronome(synchronization);
      case DeviceSynchronizationMode.Client:
        return HostSynchronizedMetronome(synchronization);
      case DeviceSynchronizationMode.None:
        return Metronome();
      default:
        throw Exception('Not supported Metronome type');
    }
  }

  void start(MetronomeSettings settings);
  void change(MetronomeSettings newSettings);
  void stop();

  bool get isPlaying;
  int get currentBarBeat;
}
