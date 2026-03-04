/// Modèle cours (liste et détail). Support mode local (sans compte) et serveur.
class Course {
  Course({
    required this.id,
    required this.title,
    this.description,
    this.author,
    this.updatedAt,
    this.parts,
    this.localId,
  });

  final int id;
  final String title;
  final String? description;
  final Map<String, dynamic>? author;
  final String? updatedAt;
  final List<Part>? parts;
  /// Présent uniquement pour les cours créés sans compte (stockage local).
  final String? localId;

  bool get isLocal => localId != null;

  factory Course.fromJson(Map<String, dynamic> json) {
    List<Part>? parts;
    if (json['parts'] != null) {
      parts = (json['parts'] as List)
          .map((e) => Part.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return Course(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      author: json['author'] as Map<String, dynamic>?,
      updatedAt: json['updated_at'] as String?,
      parts: parts,
      localId: null,
    );
  }

  /// Désérialisation depuis le stockage local (JSON avec local_id et structure complète).
  factory Course.fromLocalJson(Map<String, dynamic> json) {
    List<Part>? parts;
    if (json['parts'] != null) {
      parts = (json['parts'] as List)
          .map((e) => Part.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return Course(
      id: 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      author: null,
      updatedAt: json['updated_at'] as String?,
      parts: parts,
      localId: json['local_id'] as String? ?? json['localId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      if (description != null) 'description': description,
    };
  }

  /// Sérialisation complète pour le stockage local (parties + blocs).
  Map<String, dynamic> toJsonForLocal() {
    return {
      'local_id': localId,
      'title': title,
      'description': description ?? '',
      'updated_at': updatedAt ?? DateTime.now().toIso8601String(),
      'parts': parts?.map((p) => p.toJsonFull()).toList() ?? [],
    };
  }

  Course copyWith({
    int? id,
    String? title,
    String? description,
    Map<String, dynamic>? author,
    String? updatedAt,
    List<Part>? parts,
    String? localId,
  }) {
    return Course(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      author: author ?? this.author,
      updatedAt: updatedAt ?? this.updatedAt,
      parts: parts ?? this.parts,
      localId: localId ?? this.localId,
    );
  }
}

class Part {
  Part({
    required this.id,
    required this.title,
    required this.position,
    this.objective,
    this.prerequisites,
    this.estimatedDuration,
    this.blocks,
    this.updatedAt,
  });

  final int id;
  final String title;
  final int position;
  final String? objective;
  final String? prerequisites;
  final String? estimatedDuration;
  final List<Block>? blocks;
  final String? updatedAt;

  factory Part.fromJson(Map<String, dynamic> json) {
    List<Block>? blocks;
    if (json['blocks'] != null) {
      blocks = (json['blocks'] as List)
          .map((e) => Block.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return Part(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      position: json['position'] as int? ?? 0,
      objective: json['objective'] as String?,
      prerequisites: json['prerequisites'] as String?,
      estimatedDuration: json['estimated_duration'] as String?,
      blocks: blocks,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'position': position,
      'course': null,
    };
  }

  Map<String, dynamic> toJsonFull() {
    return {
      'id': id,
      'title': title,
      'position': position,
      'objective': objective,
      'prerequisites': prerequisites,
      'estimated_duration': estimatedDuration,
      'blocks': blocks?.map((b) => b.toJson()).toList() ?? [],
    };
  }
}

class Block {
  Block({
    required this.id,
    required this.blockType,
    required this.content,
    required this.position,
    this.objective,
    this.estimatedDuration,
    this.updatedAt,
  });

  final int id;
  final String blockType;
  final Map<String, dynamic> content;
  final int position;
  final String? objective;
  final String? estimatedDuration;
  final String? updatedAt;

  factory Block.fromJson(Map<String, dynamic> json) {
    final content = json['content'];
    return Block(
      id: json['id'] as int? ?? 0,
      blockType: json['block_type'] as String? ?? 'paragraph',
      content: content is Map<String, dynamic> ? content : {},
      position: json['position'] as int? ?? 0,
      objective: json['objective'] as String?,
      estimatedDuration: json['estimated_duration'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'block_type': blockType,
      'content': content,
      'position': position,
      if (objective != null) 'objective': objective,
      if (estimatedDuration != null) 'estimated_duration': estimatedDuration,
    };
  }
}
