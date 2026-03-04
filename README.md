# Créateur de cours

Logiciel pour concevoir et structurer des cours : éditeur de contenus avec parties et blocs, sauvegarde locale ou synchronisée, export HTML et PDF.

**Stack :** Flutter (application) + Django (API).

---

## Ce que fait l’application

- **Création de cours** : titre, parties (chapitres), blocs de contenu dans chaque partie.
- **Blocs disponibles** : texte (titre, paragraphe, objectif, liste, surlignage), médias (image, vidéo, tableau blanc), code et terminal, questions (QCU, QCM, ordre, numérique, etc.), tableaux, glossaire, **partition musicale** (portées, clés de sol/fa, notes, silences), audio.
- **Utilisation** : avec ou sans compte. Sans compte, les cours restent sur l’appareil ; avec compte, synchronisation et export.
- **Export** : cours exportables en HTML ou PDF (avec compte).

---

## Structure du projet

```
createur-cours/
├── app/                 # Application Flutter
│   ├── lib/
│   │   ├── core/        # Thème, API, auth
│   │   ├── models/      # Course, Part, Block
│   │   ├── screens/     # Accueil, Auth, Éditeur, Onboarding
│   │   └── widgets/     # Cartes de parties, blocs, panneau d’ajout
│   └── pubspec.yaml
├── backend/             # API Django
│   ├── config/          # Settings, URLs
│   ├── courses/         # Modèles, vues, exports HTML/PDF
│   ├── manage.py
│   └── requirements.txt
```

---

## Lancer le backend (Django)

```bash
cd backend
python -m venv .venv
source .venv/bin/activate   # Windows : .venv\Scripts\activate
pip install -r requirements.txt
python manage.py migrate
python manage.py runserver
```

API : **http://127.0.0.1:8000/api/**

- Inscription : `POST /api/auth/register/`
- Connexion : `POST /api/auth/token/`
- Cours, parties, blocs : CRUD classique
- Export : `GET /api/courses/:id/export/html/` et `.../export/pdf/`

Pour le PDF : `pip install weasyprint` (et dépendances système indiquées dans la doc WeasyPrint).

---

## Lancer l’app Flutter

L’URL de l’API est dans `app/lib/core/auth_provider.dart` (par défaut `http://127.0.0.1:8000/api`).

```bash
cd app
flutter pub get
flutter run
```

- Linux : `flutter run -d linux`
- Web : `flutter run -d chrome` ou `flutter run -d web-server`
- Autre : `flutter devices` puis `flutter run -d <device_id>`

---

## Utilisateur de test (backend)

```bash
cd backend
source .venv/bin/activate
python manage.py createsuperuser
```

Ou créer un compte depuis l’app (Inscription).

---

**Créateur :** DesertYGL
