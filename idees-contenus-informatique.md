# Référence : apprentissage de l’informatique sous tous les angles

Ce document couvre **tous les grands domaines** de l’informatique pour construire des cours adaptés : réseau, développement, DevOps, sécurité, algorithmique, bases de données, système, web, cloud, matériel. Pour chaque angle : idées d’activités et **blocs à utiliser** dans l’app.

---

## Vue d’ensemble par domaine

| Domaine | Blocs les plus utiles | Exemples d’usage |
|--------|------------------------|------------------|
| **Réseau / TSSR / Admin Réseau** | Terminal, Scénario, Code, Tableau, QCM, Mettre dans l’ordre, Image | Commandes, topologie, adressage IP, scénarios de panne |
| **Développement** | Code, Terminal, Algorithme, Tableau, QCM, Terme/Définition, Image | Snippets, algo, structures de données, glossaire |
| **DevOps** | Terminal, Scénario, Code (YAML/JSON), Mettre dans l’ordre, Image | Pipelines, Docker/K8s, incidents, runbooks |
| **Cybersécurité** | Scénario, Terminal, Code, QCM, Terme/Définition | Phishing, bonnes pratiques, vocabulaire (XSS, CSRF…) |
| **Algorithmique** | Algorithme, Code, Tableau, Mettre dans l’ordre, Réponse numérique | Pseudo-code, trace, complexité, tri |
| **Bases de données** | Code (SQL), Terminal, Tableau, QCM, Texte à compléter | Requêtes, schémas, comparaison SGBD |
| **Système / Admin sys** | Terminal, Scénario, Liste, Mettre dans l’ordre, Image | Commandes, procédures, dépannage |
| **Web (front/back)** | Code, Image, QCM, Terminal | HTML/CSS/JS, APIs, schémas |
| **Cloud** | Scénario, Terminal, Code, Tableau, Image | IaaS/PaaS/SaaS, commandes, architectures |
| **Matériel / Architecture** | Tableau, Image, QCM, Terme/Définition | Comparaison composants, vocabulaire |

---

## 1. Réseau, TSSR, Admin Réseau

- **Topologie** : Image + légende (Liste/Paragraphe). **Tableau** pour tableau d’adressage IP.
- **Panne, impact** : QCM ou QCU + Paragraphe (contexte).
- **Calcul sous-réseaux** : Réponse numérique + Paragraphe.
- **Ordre des commandes** : Mettre dans l’ordre.
- **Trame / capture factice** : Code ou Terminal + QCM/QCU.
- **Scénarios (phishing, incident)** : Bloc **Scénario**.
- **Commande à taper / sortie** : Bloc **Terminal** (question + réponse attendue, sortie simulée).
- **Comparaison protocoles, options** : Bloc **Tableau**.

---

## 2. Développement (tous langages)

- **Code, snippets, debug** : Bloc **Code** (langage, coloration, Résoudre virtuellement).
- **Corriger le bug** : Code + QCU ou Texte à compléter.
- **Avant/après** : Deux blocs Code ou Image (diff).
- **Ordre des instructions** : Mettre dans l’ordre.
- **Sortie du programme** : Code + QCU.
- **Algorithme, pseudo-code, trace** : Bloc **Algorithme** (étapes numérotées + trace simulée).
- **Structures de données** : Algorithme ou Code + **Tableau** (comparaison) ou **Terme/Définition** (vocabulaire).
- **Git / CLI** : Terminal (question + réponse).
- **Logs, stack trace** : Code ou Terminal + QCM.
- **Glossaire (variable, fonction, boucle…)** : Bloc **Terme / Définition**.

---

## 3. DevOps

- **Pipeline** : Mettre dans l’ordre ou Liste.
- **Config YAML/JSON** : Code + QCU/QCM.
- **Scénario déploiement / rollback** : Scénario.
- **Commandes Docker / K8s** : Terminal.
- **Incident, runbook** : Scénario ou QCM.
- **Logs et diagnostic** : Terminal + QCU.
- **Comparaison outils (Ansible vs Terraform, etc.)** : Tableau.

