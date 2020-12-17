import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RemoteMetronomeScreenController with ChangeNotifier {
  int _tempo;
  int _beatsPerBar;

  var _isInitialized = false;

  void initialize(int tempo, int beatsPerBar) {
    _tempo = tempo;
    _beatsPerBar = beatsPerBar;
    _isInitialized = true;

    notifyListeners();
  }

  set tempo(int value) {
    _tempo = value;
    notifyListeners();
  }

  set beatsPerBar(int value) {
    _beatsPerBar = value;
    notifyListeners();
  }

  bool get isInitialized => _isInitialized;
  int get tempo => _tempo;
  int get beatsPerBar => _beatsPerBar;
}

final remoteMetronomeScreenControllerProvider = ChangeNotifierProvider(
  (ref) => RemoteMetronomeScreenController(),
);
