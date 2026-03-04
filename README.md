# Createur de cours

Application de création de cours pour enseignants : **simple**, **moderne**, **facile à utiliser**, **efficace** et **complète**.  
Stack : **Flutter** (app multiplateforme) + **Django** (API REST, exports).

---

## Structure du projet

```
createur-cours/
├── app/                 # Application Flutter
│   ├── lib/
│   │   ├── core/        # Thème, API, auth
│   │   ├── models/      # Course, Part, Block
│   │   ├── screens/     # Splash, Auth, Home, Éditeur, Onboarding
│   │   └── widgets/     # PartCard, BlockTile, AddBlockSheet
│   └── pubspec.yaml
├── backend/             # API Django
│   ├── config/          # Settings, URLs
│   ├── courses/         # Modèles, vues, exports (HTML, PDF)
│   ├── manage.py
│   └── requirements.txt
├── STRATEGIE.md         # Stratégie produit
├── idees-opale-reference.md
└── .cursor/rules/       # Règles Cursor
```

---

## Lancer le backend (Django)

```bash
cd backend
python -m venv .venv
source .venv/bin/activate   # ou .venv\Scripts\activate sous Windows
pip install -r requirements.txt
python manage.py migrate
python manage.py runserver
```

L’API est disponible sur **http://127.0.0.1:8000/api/**.

- **Inscription** : `POST /api/auth/register/` (username, password, email optionnel)
- **Connexion** : `POST /api/auth/token/` (username, password) → access + refresh
- **Cours** : `GET/POST /api/courses/`, `GET/PATCH/DELETE /api/courses/:id/`
- **Parties** : `GET/POST /api/parts/`, `PATCH/DELETE /api/parts/:id/`
- **Blocs** : `GET/POST /api/blocks/`, `PATCH/DELETE /api/blocks/:id/`
- **Export** : `GET /api/courses/:id/export/html/`, `GET /api/courses/:id/export/pdf/`

Pour l’export PDF, installer WeasyPrint : `pip install weasyprint` (dépendances système selon la doc WeasyPrint).

---

## Lancer l’app Flutter

Configurer l’URL de l’API dans `app/lib/core/auth_provider.dart` si besoin (par défaut `http://127.0.0.1:8000/api`).

```bash
cd app
flutter pub get
flutter run
```

- **Linux (desktop)** : `flutter run -d linux`
- **Web** : `flutter run -d chrome` (si Chrome est détecté) ou `flutter run -d web-server` puis ouvrir l’URL affichée dans un navigateur
- **Autre cible** : `flutter devices` puis `flutter run -d <device_id>`

---

## Fonctionnalités

- **Authentification** : inscription, connexion, JWT, déconnexion
- **Liste des cours** : création, ouverture, suppression (via l’éditeur)
- **Éditeur** : titre du cours éditable, parties réordonnables (glisser-déposer), blocs réordonnables
- **Blocs** : titre, paragraphe, objectif, liste, image, vidéo, audio, question à une réponse, question à plusieurs réponses, ordonnancement, réponse numérique, texte à compléter, catégorisation
- **Édition inline** : clic sur un champ → édition sur place, pas de modale pour le texte
- **Sauvegarde** : envoi au serveur à la soumission des champs (indicateur « Enregistré »)
- **Export** : HTML (navigateur), PDF (téléchargement)
- **Onboarding** : parcours court, optionnel, depuis le menu

---

## Créer un utilisateur de test (backend)

```bash
cd backend
source .venv/bin/activate
python manage.py createsuperuser
```

Ou via l’app : **Inscription** avec un nom d’utilisateur et un mot de passe.

---

## Documentation

- **Stratégie** : voir `STRATEGIE.md`
- **Référence Opale** : voir `idees-opale-reference.md`
- **Règles de développement** : `.cursor/rules/`
