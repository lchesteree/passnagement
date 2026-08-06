import 'package:hive_flutter/hive_flutter.dart';

import '../module/home/model/password_entry.dart';
import '../module/home/model/password_group.dart';

class StorageService {
  static const String boxName = 'groups';

  static Box<PasswordGroup> get box => Hive.box<PasswordGroup>(boxName);

  static List<PasswordGroup> getAll() => box.values.toList();

  static Future<int> addGroup(PasswordGroup group) => box.add(group);

  static Future<void> updateGroup(int index, PasswordGroup group) =>
      box.putAt(index, group);

  static Future<void> deleteGroup(int index) => box.deleteAt(index);

  static Future<void> addEntryToGroup(
    int groupIndex,
    PasswordEntry entry,
  ) async {
    final group = box.getAt(groupIndex)!;
    final updated = PasswordGroup(
      name: group.name,
      entries: [...group.entries, entry],
    );
    await box.putAt(groupIndex, updated);
  }

  static Future<void> deleteEntryFromGroup(
    int groupIndex,
    int entryIndex,
  ) async {
    final group = box.getAt(groupIndex)!;
    final entries = List<PasswordEntry>.from(group.entries)
      ..removeAt(entryIndex);
    final updated = PasswordGroup(name: group.name, entries: entries);
    await box.putAt(groupIndex, updated);
  }
}
