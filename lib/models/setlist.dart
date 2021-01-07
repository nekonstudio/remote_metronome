import 'track.dart';

class Setlist {
  final String id = DateTime.now().toString();
  String name;
  final List<Track> _tracks = [
    Track.simple('test 1', 100, 4, 1),
    Track(
        name: 'test',
        isComplex: true,
        beatsPerBar: 4,
        clicksPerBeat: 1,
        sections: [
          Section(
              title: 'section1',
              barsCount: 2,
              beatsPerBar: 4,
              clicksPerBeat: 1,
              tempo: 120),
          Section(
              title: 'section2',
              barsCount: 4,
              beatsPerBar: 4,
              clicksPerBeat: 1,
              tempo: 240),
          Section(
              title: 'section3',
              barsCount: 2,
              beatsPerBar: 4,
              clicksPerBeat: 1,
              tempo: 120),
        ]),
    Track.simple('test 2', 120, 4, 1),
    Track.simple('test 3', 159, 4, 1),
    Track.simple('test 4', 112, 3, 1),
    Track.simple('test 5', 112, 5, 1),
    Track.simple('test 6', 112, 6, 1),
    Track.simple('test 4', 112, 7, 1),
  ];

  Setlist(
    this.name,
  );

  List<Track> get tracks {
    return [..._tracks];
  }

  int get tracksCount {
    return _tracks.length;
  }

  Track getTrack(String id) {
    return _tracks.firstWhere((element) => element.id == id);
  }

  void addTrack(Track track) {
    _tracks.add(track);
  }

  void editTrack(String trackId, Track newTrack) {
    final index =
        _tracks.indexOf(_tracks.firstWhere((element) => element.id == trackId));
    _tracks[index] = newTrack;
  }

  void deleteTrack(int index) {
    _tracks.removeAt(index);
  }
}
