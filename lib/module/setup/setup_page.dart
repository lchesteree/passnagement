import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../service/encryption_service.dart';
import '../home/home_page.dart';

class SetupPage extends StatefulWidget {
  const SetupPage({super.key});

  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  // ── setup mode ──
  final _formKey = GlobalKey<FormState>();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _visible = false;
  bool _saving = false;

  // ── restore mode ──
  bool _restoreMode = false;
  String? _backupPath;
  final _restorePasswordCtrl = TextEditingController();
  bool _restoreVisible = false;
  bool _restoring = false;

  @override
  void dispose() {
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _restorePasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    await EncryptionService.setup(_passwordCtrl.text);
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage(title: 'Passnagement')),
      );
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );
    if (result != null && result.files.single.path != null) {
      setState(() => _backupPath = result.files.single.path!);
    }
  }

  Future<void> _restore() async {
    if (_backupPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('select_backup_first'.tr())),
      );
      return;
    }
    if (_restorePasswordCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('enter_password_first'.tr())),
      );
      return;
    }
    setState(() => _restoring = true);
    try {
      await EncryptionService.restore(_restorePasswordCtrl.text, _backupPath!);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage(title: 'Passnagement')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('restore_failed'.tr())),
        );
        setState(() => _restoring = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: _restoreMode ? _buildRestoreForm(context) : _buildSetupForm(context),
        ),
      ),
    );
  }

  Widget _buildSetupForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.lock, size: 56),
          const SizedBox(height: 16),
          Text(
            'setup_title'.tr(),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'setup_subtitle'.tr(),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _passwordCtrl,
            obscureText: !_visible,
            decoration: InputDecoration(
              labelText: 'master_password'.tr(),
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(_visible ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _visible = !_visible),
              ),
            ),
            validator: (v) =>
                (v == null || v.length < 8) ? 'min_8_chars'.tr() : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _confirmCtrl,
            obscureText: !_visible,
            decoration: InputDecoration(
              labelText: 'confirm_password'.tr(),
              border: const OutlineInputBorder(),
            ),
            validator: (v) =>
                v != _passwordCtrl.text ? 'passwords_not_match'.tr() : null,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _saving ? null : _submit,
            child: _saving
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text('set_password_continue'.tr()),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            icon: const Icon(Icons.restore, size: 16),
            label: Text('restore_from_backup'.tr()),
            onPressed: () => setState(() => _restoreMode = true),
          ),
        ],
      ),
    );
  }

  Widget _buildRestoreForm(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final fileName = _backupPath?.split(RegExp(r'[/\\]')).last;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.restore, size: 56),
        const SizedBox(height: 16),
        Text(
          'restore_title'.tr(),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'restore_subtitle'.tr(),
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          icon: const Icon(Icons.folder_open_outlined, size: 18),
          label: Text(
            fileName ?? 'select_backup_file'.tr(),
            overflow: TextOverflow.ellipsis,
          ),
          onPressed: _pickFile,
          style: OutlinedButton.styleFrom(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          ),
        ),
        if (_backupPath != null) ...[
          const SizedBox(height: 4),
          Text(
            _backupPath!,
            style: TextStyle(fontSize: 10, color: cs.outline),
            overflow: TextOverflow.ellipsis,
          ),
        ],
        const SizedBox(height: 12),
        TextField(
          controller: _restorePasswordCtrl,
          obscureText: !_restoreVisible,
          decoration: InputDecoration(
            labelText: 'master_password'.tr(),
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: Icon(
                _restoreVisible ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () => setState(() => _restoreVisible = !_restoreVisible),
            ),
          ),
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: _restoring ? null : _restore,
          child: _restoring
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text('restore_open'.tr()),
        ),
        const SizedBox(height: 16),
        TextButton.icon(
          icon: const Icon(Icons.arrow_back, size: 16),
          label: Text('back_to_setup'.tr()),
          onPressed: () => setState(() {
            _restoreMode = false;
            _backupPath = null;
            _restorePasswordCtrl.clear();
          }),
        ),
      ],
    );
  }
}
