class Track {
  String id = DateTime.now().toString();
  String name;
  int tempo;
  int beatsPerBar;
  int clicksPerBeat;
  bool isComplex;
  List<Section> sections;

  Track.simple(this.name, this.tempo, this.beatsPerBar, this.clicksPerBeat)
      : isComplex = false;

  Track.complex(this.name, this.sections) : isComplex = true;

  Track(
      {this.name,
      this.tempo,
      this.beatsPerBar,
      this.clicksPerBeat,
      this.isComplex,
      this.sections});
}

class Section {
  String title;
  int tempo;
  int barsCount;
  int beatsPerBar;
  int clicksPerBeat;

  Section({
    this.title,
    this.tempo,
    this.barsCount,
    this.beatsPerBar,
    this.clicksPerBeat,
  });
}
