import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:metronom/providers/metronome/metronome_settings.dart';

class Track {
  String id = DateTime.now().toString();
  String name;
  MetronomeSettings settings;
  bool isComplex;
  List<Section> sections;

  Track.simple(this.name, this.settings) : isComplex = false;

  Track.complex(this.name, this.sections) : isComplex = true;

  Track({
    this.name,
    this.settings,
    this.isComplex,
    this.sections,
  });

  Track copyWith({
    String name,
    MetronomeSettings settings,
    bool isComplex,
    List<Section> sections,
  }) {
    return Track(
      name: name ?? this.name,
      settings: settings ?? this.settings,
      isComplex: isComplex ?? this.isComplex,
      sections: sections ?? this.sections,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'settings': settings?.toMap(),
      'isComplex': isComplex,
      'sections': sections?.map((x) => x?.toMap())?.toList(),
    };
  }

  factory Track.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return Track(
      name: map['name'],
      settings: MetronomeSettings.fromMap(map['settings']),
      isComplex: map['isComplex'],
      sections: map['sections'] == null
          ? null
          : List<Section>.from(map['sections']?.map((x) => Section.fromMap(x))),
    );
  }

  String toJson() => json.encode(toMap());

  factory Track.fromJson(String source) => Track.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Track(name: $name, settings: $settings, isComplex: $isComplex, sections: $sections)';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Track &&
        o.name == name &&
        o.settings == settings &&
        o.isComplex == isComplex &&
        listEquals(o.sections, sections);
  }

  @override
  int get hashCode {
    return name.hashCode ^
        settings.hashCode ^
        isComplex.hashCode ^
        sections.hashCode;
  }
}

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
