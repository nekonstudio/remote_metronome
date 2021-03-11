import 'package:flutter/foundation.dart';

import '../models/metronome_settings.dart';

class MetronomeSettingsController extends ValueNotifier<MetronomeSettings> {
  MetronomeSettingsController({MetronomeSettings initialSettings = const MetronomeSettings()})
      : super(initialSettings);

  static const HalfTimeTempoMultipler = 0.5;
  static const DoubleTimeTempoMultipler = 2.0;

  void increaseTempoBy1() => changeTempoBy(1);
  void decreaseTempoBy1() => changeTempoBy(-1);
  void increaseTempoBy5() => changeTempoBy(5);
  void decreaseTempoBy5() => changeTempoBy(-5);
  void changeTempoBy(int value) => setTempo(this.value.tempo + value);
  void setTempo(int newTempo) => changeParameter(tempo: newTempo);
  void increaseBeatsPerBarBy1() => _changeBeatsPerBarBy(1);
  void decreaseBeatsPerBarBy1() => _changeBeatsPerBarBy(-1);
  void increaseClicksPerBeatBy1() => _changeClicksPerBeatBy(1);
  void decreaseClicksPerBeatBy1() => _changeClicksPerBeatBy(-1);
  void halfTempo() => _applyTempoMultiplier(HalfTimeTempoMultipler);
  void doubleTempo() => _applyTempoMultiplier(DoubleTimeTempoMultipler);

  void _changeBeatsPerBarBy(int value) =>
      changeParameter(beatsPerBar: this.value.beatsPerBar + value);

  void _changeClicksPerBeatBy(int value) =>
      changeParameter(clicksPerBeat: this.value.clicksPerBeat + value);

  void _applyTempoMultiplier(double multiplier) => changeParameter(
        tempo: (value.tempo * multiplier).round(),
      );

  @protected
  void changeParameter({int tempo, int beatsPerBar, int clicksPerBeat}) {
    final newSettings = value
        .copyWith(
          tempo: tempo,
          beatsPerBar: beatsPerBar,
          clicksPerBeat: clicksPerBeat,
        )
        .clampToValidTempo();

    if (newSettings.isValid()) {
      value = newSettings;
      notifyListeners();
    }
  }
}