---

## 4. Cybersécurité

- **Phishing, incident** : Scénario (choix d’actions avec feedback).
- **Bonnes pratiques** : Liste + QCM ou Scénario.
- **Pare-feu, règles** : Terminal ou Code + QCU.
- **Vocabulaire (XSS, CSRF, CVE, zero-day…)** : Terme / Définition.
- **Comparaison (types d’attaques, mesures)** : Tableau.

---

## 5. Algorithmique

- **Pseudo-code, étapes** : Bloc **Algorithme** (étapes + trace optionnelle).
- **Trace d’exécution** : Algorithme (trace simulée) ou Code + QCU (quelle valeur à l’étape N ?).
- **Ordre des étapes (tri, recherche)** : Mettre dans l’ordre.
- **Complexité, nombre d’opérations** : Réponse numérique + Paragraphe.
- **Comparaison algorithmes** : Tableau (nom, complexité, cas favorable/défavorable).

---

## 6. Bases de données

- **Requêtes SQL** : Code (langage SQL) + Terminal (sortie simulée) ou QCU (résultat attendu).
- **Schéma (tables, relations)** : Image + Paragraphe ou **Tableau** (colonnes, clés).
- **Comparaison SGBD, types de jointures** : Tableau.
- **Vocabulaire (clé primaire, index, transaction…)** : Terme / Définition.
- **Ordre des opérations (transaction, lock)** : Mettre dans l’ordre.

---

## 7. Système et administration

- **Commandes (Linux, Windows, scripts)** : Terminal.
- **Procédures (install, backup)** : Liste ou Mettre dans l’ordre.
- **Scénario de panne (disque plein, service down)** : Scénario.
- **Comparaison (services, daemons, options)** : Tableau.
- **Glossaire (processus, thread, syscall…)** : Terme / Définition.

---

## 8. Web (front-end, back-end, APIs)

- **HTML/CSS/JS** : Code (langage adapté) + Résoudre virtuellement.
- **Schéma client/serveur, API** : Image + Paragraphe.
- **Requête / réponse HTTP** : Terminal (sortie) ou Code + QCM.
- **Comparaison (méthodes HTTP, frameworks)** : Tableau.
- **Vocabulaire (REST, cookie, CORS…)** : Terme / Définition.

---

## 9. Cloud

- **Scénario (choix de service, coût, disponibilité)** : Scénario.
- **Commandes (CLI cloud provider)** : Terminal.
- **Config (Terraform, CloudFormation)** : Code.
- **Comparaison IaaS/PaaS/SaaS, offres** : Tableau.
- **Architecture (multi-AZ, load balancer)** : Image + Liste.

---

## 10. Matériel et architecture

- **Comparaison composants (CPU, RAM, stockage)** : Tableau.
- **Schéma (bus, couches)** : Image + Paragraphe.
- **Vocabulaire (cache, pipeline, core…)** : Terme / Définition.
- **QCM (quel composant pour quel besoin ?)** : QCM.

---

## Blocs dédiés dans l’app

| Bloc | Usage principal |
|------|------------------|
| **Code** | Snippets, SQL, config, logs ; coloration ; Résoudre virtuellement. |
| **Terminal** | Commandes, sortie simulée ; exercices « quelle commande ? ». |
| **Scénario** | Incident, sécurité, choix d’actions avec feedback. |
| **Tableau** | Comparaisons, tables de vérité, références (protocoles, commandes, options). |
| **Algorithme** | Étapes numérotées (pseudo-code), trace d’exécution simulée. |
| **Terme / Définition** | Glossaire, flashcards (vocabulaire technique). |

Ce document sert de base pour **maquettes de cours** et pour choisir le bon bloc selon le domaine et l’objectif pédagogique.
