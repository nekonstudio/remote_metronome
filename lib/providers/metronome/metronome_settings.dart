import 'dart:convert';

class MetronomeSettings {
  final int tempo;
  final int beatsPerBar;
  final int clicksPerBeat;

  MetronomeSettings(
    this.tempo,
    this.beatsPerBar,
    this.clicksPerBeat,
  );

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
