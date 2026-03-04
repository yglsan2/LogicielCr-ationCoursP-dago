#!/usr/bin/env python
"""Script de gestion Django pour Createur de cours."""
import os
import sys

if __name__ == "__main__":
    os.environ.setdefault("DJANGO_SETTINGS_MODULE", "config.settings")
    try:
        from django.core.management import execute_from_command_line
    except ImportError as exc:
        raise ImportError(
            "Impossible d'importer Django. Êtes-vous dans un environnement virtuel ?"
        ) from exc
    execute_from_command_line(sys.argv)
