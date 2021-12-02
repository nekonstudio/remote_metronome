import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../setlists/models/setlist.dart';

enum ScreenState { SimpleMetronome, Setlist }

class _ScreenStateNotifier extends StateNotifier<ScreenState> {
  _ScreenStateNotifier(ScreenState state) : super(state);

  Setlist _setlist;
  Setlist get setlist => _setlist;

  void setSimpleMetronomeState() => state = ScreenState.SimpleMetronome;
  void setSetlistState(Setlist setlist) {
    _setlist = setlist;
    state = ScreenState.Setlist;
  }
}

final remoteScreenStateProvider =
    StateNotifierProvider<_ScreenStateNotifier, ScreenState>(
        (ref) => _ScreenStateNotifier(ScreenState.SimpleMetronome));
