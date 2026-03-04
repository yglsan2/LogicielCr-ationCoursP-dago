import 'package:flutter/material.dart';
import '../models/course.dart';
import '../core/theme.dart';
import 'block_tile.dart';

/// Carte d'une partie avec titre éditable et liste de blocs réordonnables.
class PartCard extends StatelessWidget {
  const PartCard({
    super.key,
    required this.part,
    required this.onTitleChanged,
    required this.onDelete,
    required this.onAddBlock,
    required this.onBlockPatch,
    required this.onBlockDelete,
    required this.onBlockReorder,
  });

  final Part part;
  final ValueChanged<String> onTitleChanged;
  final VoidCallback onDelete;
  final VoidCallback onAddBlock;
  final void Function(int blockId, Map<String, dynamic> patch) onBlockPatch;
  final void Function(int blockId) onBlockDelete;
  final void Function(int oldIndex, int newIndex) onBlockReorder;

  @override
  Widget build(BuildContext context) {
    final blocks = part.blocks ?? [];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.drag_handle, color: Colors.grey.shade500),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Titre de la partie',
                      isDense: true,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                    ),
                    controller: TextEditingController(text: part.title),
                    onSubmitted: (v) => onTitleChanged(v.trim().isEmpty ? part.title : v),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Supprimer cette partie ?'),
                        content: const Text(
                          'Tous les blocs qu\'elle contient seront aussi supprimés.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Annuler'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              onDelete();
                            },
                            child: const Text('Supprimer', style: TextStyle(color: AppTheme.error)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            ReorderableListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              onReorder: onBlockReorder,
              children: [
                for (int i = 0; i < blocks.length; i++)
                  ReorderableDelayedDragStartListener(
                    key: ValueKey(blocks[i].id),
                    index: i,
                    child: BlockTile(
                      block: blocks[i],
                      onPatch: (patch) => onBlockPatch(blocks[i].id, patch),
                      onDelete: () => onBlockDelete(blocks[i].id),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: onAddBlock,
              icon: const Icon(Icons.add_rounded, size: 20),
              label: const Text('Ajouter un bloc'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primary,
                side: const BorderSide(color: AppTheme.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
