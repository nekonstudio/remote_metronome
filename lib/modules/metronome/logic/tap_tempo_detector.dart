import 'package:flutter/material.dart';

class TapTempoDetector {
  final _stopwatch = Stopwatch();

  int _calculatedTempo;

  int get calculatedTempo => _calculatedTempo;
  bool get isActive => _stopwatch.isRunning;

  void registerTap() {
    if (!_stopwatch.isRunning) {
      _stopwatch.start();
    } else {
      final elapsedTime = _stopwatch.elapsedMilliseconds;
      _calculatedTempo = (1 / (elapsedTime / 60) * 1000).round();
      _stopwatch.reset();
    }
  }

  void reset() {
    _calculatedTempo = null;

    _stopwatch.stop();
    _stopwatch.reset();
  }
}

class NotifierTapTempoDetector extends TapTempoDetector with ChangeNotifier {
  @override
  void registerTap() {
    super.registerTap();

    notifyListeners();
  }

  @override
  void reset() {
    super.reset();

    notifyListeners();
  }
}
