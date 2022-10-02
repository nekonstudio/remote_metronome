import 'package:flutter/cupertino.dart';
import 'package:metronom/modules/metronome/models/metronome_settings.dart';
import 'package:metronom/modules/setlists/models/section.dart';

import '../../../modules/local_storage/local_storage.dart';
import '../models/setlist.dart';
import '../models/track.dart';

class SetlistManager with ChangeNotifier {
  final LocalStorage storage;

  List<Setlist?> _setlists = [];

  SetlistManager(this.storage) {
    _initializeSetlists(storage.getSetlists());
  }

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

  void _initializeSetlists(List<Setlist> setlists) {
    if (setlists.isEmpty) {
      if (storage.isFirstAppLaunch()) {
        setlists = [
          Setlist('Przykładowa setlista')
            ..addTrack(
              Track.simple(
                'Przykładowy prosty utwór',
                MetronomeSettings(),
              ),
            )
            ..addTrack(
              Track.complex(
                'Przykładowy złożony utwór',
                [
                  Section(
                      title: 'Część 1',
                      barsCount: 4,
                      settings: MetronomeSettings()),
                  Section(
                      title: 'Część 2',
                      barsCount: 4,
                      settings: MetronomeSettings(tempo: 160)),
                  Section(
                      title: 'Część 3',
                      barsCount: 4,
                      settings: MetronomeSettings(tempo: 110)),
                  Section(
                      title: 'Część 4',
                      barsCount: 4,
                      settings: MetronomeSettings(tempo: 180)),
                ],
              ),
            ),
        ];
      }
    }

    _setlists = setlists;
  }

  void _changeSetlists(Function change) {
    change();
    storage.saveSetlists(_setlists);

    notifyListeners();
  }
}
