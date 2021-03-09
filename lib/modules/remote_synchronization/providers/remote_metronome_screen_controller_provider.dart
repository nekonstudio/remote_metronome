import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/remote_metronome_screen_controller.dart';

final remoteMetronomeScreenControllerProvider = ChangeNotifierProvider(
  (ref) => RemoteMetronomeScreenController(),
);
