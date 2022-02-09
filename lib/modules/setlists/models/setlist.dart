import 'dart:convert';

import 'track.dart';

class Setlist {
  final String id = DateTime.now().toString();
  String? name;
  final List<Track> _tracks = [];

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
    final index =
        _tracks.indexOf(_tracks.firstWhere((element) => element.id == trackId));
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
      'tracks': _tracks.map((x) => x.toMap()).toList(),
    };
  }

  factory Setlist.fromMap(Map<String, dynamic> map) {
    final setlist = Setlist(
      map['name'],
    );

    final tracks =
        List<Track>.from(map['tracks']?.map((x) => Track.fromMap(x)));

    for (final track in tracks) {
      setlist.addTrack(track);
    }

    return setlist;
  }

  String toJson() => json.encode(toMap());

  factory Setlist.fromJson(String source) =>
      Setlist.fromMap(json.decode(source));

  @override
  String toString() => 'Setlist(name: $name, tracks: $_tracks)';
}
