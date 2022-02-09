import '../../local_storage/local_storage.dart';
import 'metronome_settings_controller.dart';

class StorageMetronomeSettingsController extends MetronomeSettingsController {
  final LocalStorage storage;

  StorageMetronomeSettingsController(this.storage)
      : super(initialSettings: storage.getMetronomeSettings());

  @override
  void changeParameter({int? tempo, int? beatsPerBar, int? clicksPerBeat}) {
    super.changeParameter(
      tempo: tempo,
      beatsPerBar: beatsPerBar,
      clicksPerBeat: clicksPerBeat,
    );

    storage.saveMetronomeSettings(value);
  }
}
