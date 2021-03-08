import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'local_storage.dart';

final localStorageProvider = Provider((ref) => LocalStorage());
