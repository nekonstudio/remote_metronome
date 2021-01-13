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

  Track({this.name, this.settings, this.isComplex, this.sections});
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
}
