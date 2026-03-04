import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import '../models/course.dart';
import '../core/theme.dart';

/// Langues supportées pour la coloration syntaxique.
const List<Map<String, String>> codeLanguages = [
  {'id': 'text', 'label': 'Sans coloration'},
  {'id': 'dart', 'label': 'Dart'},
  {'id': 'python', 'label': 'Python'},
  {'id': 'javascript', 'label': 'JavaScript'},
  {'id': 'html', 'label': 'HTML'},
  {'id': 'css', 'label': 'CSS'},
  {'id': 'sql', 'label': 'SQL'},
  {'id': 'json', 'label': 'JSON'},
  {'id': 'bash', 'label': 'Bash'},
  {'id': 'cpp', 'label': 'C++'},
  {'id': 'java', 'label': 'Java'},
];

/// Bloc de code : fond sombre, édition, copier, coloration optionnelle, « Résoudre virtuellement ».
class CodeBlockTile extends StatefulWidget {
  const CodeBlockTile({
    super.key,
    required this.block,
    required this.onPatch,
  });

  final Block block;
  final void Function(Map<String, dynamic> patch) onPatch;

  @override
  State<CodeBlockTile> createState() => _CodeBlockTileState();
}

class _CodeBlockTileState extends State<CodeBlockTile> {
  late TextEditingController _controller;
  late TextEditingController _resultController;
  late TextEditingController _actionLabelController;
  String get _code => _controller.text;
  String get _language => widget.block.content['language'] as String? ?? 'text';
  String get _mockOutput => widget.block.content['mock_output'] as String? ?? '';
  bool get _syntaxHighlight => widget.block.content['syntax_highlight'] as bool? ?? true;
  String get _actionLabel {
    final t = _actionLabelController.text.trim();
    return t.isEmpty
        ? (widget.block.content['action_label'] as String? ?? 'Résoudre virtuellement')
        : t;
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.block.content['code'] as String? ?? '',
    );
    _resultController = TextEditingController(text: _mockOutput);
    _actionLabelController = TextEditingController(
      text: widget.block.content['action_label'] as String? ?? 'Résoudre virtuellement',
    );
  }

  @override
  void didUpdateWidget(covariant CodeBlockTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.block.content != widget.block.content) {
      final newOutput = widget.block.content['mock_output'] as String? ?? '';
      if (newOutput != _resultController.text) _resultController.text = newOutput;
      final newLabel = widget.block.content['action_label'] as String? ?? 'Résoudre virtuellement';
      if (newLabel != _actionLabelController.text) _actionLabelController.text = newLabel;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _resultController.dispose();
    _actionLabelController.dispose();
    super.dispose();
  }

  void _save() {
    widget.onPatch({
      'content': {
        ...widget.block.content,
        'code': _controller.text,
        'language': _language,
        'mock_output': _resultController.text,
        'syntax_highlight': _syntaxHighlight,
      },
    });
  }

  void _saveResult() {
    widget.onPatch({
      'content': {...widget.block.content, 'mock_output': _resultController.text},
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Barre d’outils : langue, copier, coloration, libellé du bouton, bouton d’action
        Row(
          children: [
            DropdownButton<String>(
              value: _language,
              isDense: true,
              underline: const SizedBox(),
              items: codeLanguages
                  .map((e) => DropdownMenuItem(value: e['id'], child: Text(e['label']!)))
                  .toList(),
              onChanged: (v) {
                if (v == null) return;
                widget.onPatch({
                  'content': {...widget.block.content, 'language': v},
                });
              },
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.copy_rounded, size: 20),
              tooltip: 'Copier le code',
              onPressed: () {
                Clipboard.setData(ClipboardData(text: _code));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Code copié'), duration: Duration(seconds: 1)),
                );
              },
            ),
            IconButton(
              icon: Icon(
                _syntaxHighlight ? Icons.color_lens_rounded : Icons.color_lens_outlined,
                size: 20,
              ),
              tooltip: _syntaxHighlight ? 'Désactiver la coloration' : 'Activer la coloration',
              onPressed: () {
                widget.onPatch({
                  'content': {...widget.block.content, 'syntax_highlight': !_syntaxHighlight},
                });
              },
            ),
            const Spacer(),
            SizedBox(
              width: 180,
              child: TextField(
                controller: _actionLabelController,
                onSubmitted: (v) {
                  widget.onPatch({
                    'content': {...widget.block.content, 'action_label': v.trim().isEmpty ? 'Résoudre virtuellement' : v.trim()},
                  });
                },
                decoration: const InputDecoration(
                  hintText: 'Libellé du bouton',
                  isDense: true,
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
                style: const TextStyle(fontSize: 13),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton.icon(
                onPressed: () => _showVirtualRun(),
                icon: const Icon(Icons.play_circle_outline_rounded, size: 20),
                label: Text(_actionLabel),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.green.shade800,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        // Configuration des deux contenus : prompt de base + prompt d’arrivée
        Text(
          'Configuration des contenus',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppTheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '1. Contenu initial (prompt de base)',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    constraints: const BoxConstraints(minHeight: 100, maxHeight: 200),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade700),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: TextField(
                      controller: _controller,
                      onChanged: (_) => _save(),
                      onSubmitted: (_) => _save(),
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13,
                        color: Color(0xFFD4D4D4),
                        height: 1.4,
                      ),
                      maxLines: null,
                      minLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Ex. : 5*2, print("Hello"), algorithme...',
                        hintStyle: TextStyle(color: Color(0xFF6A737D)),
                        isDense: true,
                        contentPadding: EdgeInsets.all(12),
                        border: InputBorder.none,
                        filled: false,
                      ),
                      cursorColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '2. Résultat au clic (prompt d’arrivée)',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    constraints: const BoxConstraints(minHeight: 100, maxHeight: 200),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade900),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: TextField(
                      controller: _resultController,
                      onChanged: (_) => _saveResult(),
                      onSubmitted: (_) => _saveResult(),
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13,
                        color: Color(0xFF9CDCFE),
                        height: 1.4,
                      ),
                      maxLines: null,
                      minLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Ex. : 10\n>>> Hello, world!\nRésultat affiché instantanément au clic.',
                        hintStyle: TextStyle(color: Color(0xFF6A737D)),
                        isDense: true,
                        contentPadding: EdgeInsets.all(12),
                        border: InputBorder.none,
                        filled: false,
                      ),
                      cursorColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showVirtualRun() {
    final resultText = _resultController.text;
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620, maxHeight: 480),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.play_circle_rounded, color: Colors.green.shade300, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      _actionLabel,
                      style: const TextStyle(
                        color: Color(0xFFD4D4D4),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '— résultat instantané',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFF333333)),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Contenu initial (prompt de base)',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _code.isEmpty
                            ? const Text(
                                '(aucun contenu)',
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 12,
                                  color: Color(0xFF6A737D),
                                  height: 1.4,
                                ),
                              )
                            : (_syntaxHighlight && _language != 'text')
                                ? HighlightView(
                                    _code,
                                    language: _language,
                                    theme: atomOneDarkTheme,
                                    padding: EdgeInsets.zero,
                                    textStyle: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 12,
                                      height: 1.4,
                                    ),
                                  )
                                : SelectableText(
                                    _code,
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 12,
                                      color: Color(0xFFD4D4D4),
                                      height: 1.4,
                                    ),
                                  ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.arrow_downward_rounded, size: 16, color: Colors.green.shade400),
                          const SizedBox(width: 6),
                          Text(
                            'Après clic → prompt d’arrivée (pré-écrit)',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.green.shade300,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF252526),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.shade800),
                        ),
                        child: resultText.isEmpty
                            ? Text(
                                'Aucun résultat configuré. Remplissez le champ « 2. Résultat au clic » dans le bloc.',
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 12,
                                  color: Color(0xFF6A737D),
                                  height: 1.4,
                                ),
                              )
                            : SelectableText(
                                resultText,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 13,
                                  color: Color(0xFF9CDCFE),
                                  height: 1.4,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1, color: Color(0xFF333333)),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Fermer'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
