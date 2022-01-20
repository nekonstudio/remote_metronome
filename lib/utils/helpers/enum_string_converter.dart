import 'package:collection/collection.dart' show IterableExtension;

class EnumStringConverter {
  static String enumToString(Object? o) => o.toString().split('.').last;

  static T? enumFromString<T>(String key, List<T> values) =>
      values.firstWhereOrNull((v) => key == enumToString(v));
}
