import 'package:metronom/providers/metronome/metronome_settings.dart';

import 'track.dart';

class Setlist {
  final String id = DateTime.now().toString();
  String name;
  final List<Track> _tracks = [
    Track.simple('test 1', MetronomeSettings(100, 4, 1)),
    Track.complex(
      'text',
      [
        Section(
          title: 'section1',
          barsCount: 2,
          settings: MetronomeSettings(120, 4, 1),
        ),
        Section(
          title: 'section2',
          barsCount: 4,
          settings: MetronomeSettings(240, 4, 1),
        ),
        Section(
          title: 'section3',
          barsCount: 2,
          settings: MetronomeSettings(120, 4, 1),
        ),
      ],
    ),
    Track.simple('test 2', MetronomeSettings(120, 4, 1)),
    Track.simple('test 3', MetronomeSettings(159, 4, 1)),
    Track.simple('test 4', MetronomeSettings(112, 3, 1)),
    Track.simple('test 5', MetronomeSettings(112, 5, 1)),
    Track.simple('test 6', MetronomeSettings(112, 6, 1)),
    Track.simple('test 4', MetronomeSettings(112, 7, 1)),
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
