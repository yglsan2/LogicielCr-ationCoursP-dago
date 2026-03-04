import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/course.dart';

const String _keyLocalCourses = 'createur_cours_local_courses';

/// Gestion des cours créés sans compte (stockage local sur l'appareil).
class LocalCoursesProvider extends ChangeNotifier {
  List<Course> _courses = [];
  bool _loaded = false;

  List<Course> get courses => List.unmodifiable(_courses);
  bool get loaded => _loaded;

  Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyLocalCourses);
    if (raw == null || raw.isEmpty) {
      _courses = [];
    } else {
      try {
        final list = jsonDecode(raw) as List<dynamic>;
        _courses = list
            .map((e) => Course.fromLocalJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {
        _courses = [];
      }
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _courses.map((c) => c.toJsonForLocal()).toList();
    await prefs.setString(_keyLocalCourses, jsonEncode(list));
    notifyListeners();
  }

  /// Ajoute un cours (création locale).
  Future<void> add(Course course) async {
    if (course.localId == null) return;
    _courses.add(course);
    await _save();
  }

  /// Met à jour un cours existant (par localId).
  Future<void> update(Course course) async {
    if (course.localId == null) return;
    final i = _courses.indexWhere((c) => c.localId == course.localId);
    if (i >= 0) {
      _courses[i] = course;
      await _save();
    }
  }

  /// Supprime un cours local.
  Future<void> remove(String localId) async {
    _courses.removeWhere((c) => c.localId == localId);
    await _save();
  }

  /// Génère un nouvel identifiant local unique.
  static String generateLocalId() {
    return 'local_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Id négatif unique pour partie (usage local).
  static int nextLocalPartId() => -DateTime.now().microsecondsSinceEpoch.abs();
  /// Id négatif unique pour bloc (usage local).
  static int nextLocalBlockId() => -DateTime.now().microsecondsSinceEpoch.abs() - 2147483647;
}
