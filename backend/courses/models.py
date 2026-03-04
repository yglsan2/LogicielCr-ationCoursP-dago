"""
Modèles — Createur de cours.
Hiérarchie : Cours → Partie → Bloc. Données lisibles, pas de XML.
"""
from django.conf import settings
from django.db import models


class Course(models.Model):
    """Conteneur racine : un cours (ex. Mathématiques 1re)."""
    title = models.CharField("Titre", max_length=255)
    description = models.TextField("Description", blank=True)
    author = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="courses",
        verbose_name="Auteur",
    )
    created_at = models.DateTimeField("Créé le", auto_now_add=True)
    updated_at = models.DateTimeField("Modifié le", auto_now=True)

    class Meta:
        ordering = ["-updated_at"]
        verbose_name = "Cours"
        verbose_name_plural = "Cours"

    def __str__(self):
        return self.title


class Part(models.Model):
    """Partie (module) d'un cours : regroupement thématique contenant des blocs."""
    course = models.ForeignKey(
        Course,
        on_delete=models.CASCADE,
        related_name="parts",
        verbose_name="Cours",
    )
    title = models.CharField("Titre de la partie", max_length=255)
    position = models.PositiveIntegerField("Position", default=0)
    # Champs optionnels (stratégie : pas au premier plan)
    objective = models.TextField("Objectif pédagogique", blank=True)
    prerequisites = models.TextField("Prérequis", blank=True)
    estimated_duration = models.CharField("Durée estimée", max_length=64, blank=True)
    created_at = models.DateTimeField("Créé le", auto_now_add=True)
    updated_at = models.DateTimeField("Modifié le", auto_now=True)

    class Meta:
        ordering = ["position", "id"]
        verbose_name = "Partie"
        verbose_name_plural = "Parties"

    def __str__(self):
        return f"{self.course.title} — {self.title}"


class Block(models.Model):
    """
    Bloc : unité de contenu ou d'activité.
    type + content (JSON) pour rester flexible sans multiplier les tables.
    """
    BLOCK_TYPES = [
        ("title", "Titre"),
        ("paragraph", "Paragraphe"),
        ("objective", "Objectif pédagogique"),
        ("list", "Liste"),
        ("image", "Image"),
        ("audio", "Audio"),
        ("video", "Vidéo"),
        ("qcu", "Question à une seule bonne réponse"),
        ("qcm", "Question à plusieurs bonnes réponses"),
        ("ordering", "Mettre dans l'ordre"),
        ("numeric", "Réponse numérique"),
        ("fill_blank", "Texte à compléter"),
        ("categorize", "Catégoriser"),
        ("code", "Bloc de code"),
        ("terminal", "Commande / Terminal"),
        ("scenario", "Scénario incident ou sécurité"),
        ("table", "Tableau"),
        ("algorithm", "Algorithme / Étapes"),
        ("term", "Terme / Définition"),
        ("whiteboard", "Tableau blanc"),
        ("music_notation", "Partition / Portée musicale"),
        ("highlight", "Surlignage fluo"),
    ]

    part = models.ForeignKey(
        Part,
        on_delete=models.CASCADE,
        related_name="blocks",
        verbose_name="Partie",
    )
    block_type = models.CharField(
        "Type de bloc",
        max_length=32,
        choices=BLOCK_TYPES,
    )
    content = models.JSONField("Contenu", default=dict, blank=True)
    position = models.PositiveIntegerField("Position", default=0)
    # Optionnel
    objective = models.TextField("Objectif", blank=True)
    estimated_duration = models.CharField("Durée estimée", max_length=64, blank=True)
    created_at = models.DateTimeField("Créé le", auto_now_add=True)
    updated_at = models.DateTimeField("Modifié le", auto_now=True)

    class Meta:
        ordering = ["position", "id"]
        verbose_name = "Bloc"
        verbose_name_plural = "Blocs"

    def __str__(self):
        return f"{self.get_block_type_display()} (pos. {self.position})"
