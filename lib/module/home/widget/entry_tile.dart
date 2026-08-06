import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../service/storage_service.dart';
import '../model/password_entry.dart';
import 'info_row.dart';

class EntryTile extends StatelessWidget {
  const EntryTile({
    super.key,
    required this.groupIndex,
    required this.entryIndex,
    required this.entry,
  });

  final int groupIndex;
  final int entryIndex;
  final PasswordEntry entry;

  Future<void> _showContextMenu(BuildContext context, Offset position) async {
    final overlay = Overlay.of(context).context.findRenderObject()! as RenderBox;
    final result = await showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromLTWH(position.dx, position.dy, 1, 1),
        Offset.zero & overlay.size,
      ),
      items: [
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              const Icon(Icons.delete_outline, color: Colors.red, size: 18),
              const SizedBox(width: 8),
              Text('delete'.tr(), style: const TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
    if (result == 'delete' && context.mounted) _confirmDelete(context);
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('delete_entry'.tr()),
        content: Text('delete_entry_confirm'.tr(namedArgs: {'name': entry.name})),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('delete'.tr(), style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (ok == true) {
      await StorageService.deleteEntryFromGroup(groupIndex, entryIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onSecondaryTapUp: (d) => _showContextMenu(context, d.globalPosition),
      onLongPressStart: (d) => _showContextMenu(context, d.globalPosition),
      child: Container(
        margin: const EdgeInsets.only(left: 14, right: 10, top: 2, bottom: 2),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: cs.outlineVariant.withAlpha(80)),
        ),
        child: ExpansionTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          leading: Icon(Icons.lock_outline, size: 16, color: cs.primary),
          title: Text(
            entry.name,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
          tilePadding: const EdgeInsets.only(left: 12, right: 12),
          childrenPadding: const EdgeInsets.only(bottom: 4),
          children: [
            const Divider(height: 1, indent: 12, endIndent: 12),
            InfoRow(label: 'url'.tr(), value: entry.url, copyable: true),
            if (entry.server?.isNotEmpty == true)
              InfoRow(label: 'server'.tr(), value: entry.server!, copyable: true),
            InfoRow(label: 'username'.tr(), value: entry.username, copyable: true),
            InfoRow(
              label: 'password'.tr(),
              value: entry.password,
              copyable: true,
              obscure: true,
            ),
          ],
        ),
      ),
    );
  }
}
