import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum DeviceSynchronizationMode { Host, Client, None }

class DeviceSynchronizationModeNotifier with ChangeNotifier {
  DeviceSynchronizationMode _mode = DeviceSynchronizationMode.None;
  DeviceSynchronizationMode _previousMode = DeviceSynchronizationMode.None;

  bool get isSynchronized => _mode != DeviceSynchronizationMode.None;
  DeviceSynchronizationMode get previousMode => _previousMode;
  DeviceSynchronizationMode get mode => _mode;

  void changeMode(DeviceSynchronizationMode mode) {
    _previousMode = _mode;
    _mode = mode;
    notifyListeners();
  }

  void resetPreviousMode() => _previousMode = DeviceSynchronizationMode.None;
}

final deviceSynchronizationModeNotifierProvider = ChangeNotifierProvider(
  (ref) => DeviceSynchronizationModeNotifier(),
);
