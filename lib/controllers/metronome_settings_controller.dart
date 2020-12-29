import 'package:flutter/foundation.dart';

import '../providers/metronome/metronome_settings.dart';

class MetronomeSettingsController extends ValueNotifier<MetronomeSettings> {
  MetronomeSettingsController(MetronomeSettings defaultSettings)
      : super(defaultSettings);

  void increaseTempoBy1() => changeTempoBy(1);
  void decreaseTempoBy1() => changeTempoBy(-1);
  void increaseTempoBy5() => changeTempoBy(5);
  void decreaseTempoBy5() => changeTempoBy(-5);
  void changeTempoBy(int value) =>
      _changeParameterIfValid(tempo: this.value.tempo + value);
  void increaseBeatsPerBarBy1() => _changeBeatsPerBarBy(1);
  void decreaseBeatsPerBarBy1() => _changeBeatsPerBarBy(-1);
  void increaseClicksPerBeatBy1() => _changeClicksPerBeatBy(1);
  void decreaseClicksPerBeatBy1() => _changeClicksPerBeatBy(-1);
  void changeTempo(int newTempo) => _changeParameterIfValid(tempo: newTempo);

  void _changeBeatsPerBarBy(int value) =>
      _changeParameterIfValid(beatsPerBar: this.value.beatsPerBar + value);

  void _changeClicksPerBeatBy(int value) =>
      _changeParameterIfValid(clicksPerBeat: this.value.clicksPerBeat + value);

  void _changeParameterIfValid(
      {int tempo, int beatsPerBar, int clicksPerBeat}) {
    final newSettings = value.copyWith(
      tempo: tempo,
      beatsPerBar: beatsPerBar,
      clicksPerBeat: clicksPerBeat,
    );

    if (newSettings.isValid()) {
      value = newSettings;
      notifyListeners();
    }
  }
}
