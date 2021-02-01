import 'package:flutter_riverpod/flutter_riverpod.dart';

enum DeviceSynchronizationMode { Host, Client, None }

class DeviceSynchronizationModeNotifier extends StateNotifier<DeviceSynchronizationMode> {
  DeviceSynchronizationModeNotifier() : super(DeviceSynchronizationMode.None);

  void changeMode(DeviceSynchronizationMode mode) => state = mode;
}

final deviceSynchronizationModeNotifierProvider = StateNotifierProvider(
  (ref) => DeviceSynchronizationModeNotifier(),
);
