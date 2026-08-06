import 'dart:io';

import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/auth_io.dart';
import 'package:url_launcher/url_launcher.dart';

class GoogleDriveService {
  // ──────────────────────────────────────────────────────────────────────────
  // TODO: Replace with your own credentials from Google Cloud Console.
  //
  //  Steps:
  //  1. Go to https://console.cloud.google.com/
  //  2. Create a project → Enable "Google Drive API"
  //  3. OAuth 2.0 credentials → Application type: "Desktop app"
  //  4. Paste the Client ID and Client Secret below
  // ──────────────────────────────────────────────────────────────────────────
  static ClientId _clientId = ClientId(
    'YOUR_CLIENT_ID.apps.googleusercontent.com',
    'YOUR_CLIENT_SECRET',
  );

  static const _scopes = [drive.DriveApi.driveFileScope];

  static Future<void> backupFile(File file) async {
    final authClient = await clientViaUserConsent(
      _clientId,
      _scopes,
      (url) async {
        final uri = Uri.parse(url);
        if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
          throw Exception('Could not open browser for Google sign-in');
        }
      },
    );

    try {
      final driveApi = drive.DriveApi(authClient);
      final fileName = file.path.split(Platform.pathSeparator).last;

      final driveFile = drive.File()
        ..name = fileName
        ..mimeType = 'application/octet-stream';

      final media = drive.Media(
        file.openRead(),
        await file.length(),
        contentType: 'application/octet-stream',
      );

      await driveApi.files.create(driveFile, uploadMedia: media);
    } finally {
      authClient.close();
    }
  }
}
