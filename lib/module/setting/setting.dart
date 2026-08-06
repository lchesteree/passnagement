import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../service/backup_service.dart';
import '../../service/encryption_service.dart';
import '../../service/google_drive_service.dart';
import '../../service/preference_service.dart';
import '../setup/setup_page.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  String _version = '';
  bool _closeToTray = PreferenceService.closeToTray;
  bool _exportingFile = false;
  bool _backingUpDrive = false;

  static const _supportedLocales = [
    Locale('en'),
    Locale('zh'),
  ];

  static const _localeNames = {
    'en': 'English',
    'zh': '中文',
  };

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() => _version = '${info.version}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surfaceContainerLowest,
      body: Column(
        children: [
          _buildHeader(context, cs),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              children: [
                _buildSectionLabel(context, 'language'.tr()),
                _buildLanguageCard(context, cs),
                const SizedBox(height: 14),
                _buildSectionLabel(context, 'close_behavior'.tr()),
                _buildCloseToTrayCard(context, cs),
                const SizedBox(height: 14),
                _buildSectionLabel(context, 'backup'.tr()),
                _buildBackupCard(context, cs),
                const SizedBox(height: 14),
                _buildSectionLabel(context, 'version'.tr()),
                _buildAboutCard(context, cs),

                // For Testing No data
                /*TextButton(
                  onPressed: () async {
                    await EncryptionService.reset();
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const SetupPage()),
                            (_) => false,
                      );
                    }
                  },
                  child: const Text('Reset App', style: TextStyle(color: Colors.red)),
                ),*/
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme cs) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(4, 14, 16, 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cs.primary, cs.tertiary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
            onPressed: () => Navigator.pop(context),
            visualDensity: VisualDensity.compact,
          ),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(40),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.settings_outlined, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Text(
            'settings'.tr(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 6),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
      ),
    );
  }

  Widget _buildLanguageCard(BuildContext context, ColorScheme cs) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: cs.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: _supportedLocales.asMap().entries.map((entry) {
          final i = entry.key;
          final locale = entry.value;
          final isSelected = context.locale == locale;
          final isLast = i == _supportedLocales.length - 1;
          return InkWell(
            onTap: () => context.setLocale(locale),
            borderRadius: BorderRadius.vertical(
              top: i == 0 ? const Radius.circular(12) : Radius.zero,
              bottom: isLast ? const Radius.circular(12) : Radius.zero,
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isSelected ? cs.primaryContainer : cs.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.language,
                          size: 16,
                          color: isSelected ? cs.onPrimaryContainer : cs.outline,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _localeNames[locale.languageCode] ?? locale.languageCode,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected ? cs.primary : cs.onSurface,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Icon(Icons.check_circle_rounded, size: 18, color: cs.primary),
                    ],
                  ),
                ),
                if (!isLast)
                  Divider(
                    height: 1,
                    indent: 58,
                    endIndent: 14,
                    color: cs.outlineVariant.withAlpha(80),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCloseToTrayCard(BuildContext context, ColorScheme cs) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: cs.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _closeToTray ? cs.primaryContainer : cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.minimize_outlined,
                size: 16,
                color: _closeToTray ? cs.onPrimaryContainer : cs.outline,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'close_to_tray'.tr(),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: cs.onSurface,
                    ),
                  ),
                  Text(
                    'close_to_tray_desc'.tr(),
                    style: TextStyle(fontSize: 11, color: cs.outline),
                  ),
                ],
              ),
            ),
            Switch(
              value: _closeToTray,
              onChanged: (v) async {
                await PreferenceService.setCloseToTray(v);
                setState(() => _closeToTray = v);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportToFile() async {
    setState(() => _exportingFile = true);
    try {
      final path = await BackupService.saveToFile();
      if (path != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('export_success'.tr())),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('export_failed'.tr())),
        );
      }
    } finally {
      if (mounted) setState(() => _exportingFile = false);
    }
  }

  Future<void> _backupToDrive() async {
    setState(() => _backingUpDrive = true);
    try {
      final file = await BackupService.createTempBackup();
      await GoogleDriveService.backupFile(file);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('backup_drive_success'.tr())),
        );
      }
      await file.delete();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('backup_drive_failed'.tr())),
        );
      }
    } finally {
      if (mounted) setState(() => _backingUpDrive = false);
    }
  }

  Widget _buildBackupCard(BuildContext context, ColorScheme cs) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: cs.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          _buildBackupRow(
            context: context,
            cs: cs,
            icon: Icons.save_outlined,
            label: 'export_file'.tr(),
            desc: 'export_file_desc'.tr(),
            loading: _exportingFile,
            onTap: _exportToFile,
            isFirst: true,
          ),
          Divider(
            height: 1,
            indent: 58,
            endIndent: 14,
            color: cs.outlineVariant.withAlpha(80),
          ),
          /*_buildBackupRow(
            context: context,
            cs: cs,
            icon: Icons.cloud_upload_outlined,
            label: 'backup_drive'.tr(),
            desc: 'backup_drive_desc'.tr(),
            loading: _backingUpDrive,
            onTap: null, //_backupToDrive,
            isFirst: false,
          ),*/
        ],
      ),
    );
  }

  Widget _buildBackupRow({
    required BuildContext context,
    required ColorScheme cs,
    required IconData icon,
    required String label,
    required String desc,
    required bool loading,
    required VoidCallback? onTap,
    required bool isFirst,
  }) {
    return InkWell(
      onTap: loading ? null : onTap,
      borderRadius: BorderRadius.vertical(
        top: isFirst ? const Radius.circular(12) : Radius.zero,
        bottom: isFirst ? Radius.zero : const Radius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: cs.secondaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: loading
                  ? Padding(
                      padding: const EdgeInsets.all(8),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: cs.onSecondaryContainer,
                      ),
                    )
                  : Icon(icon, size: 16, color: cs.onSecondaryContainer),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: cs.onSurface,
                    ),
                  ),
                  Text(
                    desc,
                    style: TextStyle(fontSize: 11, color: cs.outline),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 18, color: cs.outline),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutCard(BuildContext context, ColorScheme cs) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: cs.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.info_outline, size: 16, color: cs.onPrimaryContainer),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Passnagement',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                  Text(
                    _version.isEmpty ? '...' : _version,
                    style: TextStyle(fontSize: 11, color: cs.outline),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
