import 'package:hive_flutter/hive_flutter.dart';

class PreferenceService {
  static const String _boxName = 'prefs';
  static const String _closeToTrayKey = 'close_to_tray';

  static Future<void> open() => Hive.openBox(_boxName);

  static Box get _box => Hive.box(_boxName);

  static bool get closeToTray =>
      _box.get(_closeToTrayKey, defaultValue: false) as bool;

  static Future<void> setCloseToTray(bool value) =>
      _box.put(_closeToTrayKey, value);
}
