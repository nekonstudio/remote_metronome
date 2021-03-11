import '../../local_storage/local_storage.dart';
import '../../metronome/controllers/storage_metronome_settings_controller.dart';
import '../../metronome/logic/metronome_interface.dart';
import '../logic/nearby_devices.dart';
import '../logic/remote_command.dart';

class RemoteStorageMetronomeSettingsController extends StorageMetronomeSettingsController {
  final NearbyDevices nearbyDevices;
  final MetronomeInterface metronome;

  RemoteStorageMetronomeSettingsController(this.nearbyDevices, LocalStorage storage, this.metronome)
      : super(storage);

  @override
  void changeParameter({int tempo, int beatsPerBar, int clicksPerBeat}) {
    if (!metronome.isPlaying) {
      super.changeParameter(tempo: tempo, beatsPerBar: beatsPerBar, clicksPerBeat: clicksPerBeat);

      nearbyDevices.broadcastCommand(RemoteCommand.setMetronomeSettings(value));
    }
  }
}
