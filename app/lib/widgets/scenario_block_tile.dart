import 'package:flutter/material.dart';
import '../models/course.dart';
import '../core/theme.dart';

/// Bloc Scénario incident ou sécurité : cas concret avec choix d'actions (TSSR, Admin Réseau, DevOps).
class ScenarioBlockTile extends StatefulWidget {
  const ScenarioBlockTile({
    super.key,
    required this.block,
    required this.onPatch,
  });

  final Block block;
  final void Function(Map<String, dynamic> patch) onPatch;

  @override
  State<ScenarioBlockTile> createState() => _ScenarioBlockTileState();
}

class _ScenarioBlockTileState extends State<ScenarioBlockTile> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  List<dynamic> get _choices {
    final c = widget.block.content['choices'];
    if (c is List && c.isNotEmpty) return c;
    return [
      {'text': '', 'feedback': '', 'is_correct': true},
      {'text': '', 'feedback': '', 'is_correct': false},
    ];
  }

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.block.content['title'] as String? ?? '');
    _descriptionController = TextEditingController(text: widget.block.content['description'] as String? ?? '');
  }

  @override
  void didUpdateWidget(covariant ScenarioBlockTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.block.content != widget.block.content) {
      _titleController.text = widget.block.content['title'] as String? ?? '';
      _descriptionController.text = widget.block.content['description'] as String? ?? '';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveChoice(int index, {String? text, String? feedback, bool? isCorrect}) {
    final list = _choices.map((e) => e is Map ? Map<String, dynamic>.from(e) : <String, dynamic>{}).toList();
    while (list.length <= index) list.add({'text': '', 'feedback': '', 'is_correct': false});
    if (text != null) list[index]['text'] = text;
    if (feedback != null) list[index]['feedback'] = feedback;
    if (isCorrect != null) list[index]['is_correct'] = isCorrect;
    widget.onPatch({'content': {...widget.block.content, 'choices': list}});
  }

  void _addChoice() {
    final list = _choices.map((e) => e is Map ? Map<String, dynamic>.from(e) : <String, dynamic>{}).toList();
    list.add({'text': '', 'feedback': '', 'is_correct': false});
    widget.onPatch({'content': {...widget.block.content, 'choices': list}});
    setState(() {});
  }

  void _removeChoice(int index) {
    final list = _choices.map((e) => e is Map ? Map<String, dynamic>.from(e) : <String, dynamic>{}).toList();
    if (list.length <= 1) return;
    list.removeAt(index);
    widget.onPatch({'content': {...widget.block.content, 'choices': list}});
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _titleController,
          decoration: const InputDecoration(
            labelText: 'Titre du scénario',
            hintText: 'Ex. : Email suspect reçu par un utilisateur',
            isDense: true,
            border: InputBorder.none,
          ),
          onChanged: (v) => widget.onPatch({'content': {...widget.block.content, 'title': v}}),
          onSubmitted: (v) => widget.onPatch({'content': {...widget.block.content, 'title': v}}),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            labelText: 'Description du cas',
            hintText: 'Décrivez la situation (incident, alerte, demande utilisateur...)',
            isDense: true,
            border: InputBorder.none,
            alignLabelWithHint: true,
          ),
          maxLines: 3,
          onChanged: (v) => widget.onPatch({'content': {...widget.block.content, 'description': v}}),
        ),
        const SizedBox(height: 12),
        Text(
          'Choix d\'actions (une ou plusieurs bonnes réponses possibles)',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.onSurfaceVariant),
        ),
        const SizedBox(height: 8),
        ..._choices.asMap().entries.map((e) {
          final i = e.key;
          final ch = e.value is Map ? e.value as Map : <String, dynamic>{};
          final text = ch['text']?.toString() ?? '';
          final feedback = ch['feedback']?.toString() ?? '';
          final isCorrect = ch['is_correct'] == true;
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            color: AppTheme.surfaceVariant.withValues(alpha: 0.5),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(
                        isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                        size: 20,
                        color: isCorrect ? AppTheme.success : Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Action ${i + 1}',
                            isDense: true,
                            border: InputBorder.none,
                          ),
                          controller: TextEditingController(text: text),
                          onChanged: (v) => _saveChoice(i, text: v),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, size: 20),
                        onPressed: _choices.length > 1 ? () => _removeChoice(i) : null,
                      ),
                    ],
                  ),
                  TextField(
                    decoration: const InputDecoration(
                      hintText: 'Feedback (explication si l\'apprenant choisit cette action)',
                      isDense: true,
                      border: InputBorder.none,
                    ),
                    controller: TextEditingController(text: feedback),
                    maxLines: 2,
                    onChanged: (v) => _saveChoice(i, feedback: v),
                  ),
                  Row(
                    children: [
                      Text('Bonne action ?', style: TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant)),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('Oui'),
                        selected: isCorrect,
                        onSelected: (v) => _saveChoice(i, isCorrect: true),
                      ),
                      const SizedBox(width: 4),
                      ChoiceChip(
                        label: const Text('Non'),
                        selected: !isCorrect,
                        onSelected: (v) => _saveChoice(i, isCorrect: false),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
        OutlinedButton.icon(
          onPressed: _addChoice,
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text('Ajouter un choix'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.primary,
            side: const BorderSide(color: AppTheme.primary),
          ),
        ),
      ],
    );
  }
}
