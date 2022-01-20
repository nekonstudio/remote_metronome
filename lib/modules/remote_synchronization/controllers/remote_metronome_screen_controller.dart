import 'package:flutter/foundation.dart';

import '../../metronome/models/metronome_settings.dart';

class RemoteMetronomeScreenController with ChangeNotifier {
  MetronomeSettings? _metronomeSettings;
  var _isInitialized = false;

  MetronomeSettings? get metronomeSettings => _metronomeSettings;
  bool get isInitialized => _isInitialized;

  void setMetronomeSettings(MetronomeSettings? metronomeSettings) {
    _metronomeSettings = metronomeSettings;
    _isInitialized = true;

    notifyListeners();
  }
}
