import 'dart:convert';

import 'package:hive/hive.dart';

import '../../utils/validable/property_validable.dart';
import '../../utils/validable/range_validable_property.dart';
import '../../utils/validable/validable.dart';

part 'metronome_settings.g.dart';

@HiveType(typeId: 0)
class MetronomeSettings extends PropertyValidable {
  @HiveField(0)
  final int tempo;

  @HiveField(1)
  final int beatsPerBar;

  @HiveField(2)
  final int clicksPerBeat;

  MetronomeSettings(
    this.tempo,
    this.beatsPerBar,
    this.clicksPerBeat,
  );

  int get minTempo => getProperty<RangeValidableProperty>('tempo').minValue;
  int get maxTempo => getProperty<RangeValidableProperty>('tempo').maxValue;

  @override
  List<Validable> get validableProperties => [
        RangeValidableProperty('tempo',
            propertyValue: tempo, minValue: 10, maxValue: 300),
        RangeValidableProperty('beatsPerBar',
            propertyValue: beatsPerBar, minValue: 1, maxValue: 16),
        RangeValidableProperty('clicksPerBeat',
            propertyValue: clicksPerBeat, minValue: 1, maxValue: 16),
      ];

  MetronomeSettings clampToValidTempo() => MetronomeSettings(
      tempo.clamp(minTempo, maxTempo), beatsPerBar, clicksPerBeat);

  MetronomeSettings copyWith({
    int tempo,
    int beatsPerBar,
    int clicksPerBeat,
  }) {
    return MetronomeSettings(
      tempo ?? this.tempo,
      beatsPerBar ?? this.beatsPerBar,
      clicksPerBeat ?? this.clicksPerBeat,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tempo': tempo,
      'beatsPerBar': beatsPerBar,
      'clicksPerBeat': clicksPerBeat,
    };
  }

  factory MetronomeSettings.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return MetronomeSettings(
      map['tempo'],
      map['beatsPerBar'],
      map['clicksPerBeat'],
    );
  }

  String toJson() => json.encode(toMap());

  factory MetronomeSettings.fromJson(String source) =>
      MetronomeSettings.fromMap(json.decode(source));

  @override
  String toString() =>
      'MetronomeSettings(tempo: $tempo, beatsPerBar: $beatsPerBar, clicksPerBeat: $clicksPerBeat)';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is MetronomeSettings &&
        o.tempo == tempo &&
        o.beatsPerBar == beatsPerBar &&
        o.clicksPerBeat == clicksPerBeat;
  }

  @override
  int get hashCode =>
      tempo.hashCode ^ beatsPerBar.hashCode ^ clicksPerBeat.hashCode;
}
