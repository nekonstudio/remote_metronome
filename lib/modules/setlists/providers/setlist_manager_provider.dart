import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../modules/local_storage/local_storage_provider.dart';
import '../logic/setlists_manager.dart';

final setlistManagerProvider = ChangeNotifierProvider(
  (ref) => SetlistManager(ref.watch(localStorageProvider)),
);
