import 'package:flutter/material.dart';
import '../models/course.dart';
import '../core/theme.dart';

/// Bloc Terme / Définition : glossaire, vocabulaire technique (flashcard-style).
class TermBlockTile extends StatelessWidget {
  const TermBlockTile({
    super.key,
    required this.block,
    required this.onPatch,
  });

  final Block block;
  final void Function(Map<String, dynamic> patch) onPatch;

  List<Map<String, String>> _items() {
    final i = block.content['items'];
    if (i is! List) return [{'term': '', 'definition': ''}];
    return i.map((e) {
      if (e is Map) return {'term': (e['term'] ?? '').toString(), 'definition': (e['definition'] ?? '').toString()};
      return {'term': e.toString(), 'definition': ''};
    }).toList();
  }

  void _saveItems(List<Map<String, String>> items) {
    onPatch({'content': {...block.content, 'items': items}});
  }

  @override
  Widget build(BuildContext context) {
    final items = _items();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...items.asMap().entries.map((e) {
          final i = e.key;
          final term = e.value['term'] ?? '';
          final definition = e.value['definition'] ?? '';
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: TextEditingController(text: term),
                    onChanged: (v) {
                      final newItems = items.map((m) => Map<String, String>.from(m)).toList();
                      while (newItems.length <= i) newItems.add({'term': '', 'definition': ''});
                      newItems[i]['term'] = v;
                      _saveItems(newItems);
                    },
                    decoration: const InputDecoration(
                      labelText: 'Terme',
                      hintText: 'Ex. : Variable, API, TCP',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: TextEditingController(text: definition),
                    onChanged: (v) {
                      final newItems = items.map((m) => Map<String, String>.from(m)).toList();
                      while (newItems.length <= i) newItems.add({'term': '', 'definition': ''});
                      newItems[i]['definition'] = v;
                      _saveItems(newItems);
                    },
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Définition',
                      hintText: 'Explication courte',
                      isDense: true,
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                  ),
                  if (items.length > 1)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () {
                          final newItems = items.map((m) => Map<String, String>.from(m)).toList();
                          newItems.removeAt(i);
                          _saveItems(newItems);
                        },
                        icon: const Icon(Icons.delete_outline_rounded, size: 18),
                        label: const Text('Supprimer'),
                        style: TextButton.styleFrom(foregroundColor: AppTheme.error),
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
        OutlinedButton.icon(
          onPressed: () {
            _saveItems([...items, {'term': '', 'definition': ''}]);
          },
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text('Ajouter un terme'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.primary,
            side: const BorderSide(color: AppTheme.primary),
          ),
        ),
      ],
    );
  }
}
