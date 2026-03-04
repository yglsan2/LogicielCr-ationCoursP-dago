import 'package:flutter/material.dart';
import '../core/theme.dart';

/// Types de blocs : ordre hiérarchique et logique par catégorie.
/// 1. Texte (structure puis contenu, surlignage en fin de section)
/// 2. Média (image, vidéo, tableau blanc)
/// 3. Code & Réseau
/// 4. Questions & Exercices
/// 5. Tableaux & Référence
/// 6. Musique
const List<Map<String, String>> blockTypes = [
  // ——— Texte ———
  {'id': 'title', 'label': 'Titre', 'subtitle': 'Structurer le cours', 'category': 'text'},
  {'id': 'paragraph', 'label': 'Paragraphe', 'subtitle': 'Texte libre', 'category': 'text'},
  {'id': 'objective', 'label': 'Objectif pédagogique', 'subtitle': 'Ce que l\'apprenant va apprendre', 'category': 'text'},
  {'id': 'list', 'label': 'Liste', 'subtitle': 'Liste à puces', 'category': 'text'},
  {'id': 'highlight', 'label': 'Surlignage fluo', 'subtitle': 'Mettre en évidence (feutre)', 'category': 'text'},
  // ——— Média ———
  {'id': 'image', 'label': 'Image', 'subtitle': 'Illustration ou schéma', 'category': 'media'},
  {'id': 'video', 'label': 'Vidéo', 'subtitle': 'Lien vidéo', 'category': 'media'},
  {'id': 'whiteboard', 'label': 'Tableau blanc', 'subtitle': 'Dessin à main levée', 'category': 'media'},
  // ——— Code & Réseau ———
  {'id': 'code', 'label': 'Bloc de code', 'subtitle': 'Coloration, exécution simulée', 'category': 'code'},
  {'id': 'terminal', 'label': 'Commande / Terminal', 'subtitle': 'Réseau, dev, DevOps', 'category': 'code'},
  {'id': 'scenario', 'label': 'Scénario incident', 'subtitle': 'Sécurité, TSSR', 'category': 'code'},
  // ——— Questions & Exercices ———
  {'id': 'qcu', 'label': 'Une seule bonne réponse', 'subtitle': 'QCU', 'category': 'quiz'},
  {'id': 'qcm', 'label': 'Plusieurs bonnes réponses', 'subtitle': 'QCM', 'category': 'quiz'},
  {'id': 'ordering', 'label': 'Mettre dans l\'ordre', 'subtitle': 'Réordonner', 'category': 'quiz'},
  {'id': 'numeric', 'label': 'Réponse numérique', 'subtitle': 'Un nombre', 'category': 'quiz'},
  {'id': 'fill_blank', 'label': 'Texte à compléter', 'subtitle': 'Blancs à remplir', 'category': 'quiz'},
  {'id': 'categorize', 'label': 'Catégoriser', 'subtitle': 'Ranger par catégorie', 'category': 'quiz'},
  // ——— Tableaux & Référence ———
  {'id': 'table', 'label': 'Tableau', 'subtitle': 'Comparaisons, références', 'category': 'reference'},
  {'id': 'algorithm', 'label': 'Algorithme / Étapes', 'subtitle': 'Pseudo-code, trace', 'category': 'reference'},
  {'id': 'term', 'label': 'Terme / Définition', 'subtitle': 'Glossaire, vocabulaire', 'category': 'reference'},
  // ——— Musique ———
  {'id': 'audio', 'label': 'Audio (MP3 / WAV)', 'subtitle': 'Extrait sonore', 'category': 'music'},
  {'id': 'music_notation', 'label': 'Partition musicale', 'subtitle': 'Portées, clés, notes, silences', 'category': 'music'},
];

const Map<String, String> _categoryLabels = {
  'text': 'Texte',
  'media': 'Média',
  'code': 'Code & Réseau',
  'quiz': 'Questions & Exercices',
  'reference': 'Tableaux & Glossaire',
  'music': 'Musique',
};

