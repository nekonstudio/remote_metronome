import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metronom/providers/metronome/metronome_settings.dart';

class RemoteMetronomeScreenController with ChangeNotifier {
  MetronomeSettings _metronomeSettings;

  var _isInitialized = false;

  void setMetronomeSettings(MetronomeSettings metronomeSettings) {
    _metronomeSettings = metronomeSettings;
    _isInitialized = true;

    notifyListeners();
  }

  bool get isInitialized => _isInitialized;
  MetronomeSettings get metronomeSettings => _metronomeSettings;
}

final remoteMetronomeScreenControllerProvider = ChangeNotifierProvider(
  (ref) => RemoteMetronomeScreenController(),
);
