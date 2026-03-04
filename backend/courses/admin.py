from django.contrib import admin
from .models import Course, Part, Block


class PartInline(admin.StackedInline):
    model = Part
    extra = 0
    ordering = ["position"]


@admin.register(Course)
class CourseAdmin(admin.ModelAdmin):
    list_display = ("title", "author", "updated_at")
    list_filter = ("updated_at",)
    search_fields = ("title",)
    inlines = [PartInline]


class BlockInline(admin.StackedInline):
    model = Block
    extra = 0
    ordering = ["position"]


@admin.register(Part)
class PartAdmin(admin.ModelAdmin):
    list_display = ("title", "course", "position", "updated_at")
    list_filter = ("course",)
    ordering = ["course", "position"]
    inlines = [BlockInline]


@admin.register(Block)
class BlockAdmin(admin.ModelAdmin):
    list_display = ("block_type", "part", "position", "updated_at")
    list_filter = ("block_type", "part__course")
    ordering = ["part", "position"]
