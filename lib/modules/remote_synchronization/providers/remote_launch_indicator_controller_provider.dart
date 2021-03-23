import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../logic/metronome/remote_synchronized_metronome.dart';

class RemoteLaunchIndicatorController with ChangeNotifier {
  bool _isActive = false;

  bool get isActive => _isActive;

  void activate() {
    _changeState(true);

    Future.delayed(
      RemoteSynchronizedMetronome.commandExecutionDuration + Duration(milliseconds: 120),
      () => _changeState(false),
    );
  }

  void _changeState(bool value) {
    _isActive = value;
    notifyListeners();
  }
}

final remoteLaunchIndicatorControllerProvider = ChangeNotifierProvider(
  (ref) => RemoteLaunchIndicatorController(),
);