/// Panneau de choix du type de bloc : pleine hauteur, grille, catégories, fermeture claire.
class AddBlockSheet extends StatelessWidget {
  const AddBlockSheet({super.key});

  static Future<String?> show(BuildContext context) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddBlockSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.88;
    final padding = MediaQuery.paddingOf(context);

    return Container(
      height: height + padding.bottom,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          const _SheetHandle(),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ajouter un bloc',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.onSurface,
                      ),
                ),
                IconButton.filled(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.surfaceVariant,
                    foregroundColor: AppTheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(16, 0, 16, padding.bottom + 16),
              children: _buildCategories(context),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCategories(BuildContext context) {
    final grouped = <String, List<Map<String, String>>>{};
    for (final item in blockTypes) {
      final cat = item['category'] ?? 'text';
      grouped.putIfAbsent(cat, () => []).add(item);
    }
    final order = ['text', 'media', 'code', 'quiz', 'reference', 'music'];
    final list = <Widget>[];
    for (final cat in order) {
      final items = grouped[cat];
      if (items == null || items.isEmpty) continue;
      list.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  _categoryLabels[cat] ?? cat,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              Builder(
                builder: (context) {
                  const crossAxisCount = 2;
                  const spacing = 10.0;
                  const runSpacing = 10.0;
                  final maxW = MediaQuery.sizeOf(context).width - 32;
                  final width = (maxW - spacing * (crossAxisCount - 1)) / crossAxisCount;
                  return Wrap(
                    spacing: spacing,
                    runSpacing: runSpacing,
                    children: items.map((item) {
                      return SizedBox(
                        width: width,
                        child: _BlockTypeCard(
                          item: item,
                          onTap: () => Navigator.pop(context, item['id']),
                          icon: _iconForType(item['id']!),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      );
    }
    return list;
  }

  IconData _iconForType(String id) {
    switch (id) {
      case 'title':
        return Icons.title_rounded;
      case 'paragraph':
        return Icons.notes_rounded;
      case 'highlight':
        return Icons.highlight_rounded;
      case 'objective':
        return Icons.flag_rounded;
      case 'list':
        return Icons.format_list_bulleted_rounded;
      case 'code':
        return Icons.code_rounded;
      case 'terminal':
        return Icons.terminal_rounded;
      case 'scenario':
        return Icons.warning_amber_rounded;
      case 'image':
        return Icons.image_rounded;
      case 'video':
        return Icons.video_library_rounded;
      case 'audio':
        return Icons.audiotrack_rounded;
      case 'qcu':
        return Icons.radio_button_checked_rounded;
      case 'qcm':
        return Icons.checklist_rounded;
      case 'ordering':
        return Icons.sort_rounded;
      case 'numeric':
        return Icons.numbers_rounded;
      case 'fill_blank':
        return Icons.space_bar_rounded;
      case 'categorize':
        return Icons.category_rounded;
      case 'table':
        return Icons.table_chart_rounded;
      case 'algorithm':
        return Icons.account_tree_rounded;
      case 'term':
        return Icons.menu_book_rounded;
      case 'whiteboard':
        return Icons.draw_rounded;
      case 'music_notation':
        return Icons.music_note_rounded;
      default:
        return Icons.widgets_rounded;
    }
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey.shade400,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}

class _BlockTypeCard extends StatelessWidget {
  const _BlockTypeCard({
    required this.item,
    required this.onTap,
    required this.icon,
  });

  final Map<String, String> item;
  final VoidCallback onTap;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surfaceVariant.withValues(alpha: 0.6),
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.primary.withValues(alpha: 0.15),
                child: Icon(icon, color: AppTheme.primary, size: 22),
              ),
              const SizedBox(height: 10),
              Text(
                item['label']!,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                item['subtitle']!,
                style: TextStyle(
                  fontSize: 11,
                  color: AppTheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
