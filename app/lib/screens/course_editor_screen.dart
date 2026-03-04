import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../core/auth_provider.dart';
import '../core/local_courses_provider.dart';
import '../models/course.dart';
import '../widgets/part_card.dart';
import '../widgets/add_block_sheet.dart';

/// Éditeur de cours : titre, parties, blocs. Édition inline, glisser-déposer, auto-save.
class CourseEditorScreen extends StatefulWidget {
  const CourseEditorScreen({
    super.key,
    required this.course,
  });

  final Course course;

  @override
  State<CourseEditorScreen> createState() => _CourseEditorScreenState();
}

class _CourseEditorScreenState extends State<CourseEditorScreen> {
  late Course _course;
  late TextEditingController _courseTitleController;
  List<Part> _parts = [];
  bool _loading = true;
  String? _saveStatus;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _course = widget.course;
    _courseTitleController = TextEditingController(text: widget.course.title);
    _parts = List.from(widget.course.parts ?? []);
    if (_course.isLocal) {
      _loading = false;
    } else if (_parts.isEmpty) {
      _loading = false;
    } else {
      _loadFullCourse();
    }
  }

  /// Sauvegarde locale (sans compte).
  Future<void> _saveLocal() async {
    final updated = _course.copyWith(
      parts: _parts,
      updatedAt: DateTime.now().toIso8601String(),
    );
    await context.read<LocalCoursesProvider>().update(updated);
    if (mounted) _setSaveStatus('Enregistré');
  }

  Future<void> _loadFullCourse() async {
    if (_course.isLocal) return;
    final auth = context.read<AuthProvider>();
    final res = await auth.apiClient.get('/courses/${_course.id}/');
    if (!mounted) return;
    if (res.ok && res.data != null) {
      _course = Course.fromJson(res.data as Map<String, dynamic>);
      _courseTitleController.text = _course.title;
      setState(() {
        _parts = _course.parts ?? [];
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  void _setSaveStatus(String status) {
    _debounce?.cancel();
    setState(() => _saveStatus = status);
    _debounce = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _saveStatus = null);
    });
  }

  Future<void> _patchCourse({String? title, String? description}) async {
    if (_course.isLocal) {
      setState(() {
        _course = _course.copyWith(
          title: title ?? _course.title,
          description: description ?? _course.description,
          updatedAt: DateTime.now().toIso8601String(),
        );
      });
      await _saveLocal();
      return;
    }
    final auth = context.read<AuthProvider>();
    final body = <String, dynamic>{};
    if (title != null) body['title'] = title;
    if (description != null) body['description'] = description;
    final res = await auth.apiClient.patch('/courses/${_course.id}/', body: body);
    if (!mounted) return;
    if (res.ok) {
      setState(() {
        _course = _course.copyWith(
          title: title ?? _course.title,
          description: description ?? _course.description,
        );
      });
      _setSaveStatus('Enregistré');
    }
  }

  Future<void> _addPart() async {
    if (_course.isLocal) {
      final part = Part(
        id: LocalCoursesProvider.nextLocalPartId(),
        title: 'Nouvelle partie',
        position: _parts.length,
        blocks: [],
      );
      setState(() => _parts = [..._parts, part]);
      await _saveLocal();
      return;
    }
    final auth = context.read<AuthProvider>();
    final res = await auth.apiClient.post('/parts/', body: {
      'course': _course.id,
      'title': 'Nouvelle partie',
      'position': _parts.length,
    });
    if (!mounted) return;
    if (res.ok && res.data != null) {
      final part = Part.fromJson(res.data as Map<String, dynamic>);
      setState(() => _parts = [..._parts, part]);
      _setSaveStatus('Partie ajoutée');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res.error ?? 'Erreur')),
      );
    }
  }

  Future<void> _patchPart(int partId, {String? title, int? position}) async {
    if (_course.isLocal) {
      setState(() {
        _parts = _parts.map((p) {
          if (p.id == partId) {
            return Part(
              id: p.id,
              title: title ?? p.title,
              position: position ?? p.position,
              objective: p.objective,
              prerequisites: p.prerequisites,
              estimatedDuration: p.estimatedDuration,
              blocks: p.blocks,
              updatedAt: p.updatedAt,
            );
          }
          return p;
        }).toList();
      });
      await _saveLocal();
      return;
    }
    final auth = context.read<AuthProvider>();
    final body = <String, dynamic>{};
    if (title != null) body['title'] = title;
    if (position != null) body['position'] = position;
    final res = await auth.apiClient.patch('/parts/$partId/', body: body);
    if (!mounted) return;
    if (res.ok) {
      setState(() {
        _parts = _parts.map((p) {
          if (p.id == partId) {
            return Part(
              id: p.id,
              title: title ?? p.title,
              position: position ?? p.position,
              objective: p.objective,
              prerequisites: p.prerequisites,
              estimatedDuration: p.estimatedDuration,
              blocks: p.blocks,
              updatedAt: p.updatedAt,
            );
          }
          return p;
        }).toList();
      });
      _setSaveStatus('Enregistré');
    }
  }

  Future<void> _deletePart(int partId) async {
    if (_course.isLocal) {
      setState(() => _parts = _parts.where((p) => p.id != partId).toList());
      await _saveLocal();
      return;
    }
    final auth = context.read<AuthProvider>();
    final res = await auth.apiClient.delete('/parts/$partId/');
    if (!mounted) return;
    if (res.ok) {
      setState(() => _parts = _parts.where((p) => p.id != partId).toList());
      _setSaveStatus('Partie supprimée');
    }
  }

  Future<void> _reorderParts(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex--;
    final part = _parts.removeAt(oldIndex);
    _parts.insert(newIndex, part);
    setState(() {});
    if (_course.isLocal) {
      await _saveLocal();
      return;
    }
    for (int i = 0; i < _parts.length; i++) {
      await context.read<AuthProvider>().apiClient.patch(
            '/parts/${_parts[i].id}/',
            body: {'position': i},
          );
    }
    if (mounted) _setSaveStatus('Ordre enregistré');
  }

  Future<void> _addBlock(int partId, String blockType, [Map<String, dynamic>? content]) async {
    final part = _parts.firstWhere((p) => p.id == partId);
    final nextPosition = (part.blocks?.length ?? 0);
    if (_course.isLocal) {
      final block = Block(
        id: LocalCoursesProvider.nextLocalBlockId(),
        blockType: blockType,
        content: content ?? _defaultContent(blockType),
        position: nextPosition,
      );
      setState(() {
        _parts = _parts.map((p) {
          if (p.id != partId) return p;
          final blocks = [...?p.blocks, block];
          return Part(
            id: p.id,
            title: p.title,
            position: p.position,
            objective: p.objective,
            prerequisites: p.prerequisites,
            estimatedDuration: p.estimatedDuration,
            blocks: blocks,
            updatedAt: p.updatedAt,
          );
        }).toList();
      });
      await _saveLocal();
      return;
    }
    final auth = context.read<AuthProvider>();
    final res = await auth.apiClient.post('/blocks/', body: {
      'part': partId,
      'block_type': blockType,
      'content': content ?? _defaultContent(blockType),
      'position': nextPosition,
    });
    if (!mounted) return;
    if (res.ok && res.data != null) {
      final block = Block.fromJson(res.data as Map<String, dynamic>);
      setState(() {
        _parts = _parts.map((p) {
          if (p.id != partId) return p;
          final blocks = [...?p.blocks, block];
          blocks.sort((a, b) => a.position.compareTo(b.position));
          return Part(
            id: p.id,
            title: p.title,
            position: p.position,
            objective: p.objective,
            prerequisites: p.prerequisites,
            estimatedDuration: p.estimatedDuration,
            blocks: blocks,
            updatedAt: p.updatedAt,
          );
        }).toList();
      });
      _setSaveStatus('Bloc ajouté');
    }
  }

  Map<String, dynamic> _defaultContent(String blockType) {
    switch (blockType) {
      case 'title':
        return {'text': '', 'level': 2};
      case 'paragraph':
        return {'text': ''};
      case 'highlight':
        return {'text': '', 'color': 'yellow'};
      case 'objective':
        return {'text': ''};
      case 'list':
        return {'items': ['']};
      case 'qcu':
        return {'question': '', 'options': ['', ''], 'correct_index': 0};
      case 'qcm':
        return {'question': '', 'options': ['', ''], 'correct_indices': [0]};
      case 'video':
      case 'audio':
      case 'image':
        return {'url': '', 'alt': ''};
      case 'code':
        return {
          'code': '',
          'language': 'text',
          'mock_output': '',
          'syntax_highlight': true,
          'action_label': 'Résoudre virtuellement',
        };
      case 'terminal':
        return {'prompt': r'$ ', 'lines': [''], 'output': '', 'question': '', 'expected_command': ''};
      case 'scenario':
        return {
          'title': '',
          'description': '',
          'choices': [
            {'text': '', 'feedback': '', 'is_correct': true},
            {'text': '', 'feedback': '', 'is_correct': false},
          ],
        };
      case 'table':
        return {'headers': ['Colonne 1', 'Colonne 2'], 'rows': [['', '']]};
      case 'algorithm':
        return {'steps': ['Étape 1', 'Étape 2'], 'trace': ''};
      case 'term':
        return {'items': [{'term': '', 'definition': ''}]};
      case 'whiteboard':
        return {'strokes': <List<Map<String, dynamic>>>[], 'backgroundColor': '#FFFFFF'};
      case 'music_notation':
        return {
          'staffLayout': 'single',
          'clef': 'treble',
          'keySignature': 'C',
          'items': <Map<String, dynamic>>[],
          'timeSignature': '4/4',
        };
      default:
        return {};
    }
  }

  Future<void> _patchBlock(int partId, int blockId, Map<String, dynamic> patch) async {
    if (_course.isLocal) {
      setState(() {
        _parts = _parts.map((p) {
          if (p.id != partId) return p;
          final blocks = p.blocks?.map((b) {
            if (b.id != blockId) return b;
            final newContent = {...b.content};
            if (patch['content'] != null) {
              newContent.addAll(Map<String, dynamic>.from(patch['content'] as Map));
            }
            return Block(
              id: b.id,
              blockType: b.blockType,
              content: newContent,
              position: patch['position'] ?? b.position,
              objective: patch['objective'] ?? b.objective,
              estimatedDuration: patch['estimated_duration'] ?? b.estimatedDuration,
              updatedAt: b.updatedAt,
            );
          }).toList() ?? [];
          return Part(
            id: p.id,
            title: p.title,
            position: p.position,
            objective: p.objective,
            prerequisites: p.prerequisites,
            estimatedDuration: p.estimatedDuration,
            blocks: blocks,
            updatedAt: p.updatedAt,
          );
        }).toList();
      });
      await _saveLocal();
      return;
    }
    final auth = context.read<AuthProvider>();
    final res = await auth.apiClient.patch('/blocks/$blockId/', body: patch);
    if (!mounted) return;
    if (res.ok) {
      setState(() {
        _parts = _parts.map((p) {
          if (p.id != partId) return p;
          final blocks = p.blocks?.map((b) {
            if (b.id != blockId) return b;
            final newContent = {...b.content};
            if (patch['content'] != null) {
              newContent.addAll(Map<String, dynamic>.from(patch['content'] as Map));
            }
            return Block(
              id: b.id,
              blockType: b.blockType,
              content: newContent,
              position: patch['position'] ?? b.position,
              objective: patch['objective'] ?? b.objective,
              estimatedDuration: patch['estimated_duration'] ?? b.estimatedDuration,
              updatedAt: b.updatedAt,
            );
          }).toList() ?? [];
          return Part(
            id: p.id,
            title: p.title,
            position: p.position,
            objective: p.objective,
            prerequisites: p.prerequisites,
            estimatedDuration: p.estimatedDuration,
            blocks: blocks,
            updatedAt: p.updatedAt,
          );
        }).toList();
      });
      _setSaveStatus('Enregistré');
    }
  }

  Future<void> _deleteBlock(int partId, int blockId) async {
    if (_course.isLocal) {
      setState(() {
        _parts = _parts.map((p) {
          if (p.id != partId) return p;
          return Part(
            id: p.id,
            title: p.title,
            position: p.position,
            objective: p.objective,
            prerequisites: p.prerequisites,
            estimatedDuration: p.estimatedDuration,
            blocks: p.blocks?.where((b) => b.id != blockId).toList(),
            updatedAt: p.updatedAt,
          );
        }).toList();
      });
      await _saveLocal();
      return;
    }
    final auth = context.read<AuthProvider>();
    final res = await auth.apiClient.delete('/blocks/$blockId/');
    if (!mounted) return;
    if (res.ok) {
      setState(() {
        _parts = _parts.map((p) {
          if (p.id != partId) return p;
          return Part(
            id: p.id,
            title: p.title,
            position: p.position,
            objective: p.objective,
            prerequisites: p.prerequisites,
            estimatedDuration: p.estimatedDuration,
            blocks: p.blocks?.where((b) => b.id != blockId).toList(),
            updatedAt: p.updatedAt,
          );
        }).toList();
      });
      _setSaveStatus('Bloc supprimé');
    }
  }

  Future<void> _reorderBlocks(int partId, int oldIndex, int newIndex) async {
    final part = _parts.firstWhere((p) => p.id == partId);
    final blocks = List<Block>.from(part.blocks ?? []);
    if (oldIndex < 0 || oldIndex >= blocks.length || newIndex < 0 || newIndex >= blocks.length) return;
    final block = blocks.removeAt(oldIndex);
    blocks.insert(newIndex, block);
    setState(() {
      _parts = _parts.map((p) {
        if (p.id != partId) return p;
        for (int i = 0; i < blocks.length; i++) {
          blocks[i] = Block(
            id: blocks[i].id,
            blockType: blocks[i].blockType,
            content: blocks[i].content,
            position: i,
            objective: blocks[i].objective,
            estimatedDuration: blocks[i].estimatedDuration,
            updatedAt: blocks[i].updatedAt,
          );
        }
        return Part(
          id: p.id,
          title: p.title,
          position: p.position,
          objective: p.objective,
          prerequisites: p.prerequisites,
          estimatedDuration: p.estimatedDuration,
          blocks: blocks,
          updatedAt: p.updatedAt,
        );
      }).toList();
    });
    if (_course.isLocal) {
      await _saveLocal();
      return;
    }
    for (int i = 0; i < blocks.length; i++) {
      await context.read<AuthProvider>().apiClient.patch(
            '/blocks/${blocks[i].id}/',
            body: {'position': i},
          );
    }
    if (mounted) _setSaveStatus('Ordre enregistré');
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _courseTitleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text(_course.title)),
        body: const Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_course.title),
        actions: [
          if (_saveStatus != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                child: Text(
                  _saveStatus!,
                  style: TextStyle(
                    color: AppTheme.success,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.download_rounded),
            tooltip: 'Exporter',
            onPressed: () {
              if (_course.isLocal) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Connectez-vous pour exporter ce cours (HTML, PDF).'),
                  ),
                );
                return;
              }
              final auth = context.read<AuthProvider>();
              final base = auth.apiBaseUrl.replaceFirst('/api', '');
              final token = auth.apiClient.accessToken;
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Exporter'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Téléchargez le cours en HTML ou PDF.'),
                      const SizedBox(height: 12),
                      ListTile(
                        leading: const Icon(Icons.code),
                        title: const Text('Site web (HTML)'),
                        onTap: () {
                          Navigator.pop(ctx);
                          final url = '$base/api/courses/${_course.id}/export/html/';
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (c) => _ExportPage(
                                url: url,
                                token: token,
                                title: 'Export HTML',
                              ),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.picture_as_pdf),
                        title: const Text('PDF'),
                        onTap: () {
                          Navigator.pop(ctx);
                          final url = '$base/api/courses/${_course.id}/export/pdf/';
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (c) => _ExportPage(
                                url: url,
                                token: token,
                                title: 'Export PDF',
                                isPdf: true,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Titre du cours',
                hintText: 'Ex. Mathématiques 1re',
              ),
              controller: _courseTitleController,
              onSubmitted: (v) => _patchCourse(title: v.trim().isEmpty ? _course.title : v),
            ),
          ),
          Expanded(
            child: ReorderableListView(
              onReorder: _reorderParts,
              children: [
                for (int i = 0; i < _parts.length; i++)
                  ReorderableDelayedDragStartListener(
                    key: ValueKey(_parts[i].id),
                    index: i,
                    child: PartCard(
                      part: _parts[i],
                    onTitleChanged: (title) => _patchPart(_parts[i].id, title: title),
                    onDelete: () => _deletePart(_parts[i].id),
                    onAddBlock: () async {
                      final type = await AddBlockSheet.show(context);
                      if (type != null && mounted) _addBlock(_parts[i].id, type);
                    },
                    onBlockPatch: (blockId, patch) =>
                        _patchBlock(_parts[i].id, blockId, patch),
                    onBlockDelete: (blockId) =>
                        _deleteBlock(_parts[i].id, blockId),
                    onBlockReorder: (oldIndex, newIndex) =>
                        _reorderBlocks(_parts[i].id, oldIndex, newIndex),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: OutlinedButton.icon(
            onPressed: _addPart,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Ajouter une partie'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primary,
              side: const BorderSide(color: AppTheme.primary),
            ),
          ),
        ),
      ),
    );
  }
}

class _ExportPage extends StatelessWidget {
  const _ExportPage({
    required this.url,
    required this.token,
    required this.title,
    this.isPdf = false,
  });

  final String url;
  final String? token;
  final String title;
  final bool isPdf;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isPdf ? Icons.picture_as_pdf : Icons.code,
                size: 64,
                color: AppTheme.primary,
              ),
              const SizedBox(height: 16),
              const Text(
                'Ouvrez le lien ci-dessous dans votre navigateur pour télécharger l\'export. Si vous êtes connecté au même réseau que le serveur, le fichier se téléchargera.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              SelectableText(url),
            ],
          ),
        ),
      ),
    );
  }
}
