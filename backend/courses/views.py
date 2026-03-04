"""
Vues API — endpoints clairs pour l'app Flutter.
Support PATCH pour auto-save. Réponses en français en cas d'erreur.
"""
from rest_framework import status, viewsets
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.parsers import JSONParser, MultiPartParser, FormParser

from django.db import models
from django.shortcuts import get_object_or_404
from django.http import FileResponse, HttpResponse

from .models import Course, Part, Block
from .serializers import (
    CourseListSerializer,
    CourseDetailSerializer,
    CourseWriteSerializer,
    PartSerializer,
    PartWriteSerializer,
    BlockSerializer,
)
from .exports import export_course_html, export_course_pdf


class CourseViewSet(viewsets.ModelViewSet):
    """Cours : liste, détail, création, mise à jour, suppression."""
    def get_queryset(self):
        return Course.objects.filter(author=self.request.user).prefetch_related(
            "parts__blocks"
        )

    def get_serializer_class(self):
        if self.action == "list":
            return CourseListSerializer
        if self.action in ("retrieve", "export_html", "export_pdf"):
            return CourseDetailSerializer
        return CourseWriteSerializer

    def perform_create(self, serializer):
        serializer.save(author=self.request.user)

    @action(detail=True, methods=["get"], url_path="export/html")
    def export_html(self, request, pk=None):
        """Export du cours en HTML (site web)."""
        course = self.get_object()
        try:
            html_content, _ = export_course_html(course)
            return HttpResponse(html_content, content_type="text/html; charset=utf-8")
        except Exception as e:
            return Response(
                {"detail": f"Erreur lors de l'export : {str(e)}"},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR,
            )

    @action(detail=True, methods=["get"], url_path="export/pdf")
    def export_pdf(self, request, pk=None):
        """Export du cours en PDF."""
        course = self.get_object()
        try:
            pdf_file, filename = export_course_pdf(course)
            return FileResponse(
                pdf_file,
                as_attachment=True,
                filename=filename,
                content_type="application/pdf",
            )
        except Exception as e:
            return Response(
                {"detail": f"Erreur lors de l'export PDF : {str(e)}"},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR,
            )


class PartViewSet(viewsets.ModelViewSet):
    """Parties d'un cours : CRUD + réordonnancement."""
    def get_queryset(self):
        return Part.objects.filter(course__author=self.request.user).prefetch_related(
            "blocks"
        )

    def get_serializer_class(self):
        if self.action in ("list", "retrieve"):
            return PartSerializer
        return PartWriteSerializer

    def create(self, request, *args, **kwargs):
        course_id = request.data.get("course")
        if not course_id:
            return Response(
                {"detail": "Le champ 'course' est requis."},
                status=status.HTTP_400_BAD_REQUEST,
            )
        course = get_object_or_404(Course, id=course_id, author=request.user)
        max_pos = course.parts.aggregate(max_pos=models.Max("position"))["max_pos"] or 0
        data = request.data.copy()
        if "position" not in data:
            data["position"] = max_pos + 1
        serializer = self.get_serializer(data=data)
        serializer.is_valid(raise_exception=True)
        serializer.save(course=course)
        return Response(serializer.data, status=status.HTTP_201_CREATED)


class BlockViewSet(viewsets.ModelViewSet):
    """Blocs d'une partie : CRUD. PATCH pour auto-save."""
    serializer_class = BlockSerializer

    def get_queryset(self):
        return Block.objects.filter(
            part__course__author=self.request.user
        ).select_related("part", "part__course")

    def create(self, request, *args, **kwargs):
        part_id = request.data.get("part")
        if not part_id:
            return Response(
                {"detail": "Le champ 'part' est requis."},
                status=status.HTTP_400_BAD_REQUEST,
            )
        part = get_object_or_404(
            Part, id=part_id, course__author=request.user
        )
        max_pos = part.blocks.aggregate(max_pos=models.Max("position"))["max_pos"] or 0
        data = request.data.copy()
        if "position" not in data:
            data["position"] = max_pos + 1
        serializer = self.get_serializer(data=data)
        serializer.is_valid(raise_exception=True)
        serializer.save(part=part)
        return Response(serializer.data, status=status.HTTP_201_CREATED)
