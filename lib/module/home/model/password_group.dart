import 'package:hive/hive.dart';

import 'password_entry.dart';

part 'password_group.g.dart';

@HiveType(typeId: 1)
class PasswordGroup {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final List<PasswordEntry> entries;

  PasswordGroup({required this.name, required this.entries});
}
