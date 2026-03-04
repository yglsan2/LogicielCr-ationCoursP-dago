import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../core/auth_provider.dart';
import '../core/local_courses_provider.dart';
import '../models/course.dart';
import 'course_editor_screen.dart';

/// Vue principale : liste des cours. Sans compte = stockage local ; avec compte = API.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Course> _serverCourses = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final auth = context.read<AuthProvider>();
    final local = context.read<LocalCoursesProvider>();
    await local.load();

    if (auth.isAuthenticated) {
      _loadServerCourses();
    } else {
      setState(() {
        _loading = false;
        _error = null;
      });
    }
  }

  Future<void> _loadServerCourses() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final auth = context.read<AuthProvider>();
    final res = await auth.apiClient.get('/courses/');
    if (!mounted) return;
    if (res.ok && res.data != null) {
      final list = res.data is List ? res.data as List : (res.data as Map?)?['results'] as List?;
      if (list != null) {
        setState(() {
          _serverCourses = list.map((e) => Course.fromJson(e as Map<String, dynamic>)).toList();
          _loading = false;
        });
      } else {
        setState(() {
          _serverCourses = [];
          _loading = false;
        });
      }
    } else {
      setState(() {
        _error = res.error ?? 'Impossible de charger les cours.';
        _loading = false;
      });
    }
  }

  List<Course> get _courses {
    final auth = context.read<AuthProvider>();
    if (auth.isAuthenticated) return _serverCourses;
    return context.read<LocalCoursesProvider>().courses;
  }

  static const List<Map<String, dynamic>> _courseTemplates = [
    {'title': 'Nouveau cours', 'parts': <String>[]},
    {'title': 'Cours Réseau', 'parts': ['Introduction', 'Adressage IP', 'Commandes de base', 'Sécurité']},
    {'title': 'Cours Programmation', 'parts': ['Variables et types', 'Structures de contrôle', 'Fonctions', 'Projet']},
    {'title': 'Cours DevOps', 'parts': ['Conteneurs', 'Orchestration', 'CI/CD', 'Incidents']},
    {'title': 'Cours Cybersécurité', 'parts': ['Bonnes pratiques', 'Incidents', 'Outils']},
    {'title': 'Cours Algorithmique', 'parts': ['Variables et boucles', 'Tableaux', 'Tri et recherche', 'Complexité']},
  ];

  Future<void> _createCourse() async {
    final chosen = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.7,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Créer un cours',
                  style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: _courseTemplates.map<Widget>((t) {
                      final parts = t['parts'] as List<dynamic>? ?? [];
                      final isTemplate = parts.isNotEmpty;
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          isTemplate ? Icons.library_books_rounded : Icons.add_circle_outline_rounded,
                          color: AppTheme.primary,
                        ),
                        title: Text(t['title'] as String),
                        subtitle: isTemplate ? Text('${parts.length} parties prévues') : const Text('Partir de zéro'),
                        onTap: () => Navigator.pop(ctx, t),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (!mounted || chosen == null) return;
    await _createCourseWithTemplate(chosen);
  }

  Future<void> _createCourseWithTemplate(Map<String, dynamic> template) async {
    final auth = context.read<AuthProvider>();
    final title = template['title'] as String? ?? 'Nouveau cours';
    final partTitles = (template['parts'] as List<dynamic>?)?.cast<String>() ?? [];

    if (auth.isAuthenticated) {
      final res = await auth.apiClient.post('/courses/', body: {'title': title, 'description': ''});
      if (!mounted) return;
      if (!res.ok || res.data == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res.error ?? 'Erreur lors de la création.')),
        );
        return;
      }
      final course = Course.fromJson(res.data as Map<String, dynamic>);
      for (int i = 0; i < partTitles.length; i++) {
        await auth.apiClient.post('/parts/', body: {'course': course.id, 'title': partTitles[i], 'position': i});
      }
      if (!mounted) return;
      final updated = await auth.apiClient.get('/courses/${course.id}/');
      final toOpen = updated.ok && updated.data != null
          ? Course.fromJson(updated.data as Map<String, dynamic>)
          : course;
      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (context) => CourseEditorScreen(course: toOpen)),
      ).then((_) => _load());
    } else {
      final local = context.read<LocalCoursesProvider>();
      final parts = <Part>[];
      for (int i = 0; i < partTitles.length; i++) {
        parts.add(Part(id: -(i + 1), title: partTitles[i], position: i, blocks: []));
      }
      final course = Course(
        id: 0,
        title: title,
        description: '',
        localId: LocalCoursesProvider.generateLocalId(),
        updatedAt: DateTime.now().toIso8601String(),
        parts: parts,
      );
      await local.add(course);
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (context) => CourseEditorScreen(course: course)),
      ).then((_) => _load());
    }
  }

  void _openEditor(Course course) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => CourseEditorScreen(course: course),
      ),
    ).then((_) => _load());
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final isLocalMode = !auth.isAuthenticated;
    final courses = _courses;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes cours'),
        actions: [
          IconButton(
            icon: const Icon(Icons.lightbulb_outline_rounded),
            tooltip: 'Découvrir l\'app',
            onPressed: () => Navigator.of(context).pushNamed('/onboarding'),
          ),
          if (isLocalMode)
            TextButton.icon(
              onPressed: () => Navigator.of(context).pushNamed('/auth'),
              icon: const Icon(Icons.login_rounded, size: 20),
              label: const Text('Se connecter'),
            )
          else
            IconButton(
              icon: const Icon(Icons.logout_rounded),
              tooltip: 'Déconnexion',
              onPressed: () async {
                await auth.logout();
                if (!mounted) return;
                setState(() {
                  _serverCourses = [];
                  _error = null;
                });
              },
            ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isLocalMode)
            Material(
              color: AppTheme.primary.withValues(alpha: 0.1),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded, size: 20, color: AppTheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Cours enregistrés sur cet appareil. Inscrivez-vous pour les synchroniser et les retrouver partout.',
                        style: TextStyle(fontSize: 12, color: AppTheme.onSurface),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                : _error != null && auth.isAuthenticated
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_error!, textAlign: TextAlign.center),
                            const SizedBox(height: 16),
                            TextButton.icon(
                              onPressed: _loadServerCourses,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Réessayer'),
                            ),
                          ],
                        ),
                      )
                    : courses.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.school_rounded, size: 80, color: Colors.grey.shade400),
                                const SizedBox(height: 16),
                                Text(
                                  'Aucun cours pour l\'instant',
                                  style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 16),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Créez votre premier cours en un clic',
                                  style: TextStyle(color: AppTheme.onSurfaceVariant),
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton.icon(
                                  onPressed: _createCourse,
                                  icon: const Icon(Icons.add_rounded),
                                  label: const Text('Créer mon premier cours'),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () async {
                              if (auth.isAuthenticated) await _loadServerCourses();
                              else context.read<LocalCoursesProvider>().load();
                            },
                            color: AppTheme.primary,
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              itemCount: courses.length,
                              itemBuilder: (context, index) {
                                final course = courses[index];
                                return Card(
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: AppTheme.primary.withValues(alpha: 0.2),
                                      child: const Icon(Icons.menu_book_rounded, color: AppTheme.primary),
                                    ),
                                    title: Text(course.title),
                                    subtitle: course.description != null && course.description!.isNotEmpty
                                        ? Text(course.description!, maxLines: 1, overflow: TextOverflow.ellipsis)
                                        : (course.isLocal ? const Text('Sur cet appareil') : null),
                                    trailing: const Icon(Icons.chevron_right),
                                    onTap: () => _openEditor(course),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
      floatingActionButton: courses.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _createCourse,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Nouveau cours'),
              backgroundColor: AppTheme.primary,
            )
          : null,
    );
  }
}
