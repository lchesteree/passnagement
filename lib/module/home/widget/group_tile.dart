import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../service/storage_service.dart';
import '../model/password_group.dart';
import '../page/add_entry_page.dart';
import 'entry_tile.dart';

class GroupTile extends StatelessWidget {
  const GroupTile({super.key, required this.groupIndex, required this.group});

  final int groupIndex;
  final PasswordGroup group;

  Future<void> _showContextMenu(BuildContext context, Offset position) async {
    final overlay =
        Overlay.of(context).context.findRenderObject()! as RenderBox;
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
    if (result == 'delete' && context.mounted) _deleteGroup(context);
  }

  Future<void> _deleteGroup(BuildContext context) async {
    if (group.entries.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('delete_entries_first'.tr()),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('delete_group'.tr()),
        content: Text('delete_group_confirm'.tr(namedArgs: {'name': group.name})),
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
      await StorageService.deleteGroup(groupIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onSecondaryTapUp: (d) => _showContextMenu(context, d.globalPosition),
      // onLongPressStart: (d) => _showContextMenu(context, d.globalPosition),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        elevation: 0,
        color: cs.surfaceContainerLow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ExpansionTile(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          collapsedShape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          leading: CircleAvatar(
            radius: 15,
            backgroundColor: cs.primaryContainer,
            child: Icon(Icons.folder_outlined,
                size: 15, color: cs.onPrimaryContainer),
          ),
          title: Text(
            group.name,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          children: [
            ...group.entries.asMap().entries.map(
                  (e) => EntryTile(
                    groupIndex: groupIndex,
                    entryIndex: e.key,
                    entry: e.value,
                  ),
                ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}
