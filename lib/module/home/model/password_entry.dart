import 'package:hive/hive.dart';

part 'password_entry.g.dart';

@HiveType(typeId: 0)
class PasswordEntry {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String url;

  @HiveField(2)
  final String? server;

  @HiveField(3)
  final String username;

  @HiveField(4)
  final String password;

  PasswordEntry({
    required this.name,
    required this.url,
    this.server,
    required this.username,
    required this.password,
  });
}
