import 'package:flutter/cupertino.dart';

import '../../../modules/local_storage/local_storage.dart';
import '../models/setlist.dart';
import '../models/track.dart';

class SetlistManager with ChangeNotifier {
  final LocalStorage storage;

  List<Setlist?> _setlists = [];

  SetlistManager(this.storage) : _setlists = storage.getSetlists();

  List<Setlist?> get setlists {
    return [..._setlists];
  }

  Setlist? getSetlist(String id) {
    return _setlists.firstWhere((element) => element!.id == id);
  }

  void addSetlist(String? name) {
    _changeSetlists(
      () => _setlists.add(Setlist(name)),
    );
  }

  void editSetlist(Setlist? setlist, String? name) {
    _changeSetlists(
      () {
        final index = _setlists.indexOf(setlist);
        _setlists[index]!.name = name;
      },
    );
  }

  void deleteSetlist(int index) {
    _changeSetlists(
      () => _setlists.removeAt(index),
    );
  }

  void addTrack(String setlistId, Track track) {
    _changeSetlists(
      () => getSetlist(setlistId)!.addTrack(track),
    );
  }

  void editTrack(String setlistId, String trackId, Track newTrack) {
    _changeSetlists(
      () => getSetlist(setlistId)!.editTrack(trackId, newTrack),
    );
  }

  void deleteTrack(String setlistId, int index) {
    _changeSetlists(
      () => getSetlist(setlistId)!.deleteTrack(index),
    );
  }

  void _changeSetlists(Function change) {
    change();
    storage.saveSetlists(_setlists);

    notifyListeners();
  }
}
