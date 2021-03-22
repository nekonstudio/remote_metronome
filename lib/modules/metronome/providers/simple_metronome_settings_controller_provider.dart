import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../local_storage/local_storage_provider.dart';
import '../../remote_synchronization/controllers/remote_storage_metronome_settings_controller.dart';
import '../../remote_synchronization/providers/device_synchronization_mode_notifier_provider.dart';
import '../../remote_synchronization/providers/nearby_devices_provider.dart';
import '../controllers/storage_metronome_settings_controller.dart';
import 'metronome_provider.dart';

final simpleMetronomeSettingsControllerProvider =
    Provider<StorageMetronomeSettingsController>((ref) {
  final storage = ref.read(localStorageProvider);
  final isSynchronized = ref.watch(deviceSynchronizationModeNotifierProvider).isSynchronized;
  final metronomeSettingsController = isSynchronized
      ? RemoteStorageMetronomeSettingsController(
          ref.read(nearbyDevicesProvider),
          storage,
          ref.read(metronomeProvider),
        )
      : StorageMetronomeSettingsController(storage);

  return metronomeSettingsController;
});
