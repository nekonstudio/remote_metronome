import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum DeviceSynchronizationMode { Host, Client, None }

class DeviceSynchronizationModeNotifier with ChangeNotifier {
  DeviceSynchronizationMode _mode = DeviceSynchronizationMode.None;

  bool get isSynchronized => _mode != DeviceSynchronizationMode.None;

  DeviceSynchronizationMode get mode => _mode;
  void changeMode(DeviceSynchronizationMode mode) {
    _mode = mode;
    notifyListeners();
  }
}

final deviceSynchronizationModeNotifierProvider = ChangeNotifierProvider(
  (ref) => DeviceSynchronizationModeNotifier(),
);
