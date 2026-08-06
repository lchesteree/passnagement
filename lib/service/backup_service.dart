import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'storage_service.dart';

class BackupService {
  static String _timestampedName() {
    final ts = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .substring(0, 19);
    return 'passnagement_backup_$ts.hive';
  }

  static Future<File> _sourceFile() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/${StorageService.boxName}.hive');
    if (!file.existsSync()) {
      throw Exception('Hive database file not found at ${file.path}');
    }
    return file;
  }

  static Future<String?> saveToFile() async {
    await StorageService.box.flush();
    final src = await _sourceFile();

    final path = await FilePicker.platform.saveFile(
      dialogTitle: 'Save Backup',
      fileName: _timestampedName(),
      type: FileType.any,
    );
    if (path == null) return null;

    await src.copy(path);
    return path;
  }

  static Future<File> createTempBackup() async {
    await StorageService.box.flush();
    final src = await _sourceFile();

    final dir = await getTemporaryDirectory();
    final dest = File('${dir.path}/${_timestampedName()}');
    await src.copy(dest.path);
    return dest;
  }
}
