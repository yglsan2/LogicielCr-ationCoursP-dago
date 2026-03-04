import 'package:flutter/material.dart';
import '../models/course.dart';
import '../core/theme.dart';

/// Bloc Algorithme / Étapes : pseudo-code, étapes numérotées, trace d'exécution simulée.
class AlgorithmBlockTile extends StatefulWidget {
  const AlgorithmBlockTile({
    super.key,
    required this.block,
    required this.onPatch,
  });

  final Block block;
  final void Function(Map<String, dynamic> patch) onPatch;

  @override
  State<AlgorithmBlockTile> createState() => _AlgorithmBlockTileState();
}

class _AlgorithmBlockTileState extends State<AlgorithmBlockTile> {
  late TextEditingController _traceController;
  List<String> get _steps {
    final s = widget.block.content['steps'];
    if (s is List) return s.map((e) => e.toString()).toList();
    return ['Étape 1', 'Étape 2'];
  }

  @override
  void initState() {
    super.initState();
    _traceController = TextEditingController(
      text: widget.block.content['trace'] as String? ?? '',
    );
  }

  @override
  void didUpdateWidget(covariant AlgorithmBlockTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.block.content != widget.block.content) {
      _traceController.text = widget.block.content['trace'] as String? ?? '';
    }
  }

  @override
  void dispose() {
    _traceController.dispose();
    super.dispose();
  }

  void _saveSteps(List<String> steps) {
    widget.onPatch({'content': {...widget.block.content, 'steps': steps}});
  }

  void _saveTrace() {
    widget.onPatch({'content': {...widget.block.content, 'trace': _traceController.text}});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Étapes (pseudo-code ou algorithme)',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.onSurfaceVariant),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceVariant.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ..._steps.asMap().entries.map((e) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${e.key + 1}.',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: TextEditingController(text: e.value),
                          onChanged: (v) {
                            final s = List<String>.from(_steps);
                            while (s.length <= e.key) s.add('');
                            s[e.key] = v;
                            _saveSteps(s);
                          },
                          decoration: const InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () => _saveSteps([..._steps, '']),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Ajouter une étape'),
                  ),
                  if (_steps.length > 1)
                    TextButton.icon(
                      onPressed: () {
                        final s = List<String>.from(_steps)..removeLast();
                        _saveSteps(s);
                      },
                      icon: const Icon(Icons.remove_rounded, size: 18),
                      label: const Text('Retirer'),
                      style: TextButton.styleFrom(foregroundColor: AppTheme.onSurfaceVariant),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Trace d\'exécution (optionnel)',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.onSurfaceVariant),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade700),
          ),
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: _traceController,
            onChanged: (_) => _saveTrace(),
            maxLines: 5,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              color: Color(0xFFD4D4D4),
              height: 1.4,
            ),
            decoration: const InputDecoration(
              hintText: 'Résultat / trace simulée après exécution...',
              hintStyle: TextStyle(color: Color(0xFF6A737D)),
              isDense: true,
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }
}
