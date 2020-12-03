import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/setlist.dart';
import '../models/track.dart';

class SetlistManager with ChangeNotifier {
  List<Setlist> _setlists = [
    Setlist('Underkicks'),
    Setlist('Nekon'),
    Setlist('Lepiej Nie Będzie'),
  ];

  Setlist getSetlist(String id) {
    return _setlists.firstWhere((element) => element.id == id);
  }

  List<Setlist> get setlists {
    return [..._setlists];
  }

  void addSetlist(String name) {
    _setlists.add(Setlist(name));
    notifyListeners();
  }

  void editSetlist(Setlist setlist, String name) {
    final index = _setlists.indexOf(setlist);
    _setlists[index].name = name;
    notifyListeners();
  }

  void deleteSetlist(int index) {
    _setlists.removeAt(index);
    notifyListeners();
  }

  // Track getTrack(String setlistId, String trackId) {
  //   return getSetlist(setlistId)
  //       .tracks
  //       .firstWhere((element) => element.id == trackId);
  // }

  void addTrack(String setlistId, Track track) {
    getSetlist(setlistId).addTrack(track);
    notifyListeners();
  }

  void editTrack(String setlistId, String trackId, Track newTrack) {
    getSetlist(setlistId).editTrack(trackId, newTrack);
    notifyListeners();
  }

  void deleteTrack(String setlistId, int index) {
    getSetlist(setlistId).deleteTrack(index);
    notifyListeners();
  }

  // void selectNextTrackSection(String setlistId, String trackId) {
  //   getSetlist(setlistId).getTrack(trackId).selectNextSection();
  //   notifyListeners();
  // }

  // void selectPreviousTrackSection(String setlistId, String trackId) {
  //   getSetlist(setlistId).getTrack(trackId).selectPreviousSection();
  //   notifyListeners();
  // }
}

final setlistManagerProvider =
    ChangeNotifierProvider((ref) => SetlistManager());
