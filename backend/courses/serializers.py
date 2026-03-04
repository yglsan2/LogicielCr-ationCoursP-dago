"""
Sérialiseurs REST — messages en français si besoin.
Support PATCH pour auto-save (mise à jour partielle).
"""
from rest_framework import serializers
from django.contrib.auth import get_user_model

from .models import Course, Part, Block

User = get_user_model()


class UserSerializer(serializers.ModelSerializer):
    """Utilisateur (pour affichage, pas de mot de passe)."""
    class Meta:
        model = User
        fields = ("id", "username", "email")
        read_only_fields = fields


class BlockSerializer(serializers.ModelSerializer):
    class Meta:
        model = Block
        fields = (
            "id",
            "block_type",
            "content",
            "position",
            "objective",
            "estimated_duration",
            "created_at",
            "updated_at",
        )
        read_only_fields = ("created_at", "updated_at")


class PartSerializer(serializers.ModelSerializer):
    blocks = BlockSerializer(many=True, read_only=True)

    class Meta:
        model = Part
        fields = (
            "id",
            "title",
            "position",
            "objective",
            "prerequisites",
            "estimated_duration",
            "blocks",
            "created_at",
            "updated_at",
        )
        read_only_fields = ("created_at", "updated_at")


class PartWriteSerializer(serializers.ModelSerializer):
    """Pour créer/éditer une partie sans nested blocks (éviter la complexité)."""
    class Meta:
        model = Part
        fields = (
            "id",
            "title",
            "position",
            "objective",
            "prerequisites",
            "estimated_duration",
            "created_at",
            "updated_at",
        )
        read_only_fields = ("created_at", "updated_at")


class CourseListSerializer(serializers.ModelSerializer):
    """Liste des cours : léger."""
    author = UserSerializer(read_only=True)

    class Meta:
        model = Course
        fields = ("id", "title", "description", "author", "updated_at")


class CourseDetailSerializer(serializers.ModelSerializer):
    """Détail d'un cours avec parties et blocs (pour l'éditeur)."""
    author = UserSerializer(read_only=True)
    parts = PartSerializer(many=True, read_only=True)

    class Meta:
        model = Course
        fields = (
            "id",
            "title",
            "description",
            "author",
            "parts",
            "created_at",
            "updated_at",
        )
        read_only_fields = ("created_at", "updated_at")


class CourseWriteSerializer(serializers.ModelSerializer):
    class Meta:
        model = Course
        fields = ("id", "title", "description", "created_at", "updated_at")
        read_only_fields = ("created_at", "updated_at")
