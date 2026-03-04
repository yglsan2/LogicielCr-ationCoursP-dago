# Stratégie produit : Createur de cours

**Vision** : Une application de création de cours **hyper simple**, **moderne** et **très facile à utiliser**, tout en restant **efficace** et **complète** pour les enseignants. Zéro formation nécessaire, prise en main en quelques minutes.

---

## 1. Piliers stratégiques

| Pilier | Signification concrète |
|--------|------------------------|
| **Hyper simple** | Aucun concept à apprendre avant de commencer. Vocabulaire du quotidien. Pas de modes « simple » vs « avancé » : un seul flux, les options restent discrètes. |
| **Moderne** | Interface actuelle (design 2020+), réactive, cohérente. Pas d’aspect « logiciel métier des années 2000 ». |
| **Très facile à utiliser** | Moins de 3 clics pour les actions courantes. Édition inline, glisser-déposer, sauvegarde automatique. Onboarding court et optionnel. |
| **Efficace** | Créer un module utilisable en ~10 minutes. Pas de wizards en 12 étapes. Pas de fenêtres superflues. |
| **Complet** | Couvre le besoin réel : structure pédagogique (cours → parties → activités), tous les types d’activités utiles (questions, ordre, médias, etc.), exports (PDF, web, SCORM). |

**Règle d’or** : Chaque fonctionnalité doit passer le test « Un enseignant débute : peut-il la comprendre et l’utiliser sans lire la doc ? ». Si non, simplifier ou guider in-app.

---

## 2. Expérience utilisateur cible

### 2.1 Premier contact (jour 1)

- **Arrivée** : écran d’accueil clair avec un seul appel à l’action principal : « Créer mon premier cours » ou « Découvrir l’app ».
- **Onboarding** : parcours court (3–5 écrans max), optionnel et skippable. Montrer : 1) la liste des cours, 2) l’éditeur (cours = parties + blocs), 3) « Ajouter un bloc » (texte, question, média). Pas de théorie.
- **Premier cours** : possibilité de créer un cours vide et d’ajouter une première partie + un premier bloc en moins de 2 minutes.

### 2.2 Usage quotidien

- **Vue principale** : une seule « home » = liste des cours (cartes ou liste). Clic sur un cours → éditeur de ce cours.
- **Éditeur** : structure visible (parties/sections), contenu en blocs. Actions immédiates :
  - Cliquer sur un titre ou un paragraphe → édition inline.
  - Bouton « Ajouter un bloc » (ou équivalent) toujours visible → choix par type (texte, question à choix unique, vidéo, etc.).
  - Glisser-déposer pour réordonner parties et blocs.
- **Pas de « Fichier > Enregistrer »** : sauvegarde automatique avec indicateur discret (ex. « Enregistré » / « Enregistrement… »).
- **Exports** : un menu ou écran « Exporter » avec 3–4 options lisibles : « Site web », « PDF », « SCORM (LMS) ». Un clic → choix du format → téléchargement ou lien.

### 2.3 Ce qu’on évite

- Wizards de plus de 5 étapes.
- Fenêtres modales pour éditer un simple paragraphe.
- Vocabulaire technique (QCU, QCM, grain, séquence) sans explication en langage naturel.
- Modes « débutant » / « expert » : une seule interface, options avancées regroupées et optionnelles.
- Installation ou configuration compliquée : privilégier app web ou PWA + backend hébergeable simplement.

---

## 3. Architecture de l’information (IA)

### 3.1 Hiérarchie des contenus

- **Cours** : conteneur racine (ex. « Mathématiques 1re », « Formation sécurité »).
- **Partie** (ou « Module ») : regroupement thématique dans un cours (ex. « Les fonctions », « Évaluation »). Une partie contient des **blocs**.
- **Bloc** : unité de contenu ou d’activité. Types : titre, paragraphe, objectif pédagogique, liste, image, audio, vidéo, question à choix unique, question à choix multiples, ordonnancement, réponse numérique, texte à trous, catégorisation.

La **séquence** (sous-partie) reste optionnelle : on peut l’introduire plus tard comme « sous-partie » sans l’imposer.

### 3.2 Vocabulaire interface

Utiliser des termes compréhensibles par tout enseignant :

| Éviter (jargon) | Préférer |
|-----------------|----------|
| Grain | Bloc, activité, contenu |
| QCU | « Question à une seule bonne réponse » (avec infobulle si besoin) |
| QCM | « Question à plusieurs bonnes réponses » |
| Séquence | Partie, section (ou « sous-partie » si on l’ajoute) |
| Module SCORM | « Export pour Moodle / LMS » |

### 3.3 Champs optionnels (pas bloquants)

