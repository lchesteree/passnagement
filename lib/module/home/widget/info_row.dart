import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InfoRow extends StatefulWidget {
  const InfoRow({
    required this.label,
    required this.value,
    this.copyable = false,
    this.obscure = false,
  });

  final String label;
  final String value;
  final bool copyable;
  final bool obscure;

  @override
  State<InfoRow> createState() => InfoRowState();
}

class InfoRowState extends State<InfoRow> {
  bool _revealed = false;

  void _copy() {
    Clipboard.setData(ClipboardData(text: widget.value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('copied'.tr(namedArgs: {'label': widget.label})),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final display = widget.obscure && !_revealed ? '••••••••' : widget.value;
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: cs.outline,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  display,
                  style: TextStyle(
                    fontSize: 12,
                    color: cs.onSurface,
                    fontFamily: widget.obscure ? 'monospace' : null,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (widget.copyable) ...[
            if (widget.obscure)
              SizedBox(
                width: 28,
                height: 28,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  iconSize: 15,
                  icon: Icon(
                    _revealed
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: cs.outline,
                  ),
                  onPressed: () => setState(() => _revealed = !_revealed),
                ),
              ),
            SizedBox(
              width: 28,
              height: 28,
              child: IconButton(
                padding: EdgeInsets.zero,
                iconSize: 15,
                icon: Icon(Icons.copy_outlined, color: cs.outline),
                onPressed: _copy,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
