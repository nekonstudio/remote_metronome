import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../logic/remote_synchronization.dart';
import 'device_synchronization_mode_notifier_provider.dart';
import 'nearby_devices_provider.dart';

final synchronizationProvider = Provider(
  (ref) => RemoteSynchronization(
    ref.read(nearbyDevicesProvider),
    ref.read(deviceSynchronizationModeNotifierProvider),
  ),
);