Pour chaque **partie** ou **bloc** (selon le type), proposer en option :
- Objectif pédagogique (texte court).
- Prérequis (texte court).
- Durée estimée (ex. « 5 min »).

Ces champs n’apparaissent pas en premier : accessibles via « Options » ou un panneau secondaire, pour ne pas encombrer le flux principal.

---

## 4. Fonctionnalités par périmètre

### 4.1 Indispensable (MVP)

- Création / édition / suppression de **cours**.
- Dans un cours : **parties** (titres) + **blocs** dans chaque partie.
- Types de blocs : **texte** (titre, paragraphe), **objectif**, **image**, **vidéo** (lien ou upload), **question à une seule réponse**, **question à plusieurs réponses**.
- Réordonnancement par **glisser-déposer** (parties et blocs).
- **Sauvegarde automatique**.
- **Export** : au minimum **PDF** et **page web** (HTML). SCORM en objectif prioritaire après.

### 4.2 Complétude (post-MVP)

- Autres types de blocs : **ordonnancement**, **réponse numérique**, **texte à trous**, **catégorisation**.
- **Blocs réutilisables** (référence à un bloc existant dans un autre cours) pour éviter la duplication.
- **Banque de questions** : créer des questions réutilisables dans plusieurs cours.
- **Diaporama** (export slides) si pertinent.
- **Accessibilité** : contrastes, structure des titres, textes alternatifs pour les médias.
- **IA assistée** (suggestions de structure, reformulation, idées d’exercices) sans rendre l’outil dépendant de l’IA.

### 4.3 Ce qu’on ne fait pas (volontairement)

- Édition de structure technique (XML, JSON brut) exposée à l’utilisateur.
- Chaîne éditoriale lourde type Scenari/Opale.
- Multi-fenêtres à synchroniser : une vue principale par contexte (liste des cours / éditeur de cours).

---

## 5. Principes techniques au service de la simplicité

- **Stack** : Flutter (UI multiplateforme) + Django (API, stockage, exports). Rester sur cette base sans ajouter de couches inutiles.
- **Données** : modèles Django clairs (Cours, Partie, Bloc avec type + contenu JSON ou champs dédiés). Pas de XML.
- **Exports** : services dédiés (génération PDF, génération HTML, packaging SCORM) avec des librairies ciblées, pas un moteur de documentation générique.
- **API** : REST ou équivalent, bien documentée pour que l’app Flutter n’ait qu’un nombre limité d’endpoints à utiliser.
- **Performance** : temps de chargement courts, feedback immédiat sur les actions (optimistic UI si besoin).

---

## 6. Mesure du succès (critères qualitatifs)

L’app est réussie si :

1. **Prise en main** : un nouvel utilisateur crée un premier cours avec au moins une partie et deux blocs (dont un non-texte) en moins de 10 minutes, sans aide externe.
2. **Fluidité** : réordonner des blocs ou des parties se fait par glisser-déposer sans quitter la vue ni ouvrir de dialogue.
3. **Clarté** : les libellés des types de blocs et des boutons sont compris sans formation (test utilisateur type « enseignant non technique »).
4. **Complétude perçue** : les enseignants trouvent les types d’activités et les exports dont ils ont besoin pour un usage réel (cours, évaluation, mise en ligne / LMS).

---

## 7. Synthèse : stratégie en une page

| Dimension | Stratégie |
|-----------|-----------|
| **Simplicité** | Un flux principal (liste cours → éditeur). Édition inline, glisser-déposer, auto-save. Vocabulaire naturel. Pas de modes débutant/expert. |
| **Modernité** | UI actuelle, réactive, cohérente. Stack Flutter + Django, pas de chaîne lourde. |
| **Facilité** | Onboarding court et optionnel. Actions en 1–3 clics. Aide contextuelle (infobulles), pas de manuel obligatoire. |
| **Efficacité** | Création d’un module en ~10 min. Contexte unique, pas de fenêtres multiples. Exports en un clic. |
| **Complétude** | Structure cours → parties → blocs. Tous les types d’activités utiles (questions, ordre, médias, etc.). Export PDF, web, SCORM. Options pédagogiques (objectif, prérequis, durée) disponibles sans encombrer. |

**Fil rouge** : Chaque décision (feature, écran, libellé) doit pouvoir être justifiée par « ça rend l’app plus simple ou plus efficace pour l’enseignant ». Si une fonctionnalité ajoute de la complexité sans gain clair, la repousser ou la rendre optionnelle et discrète.

---

*Document de référence pour le projet Createur de cours. À aligner avec les règles Cursor et le cahier des charges (idees-opale-reference.md).*
