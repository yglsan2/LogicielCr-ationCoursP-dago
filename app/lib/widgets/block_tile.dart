import 'package:flutter/material.dart';
import '../models/course.dart';
import '../core/theme.dart';
import 'code_block_tile.dart';
import 'terminal_block_tile.dart';
import 'scenario_block_tile.dart';
import 'table_block_tile.dart';
import 'algorithm_block_tile.dart';
import 'term_block_tile.dart';
import 'whiteboard_block_tile.dart';
import 'music_notation_block_tile.dart';

/// Une ligne de bloc avec édition inline et suppression.
class BlockTile extends StatelessWidget {
  const BlockTile({
    super.key,
    required this.block,
    required this.onPatch,
    required this.onDelete,
  });

  final Block block;
  final void Function(Map<String, dynamic> patch) onPatch;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.drag_handle, color: Colors.grey.shade500, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: _buildContent(context),
          ),
          IconButton(
            iconSize: 20,
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Supprimer ce bloc ?'),
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
    );
  }

  static Color _highlightColor(String key) {
    switch (key) {
      case 'green': return AppTheme.highlighterGreen;
      case 'pink': return AppTheme.highlighterPink;
      case 'blue': return AppTheme.highlighterBlue;
      case 'orange': return AppTheme.highlighterOrange;
      default: return AppTheme.highlighterYellow;
    }
  }

  Widget _buildContent(BuildContext context) {
    switch (block.blockType) {
      case 'title':
        final text = block.content['text'] as String? ?? '';
        return TextField(
          decoration: const InputDecoration(
            hintText: 'Titre',
            isDense: true,
            border: InputBorder.none,
          ),
          controller: TextEditingController(text: text),
          style: Theme.of(context).textTheme.titleMedium,
          onSubmitted: (v) => onPatch({'content': {...block.content, 'text': v, 'level': block.content['level'] ?? 2}}),
        );
      case 'paragraph':
        final text = block.content['text'] as String? ?? '';
        return TextField(
          decoration: const InputDecoration(
            hintText: 'Paragraphe...',
            isDense: true,
            border: InputBorder.none,
            alignLabelWithHint: true,
          ),
          controller: TextEditingController(text: text),
          maxLines: 3,
          onSubmitted: (v) => onPatch({'content': {...block.content, 'text': v}}),
          onChanged: (v) => onPatch({'content': {...block.content, 'text': v}}),
        );
      case 'highlight':
        final text = block.content['text'] as String? ?? '';
        final colorKey = block.content['color'] as String? ?? 'yellow';
        final highlightColor = _highlightColor(colorKey);
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButton<String>(
              value: colorKey,
              isDense: true,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(value: 'yellow', child: Text('Jaune')),
                DropdownMenuItem(value: 'green', child: Text('Vert')),
                DropdownMenuItem(value: 'pink', child: Text('Rose')),
                DropdownMenuItem(value: 'blue', child: Text('Bleu')),
                DropdownMenuItem(value: 'orange', child: Text('Orange')),
              ],
              onChanged: (v) {
                if (v != null) onPatch({'content': {...block.content, 'color': v}});
              },
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: highlightColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Texte à surligner...',
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  controller: TextEditingController(text: text),
                  maxLines: 2,
                  onChanged: (v) => onPatch({'content': {...block.content, 'text': v}}),
                ),
              ),
            ),
          ],
        );
      case 'objective':
        final text = block.content['text'] as String? ?? '';
        return TextField(
          decoration: const InputDecoration(
            hintText: 'Objectif pédagogique...',
            isDense: true,
            border: InputBorder.none,
          ),
          controller: TextEditingController(text: text),
          onSubmitted: (v) => onPatch({'content': {...block.content, 'text': v}}),
        );
      case 'qcu':
        final question = block.content['question'] as String? ?? '';
        final options = List<String>.from(block.content['options'] as List? ?? ['', '']);
        final correctIndex = block.content['correct_index'] as int? ?? 0;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: 'Question (une seule bonne réponse)',
                isDense: true,
                border: InputBorder.none,
              ),
              controller: TextEditingController(text: question),
              onSubmitted: (v) => onPatch({'content': {...block.content, 'question': v}}),
            ),
            ...options.asMap().entries.map((e) {
              final isCorrect = e.key == correctIndex;
              return Row(
                children: [
                  Icon(
                    isCorrect ? Icons.check_circle : Icons.radio_button_unchecked,
                    size: 20,
                    color: isCorrect ? AppTheme.success : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Réponse ${e.key + 1}',
                        isDense: true,
                        border: InputBorder.none,
                      ),
                      controller: TextEditingController(text: e.value),
                      onSubmitted: (v) {
                        final newOpts = List<String>.from(options);
                        newOpts[e.key] = v;
                        onPatch({'content': {...block.content, 'options': newOpts}});
                      },
                    ),
                  ),
                ],
              );
            }),
          ],
        );
      case 'qcm':
        final question = block.content['question'] as String? ?? '';
        final options = List<String>.from(block.content['options'] as List? ?? ['', '']);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: 'Question (plusieurs bonnes réponses)',
                isDense: true,
                border: InputBorder.none,
              ),
              controller: TextEditingController(text: question),
              onSubmitted: (v) => onPatch({'content': {...block.content, 'question': v}}),
            ),
            ...options.asMap().entries.map((e) {
              return Row(
                children: [
                  const Icon(Icons.check_box_outlined, size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Réponse ${e.key + 1}',
                        isDense: true,
                        border: InputBorder.none,
                      ),
                      controller: TextEditingController(text: e.value),
                      onSubmitted: (v) {
                        final newOpts = List<String>.from(options);
                        newOpts[e.key] = v;
                        onPatch({'content': {...block.content, 'options': newOpts}});
                      },
                    ),
                  ),
                ],
              );
            }),
          ],
        );
      case 'image':
      case 'video':
      case 'audio':
        final url = block.content['url'] as String? ?? '';
        final label = block.blockType == 'image'
            ? 'URL de l\'image'
            : block.blockType == 'video'
                ? 'URL de la vidéo'
                : 'URL de l\'audio';
        return TextField(
          decoration: InputDecoration(
            hintText: label,
            isDense: true,
            border: InputBorder.none,
          ),
          controller: TextEditingController(text: url),
          onSubmitted: (v) => onPatch({'content': {...block.content, 'url': v, 'alt': block.content['alt'] ?? ''}}),
        );
      case 'list':
        final items = List<String>.from(block.content['items'] as List? ?? ['']);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: items.asMap().entries.map((e) {
            return Row(
              children: [
                const Text('• ', style: TextStyle(fontSize: 16)),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Élément ${e.key + 1}',
                      isDense: true,
                      border: InputBorder.none,
                    ),
                    controller: TextEditingController(text: e.value),
                    onSubmitted: (v) {
                      final newItems = List<String>.from(items);
                      newItems[e.key] = v;
                      onPatch({'content': {'items': newItems}});
                    },
                  ),
                ),
              ],
            );
          }).toList(),
        );
      case 'ordering':
        final question = block.content['question'] as String? ?? '';
        final items = List<String>.from(block.content['items'] as List? ?? ['', '']);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: 'Consigne (ex. Remettez dans l\'ordre)',
                isDense: true,
                border: InputBorder.none,
              ),
              controller: TextEditingController(text: question),
              onSubmitted: (v) => onPatch({'content': {...block.content, 'question': v}}),
            ),
            Text('Éléments à ordonner :', style: TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant)),
            ...items.asMap().entries.map((e) => TextField(
                  decoration: InputDecoration(hintText: 'Élément ${e.key + 1}', isDense: true, border: InputBorder.none),
                  controller: TextEditingController(text: e.value),
                  onSubmitted: (v) {
                    final newItems = List<String>.from(items);
                    newItems[e.key] = v;
                    onPatch({'content': {...block.content, 'items': newItems}});
                  },
                )),
          ],
        );
      case 'numeric':
        final question = block.content['question'] as String? ?? '';
        final answer = block.content['answer']?.toString() ?? '';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: 'Question (réponse numérique)',
                isDense: true,
                border: InputBorder.none,
              ),
              controller: TextEditingController(text: question),
              onSubmitted: (v) => onPatch({'content': {...block.content, 'question': v}}),
            ),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Réponse attendue (nombre)',
                isDense: true,
                border: InputBorder.none,
              ),
              controller: TextEditingController(text: answer),
              keyboardType: TextInputType.number,
              onSubmitted: (v) => onPatch({'content': {...block.content, 'answer': v}}),
            ),
          ],
        );
      case 'code':
        return CodeBlockTile(
          block: block,
          onPatch: onPatch,
        );
      case 'terminal':
        return TerminalBlockTile(
          block: block,
          onPatch: onPatch,
        );
      case 'scenario':
        return ScenarioBlockTile(
          block: block,
          onPatch: onPatch,
        );
      case 'table':
        return TableBlockTile(block: block, onPatch: onPatch);
      case 'algorithm':
        return AlgorithmBlockTile(block: block, onPatch: onPatch);
      case 'term':
        return TermBlockTile(block: block, onPatch: onPatch);
      case 'whiteboard':
        return WhiteboardBlockTile(block: block, onPatch: onPatch);
      case 'music_notation':
        return MusicNotationBlockTile(block: block, onPatch: onPatch);
      case 'fill_blank':
      case 'categorize':
        final text = block.content['text'] ?? block.content['question'] ?? '';
        return TextField(
          decoration: InputDecoration(
            hintText: block.blockType == 'fill_blank' ? 'Texte avec [...] pour les trous' : 'Consigne',
            isDense: true,
            border: InputBorder.none,
          ),
          controller: TextEditingController(text: text.toString()),
          maxLines: 2,
          onSubmitted: (v) => onPatch({
            'content': {...block.content, block.blockType == 'fill_blank' ? 'text' : 'question': v},
          }),
        );
      default:
        return Text(
          block.blockType,
          style: TextStyle(color: AppTheme.onSurfaceVariant),
        );
    }
  }
}
