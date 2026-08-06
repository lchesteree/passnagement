import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../module/home/model/password_group.dart';
import 'storage_service.dart';

class EncryptionService {
  static const String _keyName = 'hive_key';
  static const _storage = FlutterSecureStorage();

  static Future<bool> hasKey() => _storage.containsKey(key: _keyName);

  static Future<void> setup(String password) async {
    final key = _deriveKey(password);
    await _storage.write(key: _keyName, value: base64.encode(key));
    await _openBox(key);
  }

  static Future<void> openBoxFromStorage() async {
    final stored = await _storage.read(key: _keyName);
    final key = base64.decode(stored!);
    await _openBox(key);
  }

  static Future<void> _openBox(Uint8List key) async {
    await Hive.openBox<PasswordGroup>(
      StorageService.boxName,
      encryptionCipher: HiveAesCipher(key),
    );
  }

  static Uint8List _deriveKey(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return Uint8List.fromList(digest.bytes);
  }
}
