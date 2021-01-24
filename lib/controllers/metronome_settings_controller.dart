import 'package:flutter/foundation.dart';

import '../providers/metronome/metronome_settings.dart';

class MetronomeSettingsController extends ValueNotifier<MetronomeSettings> {
  MetronomeSettingsController(MetronomeSettings initialSettings) : super(initialSettings);

  static const HalfTimeTempoMultipler = 0.5;
  static const DoubleTimeTempoMultipler = 2.0;

  bool _isHalfTimeTempoMultiplierActive = false;
  bool _isDoubleTimeTempoMultiplierActive = false;

  bool get isHalfTimeTempoMultiplierActive => _isHalfTimeTempoMultiplierActive;
  bool get isDoubleTimeTempoMultiplierActive => _isDoubleTimeTempoMultiplierActive;

  void increaseTempoBy1() => changeTempoBy(1);
  void decreaseTempoBy1() => changeTempoBy(-1);
  void increaseTempoBy5() => changeTempoBy(5);
  void decreaseTempoBy5() => changeTempoBy(-5);
  void changeTempoBy(int value) => changeTempo(this.value.tempo + value);
  void increaseBeatsPerBarBy1() => _changeBeatsPerBarBy(1);
  void decreaseBeatsPerBarBy1() => _changeBeatsPerBarBy(-1);
  void increaseClicksPerBeatBy1() => _changeClicksPerBeatBy(1);
  void decreaseClicksPerBeatBy1() => _changeClicksPerBeatBy(-1);
  void changeTempo(int newTempo) => changeParameter(tempo: newTempo);

  void toggleHalfTimeTempoMultiplier() {
    int newTempo;

    if (!_isHalfTimeTempoMultiplierActive && !_isDoubleTimeTempoMultiplierActive) {
      _isHalfTimeTempoMultiplierActive = true;
      newTempo = (value.tempo * HalfTimeTempoMultipler).round();
    } else if (_isHalfTimeTempoMultiplierActive) {
      _isHalfTimeTempoMultiplierActive = false;
      newTempo = (value.tempo * DoubleTimeTempoMultipler).round();
    } else {
      _isDoubleTimeTempoMultiplierActive = false;
      _isHalfTimeTempoMultiplierActive = true;
      newTempo = (value.tempo * HalfTimeTempoMultipler * HalfTimeTempoMultipler).round();
    }

    changeParameter(
      tempo: newTempo,
    );
  }

  void toggleDoubleTimeTempoMultiplier() {
    int newTempo;

    if (!_isDoubleTimeTempoMultiplierActive && !_isHalfTimeTempoMultiplierActive) {
      _isDoubleTimeTempoMultiplierActive = true;
      newTempo = (value.tempo * DoubleTimeTempoMultipler).round();
    } else if (_isDoubleTimeTempoMultiplierActive) {
      _isDoubleTimeTempoMultiplierActive = false;
      newTempo = (value.tempo * HalfTimeTempoMultipler).round();
    } else {
      _isHalfTimeTempoMultiplierActive = false;
      _isDoubleTimeTempoMultiplierActive = true;
      newTempo = (value.tempo * DoubleTimeTempoMultipler * DoubleTimeTempoMultipler).round();
    }

    changeParameter(
      tempo: newTempo,
    );
  }

  void _changeBeatsPerBarBy(int value) =>
      changeParameter(beatsPerBar: this.value.beatsPerBar + value);

  void _changeClicksPerBeatBy(int value) =>
      changeParameter(clicksPerBeat: this.value.clicksPerBeat + value);

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
