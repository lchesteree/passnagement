import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../service/storage_service.dart';
import '../model/password_entry.dart';
import '../model/password_group.dart';

class AddEntryPage extends StatefulWidget {
  const AddEntryPage({super.key, this.initialGroup});

  final String? initialGroup;

  @override
  State<AddEntryPage> createState() => _AddEntryPageState();
}

class _AddEntryPageState extends State<AddEntryPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _urlCtrl = TextEditingController();
  final _serverCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _newGroupCtrl = TextEditingController();

  String? _selectedGroup;
  bool _passwordVisible = false;
  bool _saving = false;

  List<String> get _existingGroups =>
      StorageService.getAll().map((g) => g.name).toList();

  bool get _isNewGroup => _selectedGroup == '__new__';

  @override
  void initState() {
    super.initState();
    _selectedGroup = widget.initialGroup;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _urlCtrl.dispose();
    _serverCtrl.dispose();
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _newGroupCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final groupName =
        _isNewGroup ? _newGroupCtrl.text.trim() : _selectedGroup!;

    final entry = PasswordEntry(
      name: _nameCtrl.text.trim(),
      url: _urlCtrl.text.trim(),
      server: _serverCtrl.text.trim().isEmpty ? null : _serverCtrl.text.trim(),
      username: _usernameCtrl.text.trim(),
      password: _passwordCtrl.text,
    );

    final groups = StorageService.getAll();
    final groupIndex = groups.indexWhere((g) => g.name == groupName);

    if (groupIndex >= 0) {
      await StorageService.addEntryToGroup(groupIndex, entry);
    } else {
      await StorageService.addGroup(
        PasswordGroup(name: groupName, entries: [entry]),
      );
    }

    if (mounted) Navigator.pop(context);
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
            child: Form(
              key: _formKey,
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                children: [
                  _sectionLabel(context, 'group'.tr()),
                  _buildGroupCard(context, cs),
                  const SizedBox(height: 14),
                  _sectionLabel(context, 'details'.tr()),
                  _buildDetailsCard(cs),
                  const SizedBox(height: 14),
                  _sectionLabel(context, 'credentials'.tr()),
                  _buildCredentialsCard(cs),
                ],
              ),
            ),
          ),
          _buildBottomBar(cs),
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
            child: const Icon(Icons.add, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Text(
            'add_entry'.tr(),
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

  Widget _sectionLabel(BuildContext context, String title) {
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

  Widget _buildGroupCard(BuildContext context, ColorScheme cs) {
    final groups = _existingGroups;
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: cs.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.folder_outlined, size: 16, color: cs.outline),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedGroup,
                    decoration: InputDecoration(
                      labelText: 'select_group'.tr(),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      isDense: true,
                    ),
                    style: TextStyle(fontSize: 13, color: cs.onSurface),
                    isExpanded: true,
                    items: [
                      ...groups.map(
                        (g) => DropdownMenuItem(
                          value: g,
                          child:
                              Text(g, style: const TextStyle(fontSize: 13)),
                        ),
                      ),
                      DropdownMenuItem(
                        value: '__new__',
                        child: Text('new_group'.tr(),
                            style: const TextStyle(fontSize: 13)),
                      ),
                    ],
                    onChanged: (v) => setState(() => _selectedGroup = v),
                    validator: (v) => v == null ? 'select_a_group'.tr() : null,
                  ),
                ),
              ],
            ),
            if (_isNewGroup) ...[
              Divider(height: 1, color: cs.outlineVariant.withAlpha(80)),
              _formFieldRow(
                controller: _newGroupCtrl,
                label: 'new_group_name'.tr(),
                icon: Icons.create_new_folder_outlined,
                cs: cs,
                autofocus: true,
                validator: (v) =>
                    _isNewGroup && (v == null || v.trim().isEmpty)
                        ? 'required'.tr()
                        : null,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard(ColorScheme cs) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: cs.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Column(
          children: [
            _formFieldRow(
              controller: _nameCtrl,
              label: 'name'.tr(),
              icon: Icons.label_outline,
              cs: cs,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'required'.tr() : null,
            ),
            Divider(height: 1, color: cs.outlineVariant.withAlpha(80)),
            _formFieldRow(
              controller: _urlCtrl,
              label: 'url'.tr(),
              icon: Icons.link,
              cs: cs,
              keyboardType: TextInputType.url,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'required'.tr() : null,
            ),
            Divider(height: 1, color: cs.outlineVariant.withAlpha(80)),
            _formFieldRow(
              controller: _serverCtrl,
              label: 'server_optional'.tr(),
              icon: Icons.dns_outlined,
              cs: cs,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCredentialsCard(ColorScheme cs) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: cs.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Column(
          children: [
            _formFieldRow(
              controller: _usernameCtrl,
              label: 'username'.tr(),
              icon: Icons.person_outline,
              cs: cs,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'required'.tr() : null,
            ),
            Divider(height: 1, color: cs.outlineVariant.withAlpha(80)),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(Icons.lock_outline, size: 16, color: cs.outline),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _passwordCtrl,
                      obscureText: !_passwordVisible,
                      decoration: InputDecoration(
                        labelText: 'password'.tr(),
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 8),
                        isDense: true,
                        suffixIcon: IconButton(
                          padding: EdgeInsets.zero,
                          iconSize: 16,
                          icon: Icon(
                            _passwordVisible
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: cs.outline,
                          ),
                          onPressed: () => setState(
                              () => _passwordVisible = !_passwordVisible),
                        ),
                      ),
                      style: const TextStyle(fontSize: 13),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'required'.tr() : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _formFieldRow({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required ColorScheme cs,
    bool autofocus = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: cs.outline),
          const SizedBox(width: 10),
          Expanded(
            child: TextFormField(
              controller: controller,
              autofocus: autofocus,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                labelText: label,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                isDense: true,
              ),
              style: const TextStyle(fontSize: 13),
              validator: validator,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(top: BorderSide(color: cs.outlineVariant, width: 0.5)),
      ),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: _saving ? null : _save,
          icon: _saving
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.save_outlined, size: 18),
          label: Text('save_entry'.tr()),
        ),
      ),
    );
  }
}
