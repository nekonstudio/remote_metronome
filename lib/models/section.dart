import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:metronom/providers/metronome/metronome_settings.dart';

class Section {
  String title;
  int barsCount;
  MetronomeSettings settings;

  Section({
    @required this.title,
    @required this.barsCount,
    @required this.settings,
  });

  Section copyWith({
    String title,
    int barsCount,
    MetronomeSettings settings,
  }) {
    return Section(
      title: title ?? this.title,
      barsCount: barsCount ?? this.barsCount,
      settings: settings ?? this.settings,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'barsCount': barsCount,
      'settings': settings?.toMap(),
    };
  }

  factory Section.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return Section(
      title: map['title'],
      barsCount: map['barsCount'],
      settings: MetronomeSettings.fromMap(map['settings']),
    );
  }

  String toJson() => json.encode(toMap());

  factory Section.fromJson(String source) =>
      Section.fromMap(json.decode(source));

  @override
  String toString() =>
      'Section(title: $title, barsCount: $barsCount, settings: $settings)';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Section &&
        o.title == title &&
        o.barsCount == barsCount &&
        o.settings == settings;
  }

  @override
  int get hashCode => title.hashCode ^ barsCount.hashCode ^ settings.hashCode;
}
