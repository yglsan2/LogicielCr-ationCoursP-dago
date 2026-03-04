import 'package:flutter/material.dart';
import '../models/course.dart';
import '../core/theme.dart';

/// Bloc Tableau : comparaisons, tables de vérité, références.
class TableBlockTile extends StatelessWidget {
  const TableBlockTile({
    super.key,
    required this.block,
    required this.onPatch,
  });

  final Block block;
  final void Function(Map<String, dynamic> patch) onPatch;

  List<String> _headers() {
    final h = block.content['headers'];
    if (h is List) return h.map((e) => e.toString()).toList();
    return ['Colonne 1', 'Colonne 2'];
  }

  List<List<String>> _rows() {
    final r = block.content['rows'];
    if (r is! List) return [['', '']];
    return r.map((row) {
      if (row is List) return row.map((e) => e.toString()).toList();
      return [row.toString()];
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final headers = _headers();
    final rows = _rows();
    final cols = headers.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Table(
            border: TableBorder.all(color: Colors.grey.shade300),
            columnWidths: {for (int i = 0; i < cols; i++) i: const FlexColumnWidth(1)},
            children: [
              TableRow(
                decoration: BoxDecoration(color: AppTheme.surfaceVariant),
                children: [
                  for (int c = 0; c < cols; c++)
                    _Cell(
                      value: c < headers.length ? headers[c] : '',
                      onChanged: (v) {
                        final h = List<String>.from(headers);
                        while (h.length <= c) h.add('');
                        h[c] = v;
                        onPatch({'content': {...block.content, 'headers': h}});
                      },
                    ),
                ],
              ),
              for (int r = 0; r < rows.length; r++)
                TableRow(
                  children: [
                    for (int c = 0; c < cols; c++)
                      _Cell(
                        value: r < rows.length && c < rows[r].length ? rows[r][c] : '',
                        onChanged: (v) {
                          final newRows = rows.map((e) => List<String>.from(e)).toList();
                          while (newRows.length <= r) newRows.add(List.filled(cols, ''));
                          while (newRows[r].length <= c) newRows[r].add('');
                          newRows[r][c] = v;
                          onPatch({'content': {...block.content, 'rows': newRows}});
                        },
                      ),
                  ],
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            TextButton.icon(
              onPressed: () {
                final newRows = rows.map((e) => List<String>.from(e)).toList();
                newRows.add(List.filled(cols, ''));
                onPatch({'content': {...block.content, 'rows': newRows}});
              },
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Ligne'),
            ),
            TextButton.icon(
              onPressed: () {
                final h = List<String>.from(headers)..add('');
                final newRows = rows.map((e) => List<String>.from(e)..add('')).toList();
                onPatch({'content': {...block.content, 'headers': h, 'rows': newRows}});
              },
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Colonne'),
            ),
          ],
        ),
      ],
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: TextField(
        controller: TextEditingController(text: value),
        onChanged: onChanged,
        decoration: const InputDecoration(
          isDense: true,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 6),
        ),
        style: const TextStyle(fontSize: 13),
      ),
    );
  }
}
