import 'package:metronom/controllers/metronome_settings_controller.dart';
import 'package:metronom/providers/storage.dart';

class StorageMetronomeSettingsController extends MetronomeSettingsController {
  final Storage storage;

  StorageMetronomeSettingsController(this.storage)
      : super(storage.getMetronomeSettings());

  @override
  void changeParameter({int tempo, int beatsPerBar, int clicksPerBeat}) {
    super.changeParameter(
      tempo: tempo,
      beatsPerBar: beatsPerBar,
      clicksPerBeat: clicksPerBeat,
    );

    storage.saveMetronomeSettings(value);
  }
}
