import 'package:flutter/material.dart';
import '../core/theme.dart';

/// Parcours court (3 écrans), optionnel et skippable — stratégie.
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed('/home');
                  },
                  child: const Text('Passer'),
                ),
              ),
              Expanded(
                child: PageView(
                  children: [
                    _OnboardingPage(
                      icon: Icons.menu_book_rounded,
                      title: 'Vos cours en un coup d\'œil',
                      text:
                          'La liste de vos cours s\'affiche ici. Touchez un cours pour l\'éditer.',
                    ),
                    _OnboardingPage(
                      icon: Icons.edit_note_rounded,
                      title: 'Parties et blocs',
                      text:
                          'Un cours est fait de parties (sections). Chaque partie contient des blocs : texte, questions, images, vidéos.',
                    ),
                    _OnboardingPage(
                      icon: Icons.add_circle_outline_rounded,
                      title: 'Ajouter un bloc',
                      text:
                          'Utilisez « Ajouter un bloc » pour insérer du texte, une question à une réponse, une vidéo, etc. Vous pouvez réordonner par glisser-déposer.',
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed('/home');
                },
                child: const Text('Commencer'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.text,
  });

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 80, color: AppTheme.primary),
        const SizedBox(height: 24),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.onSurface,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          text,
          style: TextStyle(
            color: AppTheme.onSurfaceVariant,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
