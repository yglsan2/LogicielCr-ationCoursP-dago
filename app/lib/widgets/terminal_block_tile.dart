import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/course.dart';
import '../core/theme.dart';

/// Bloc Commande / Terminal : affichage type terminal (réseau, dev, DevOps).
class TerminalBlockTile extends StatefulWidget {
  const TerminalBlockTile({
    super.key,
    required this.block,
    required this.onPatch,
  });

  final Block block;
  final void Function(Map<String, dynamic> patch) onPatch;

  @override
  State<TerminalBlockTile> createState() => _TerminalBlockTileState();
}

class _TerminalBlockTileState extends State<TerminalBlockTile> {
  late TextEditingController _promptController;
  late TextEditingController _linesController;
  late TextEditingController _outputController;
  late TextEditingController _questionController;
  late TextEditingController _expectedController;

  List<String> get _linesFromContent {
    final l = widget.block.content['lines'];
    if (l is List) return l.map((e) => e.toString()).toList();
    return [''];
  }

  @override
  void initState() {
    super.initState();
    _promptController = TextEditingController(text: widget.block.content['prompt'] as String? ?? r'$ ');
    _linesController = TextEditingController(text: _linesFromContent.join('\n'));
    _outputController = TextEditingController(text: widget.block.content['output'] as String? ?? '');
    _questionController = TextEditingController(text: widget.block.content['question'] as String? ?? '');
    _expectedController = TextEditingController(text: widget.block.content['expected_command'] as String? ?? '');
  }

  @override
  void didUpdateWidget(covariant TerminalBlockTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.block.content != widget.block.content) {
      _linesController.text = _linesFromContent.join('\n');
      _outputController.text = widget.block.content['output'] as String? ?? '';
      _questionController.text = widget.block.content['question'] as String? ?? '';
      _expectedController.text = widget.block.content['expected_command'] as String? ?? '';
      _promptController.text = widget.block.content['prompt'] as String? ?? r'$ ';
    }
  }

  @override
  void dispose() {
    _promptController.dispose();
    _linesController.dispose();
    _outputController.dispose();
    _questionController.dispose();
    _expectedController.dispose();
    super.dispose();
  }

  void _saveLines() {
    final lines = _linesController.text.split('\n');
    if (lines.isEmpty) return;
    widget.onPatch({'content': {...widget.block.content, 'lines': lines}});
  }

  void _saveOutput() {
    widget.onPatch({'content': {...widget.block.content, 'output': _outputController.text}});
  }

  void _saveQuestion() {
    widget.onPatch({'content': {...widget.block.content, 'question': _questionController.text}});
  }

  void _saveExpected() {
    widget.onPatch({'content': {...widget.block.content, 'expected_command': _expectedController.text}});
  }

  void _savePrompt() {
    widget.onPatch({'content': {...widget.block.content, 'prompt': _promptController.text}});
  }

  @override
  Widget build(BuildContext context) {
    final prompt = _promptController.text;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _questionController,
          decoration: const InputDecoration(
            hintText: 'Question (ex. : Quelle commande pour afficher la table de routage ?)',
            isDense: true,
            border: InputBorder.none,
          ),
          onChanged: (_) => _saveQuestion(),
          onSubmitted: (_) => _saveQuestion(),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: TextField(
            controller: _expectedController,
            decoration: const InputDecoration(
              hintText: 'Réponse attendue (commande)',
              isDense: true,
              border: InputBorder.none,
            ),
            style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
            onChanged: (_) => _saveExpected(),
            onSubmitted: (_) => _saveExpected(),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            SizedBox(
              width: 48,
              child: TextField(
                controller: _promptController,
                decoration: const InputDecoration(hintText: r'$', isDense: true, border: InputBorder.none),
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                onSubmitted: (_) => _savePrompt(),
              ),
            ),
            Text('Terminal', style: TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant)),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.copy_rounded, size: 20),
              tooltip: 'Copier tout',
              onPressed: () {
                final text = '${prompt}${_linesController.text}';
                if (_outputController.text.isNotEmpty) {
                  Clipboard.setData(ClipboardData(text: '$text\n${_outputController.text}'));
                } else {
                  Clipboard.setData(ClipboardData(text: text));
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Copié'), duration: Duration(seconds: 1)),
                );
              },
            ),
          ],
        ),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade700),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _linesController,
                onChanged: (_) => _saveLines(),
                maxLines: null,
                minLines: 4,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  color: Color(0xFFD4D4D4),
                  height: 1.4,
                ),
                decoration: const InputDecoration(
                  hintText: 'Lignes de commande (une par ligne)...',
                  hintStyle: TextStyle(color: Color(0xFF6A737D)),
                  isDense: true,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                cursorColor: Colors.white,
              ),
              const SizedBox(height: 8),
              Text('Sortie simulée', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
              const SizedBox(height: 4),
              TextField(
                controller: _outputController,
                onChanged: (_) => _saveOutput(),
                maxLines: 4,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: Color(0xFFCE9178),
                ),
                decoration: const InputDecoration(
                  hintText: 'Résultat affiché après la commande...',
                  hintStyle: TextStyle(color: Color(0xFF6A737D)),
                  isDense: true,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
