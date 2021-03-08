import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../logic/nearby_devices.dart';

final nearbyDevicesProvider = ChangeNotifierProvider((ref) => NearbyDevices(ref.read));
