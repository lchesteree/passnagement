import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../service/storage_service.dart';
import '../setting/setting.dart';
import 'model/password_group.dart';
import 'page/add_entry_page.dart';
import 'widget/group_tile.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surfaceContainerLowest,
      body: Column(
        children: [
          _buildHeader(context, cs),
          Expanded(
            child: ValueListenableBuilder<Box<PasswordGroup>>(
              valueListenable: StorageService.box.listenable(),
              builder: (context, box, _) {
                final groups = box.values.toList();
                if (groups.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lock_open_outlined, size: 48, color: cs.outlineVariant),
                        const SizedBox(height: 12),
                        Text(
                          'no_entries'.tr(),
                          style: TextStyle(color: cs.outline),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 4),
                  itemCount: groups.length,
                  itemBuilder: (context, index) =>
                      GroupTile(groupIndex: index, group: groups[index]),
                );
              },
            ),
          ),
          _buildBottomBar(context, cs),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme cs) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cs.primary, cs.tertiary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(40),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.lock_outline, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Text(
            title,
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

  Widget _buildBottomBar(BuildContext context, ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(top: BorderSide(color: cs.outlineVariant, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton.filledTonal(
            icon: const Icon(Icons.settings_outlined, size: 20),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingPage()),
            ),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddEntryPage()),
            ),
            icon: const Icon(Icons.add, size: 18),
            label: Text('add_entry'.tr()),
          ),
        ],
      ),
    );
  }
}
