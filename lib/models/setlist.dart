import 'dart:convert';

import 'track.dart';

class Setlist {
  final String id = DateTime.now().toString();
  String name;
  final List<Track> _tracks = [
    // Track.simple('test 1', MetronomeSettings(100, 4, 1)),
    // Track.complex(
    //   'text',
    //   [
    //     Section(
    //       title: 'section1',
    //       barsCount: 2,
    //       settings: MetronomeSettings(120, 4, 1),
    //     ),
    //     Section(
    //       title: 'section2',
    //       barsCount: 4,
    //       settings: MetronomeSettings(240, 4, 1),
    //     ),
    //     Section(
    //       title: 'section3',
    //       barsCount: 2,
    //       settings: MetronomeSettings(120, 4, 1),
    //     ),
    //   ],
    // ),
    // Track.simple('test 2', MetronomeSettings(120, 4, 1)),
    // Track.simple('test 3', MetronomeSettings(159, 4, 1)),
    // Track.simple('test 4', MetronomeSettings(112, 3, 1)),
    // Track.simple('test 5', MetronomeSettings(112, 5, 1)),
    // Track.simple('test 6', MetronomeSettings(112, 6, 1)),
    // Track.simple('test 4', MetronomeSettings(112, 7, 1)),
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

  bool get hasTracks => tracksCount > 0;

  Track getTrack(String id) {
    return _tracks.firstWhere((element) => element.id == id);
  }

  void addTrack(Track track) {
    _tracks.add(track);
  }

  void editTrack(String trackId, Track newTrack) {
    final index = _tracks.indexOf(_tracks.firstWhere((element) => element.id == trackId));
    _tracks[index] = newTrack;
  }

  void deleteTrack(int index) {
    _tracks.removeAt(index);
  }

  void clear() {
    _tracks.clear();
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'tracks': _tracks?.map((x) => x?.toMap())?.toList(),
    };
  }

  factory Setlist.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    final setlist = Setlist(
      map['name'],
    );

    final tracks = List<Track>.from(map['tracks']?.map((x) => Track.fromMap(x)));

    for (final track in tracks) {
      setlist.addTrack(track);
    }

    return setlist;
  }

  String toJson() => json.encode(toMap());

  factory Setlist.fromJson(String source) => Setlist.fromMap(json.decode(source));

  @override
  String toString() => 'Setlist(name: $name, tracks: $_tracks)';
}
