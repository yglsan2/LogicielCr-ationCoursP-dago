"""
Export des cours : HTML et PDF.
Services ciblés, pas de chaîne éditoriale lourde.
"""
import io
import re
from django.utils.text import slugify


def _sanitize_filename(title):
    """Nom de fichier sûr à partir du titre."""
    base = slugify(title) or "cours"
    return base[:100]


def _block_content_to_html(block):
    """Convertit le contenu d'un bloc en HTML selon son type."""
    t = block.block_type
    c = block.content or {}

    if t == "title":
        level = c.get("level", 2)
        return f"<h{min(level, 4)}>{c.get('text', '')}</h{min(level, 4)}>"
    if t == "paragraph":
        return f"<p>{c.get('text', '').replace(chr(10), '<br>')}</p>"
    if t == "objective":
        return f"<div class=\"objective\"><strong>Objectif :</strong> {c.get('text', '')}</div>"
    if t == "list":
        items = c.get("items", [])
        lis = "".join(f"<li>{x}</li>" for x in items)
        return f"<ul>{lis}</ul>"
    if t == "image":
        src = c.get("url") or c.get("src", "")
        alt = c.get("alt", "Image")
        return f"<figure><img src=\"{src}\" alt=\"{alt}\" /></figure>"
    if t == "video":
        url = c.get("url", "")
        return f"<p><a href=\"{url}\">Vidéo : {url}</a></p>"
    if t == "audio":
        url = c.get("url", "")
        return f"<p><a href=\"{url}\">Audio : {url}</a></p>"
    if t == "qcu":
        question = c.get("question", "")
        options = c.get("options", [])
        correct = c.get("correct_index", 0)
        opts = "".join(
            f"<li>{'✓ ' if i == correct else ''}{o}</li>"
            for i, o in enumerate(options)
        )
        return f"<div class=\"qcu\"><p>{question}</p><ul>{opts}</ul></div>"
    if t == "qcm":
        question = c.get("question", "")
        options = c.get("options", [])
        correct_indices = set(c.get("correct_indices", []))
        opts = "".join(
            f"<li>{'✓ ' if i in correct_indices else ''}{o}</li>"
            for i, o in enumerate(options)
        )
        return f"<div class=\"qcm\"><p>{question}</p><ul>{opts}</ul></div>"
    if t == "ordering":
        question = c.get("question", "")
        items = c.get("items", [])
        lis = "".join(f"<li>{x}</li>" for x in items)
        return f"<div class=\"ordering\"><p>{question}</p><ol>{lis}</ol></div>"
    if t == "numeric":
        question = c.get("question", "")
        answer = c.get("answer", "")
        return f"<div class=\"numeric\"><p>{question}</p><p>Réponse : {answer}</p></div>"
    if t == "fill_blank":
        text = c.get("text", "")
        return f"<p>{text.replace(chr(10), '<br>')}</p>"
    if t == "categorize":
        question = c.get("question", "")
        categories = c.get("categories", [])
        items = c.get("items", [])
        return f"<div class=\"categorize\"><p>{question}</p><p>Catégories : {', '.join(categories)}</p></div>"
    if t == "code":
        code = c.get("code", "")
        lang = c.get("language", "text")
        return f"<pre class=\"code-block\" data-language=\"{lang}\"><code>{_escape_html(code)}</code></pre>"
    if t == "terminal":
        lines = c.get("lines", [])
        prompt = c.get("prompt", "$ ")
        out = "".join(f"<span class=\"term-line\">{prompt}{_escape_html(str(line))}</span>\n" for line in lines)
        output = c.get("output", "")
        if output:
            out += f"<span class=\"term-output\">{_escape_html(output).replace(chr(10), '<br>')}</span>"
        return f"<pre class=\"terminal-block\">{out}</pre>"
    if t == "scenario":
        title = c.get("title", "")
        desc = c.get("description", "")
        choices = c.get("choices", [])
        lis = "".join(
            f"<li>{_escape_html(ch.get('text', '') if isinstance(ch, dict) else str(ch))}</li>"
            for ch in choices
        )
        return f"<div class=\"scenario-block\"><h4>{_escape_html(title)}</h4><p>{_escape_html(desc)}</p><ul>{lis}</ul></div>"
    if t == "table":
        headers = c.get("headers", [])
        rows = c.get("rows", [])
        if not headers and not rows:
            return "<p></p>"
        ths = "".join(f"<th>{_escape_html(str(h))}</th>" for h in (headers if headers else (rows[0] if rows else [])))
        thead = f"<thead><tr>{ths}</tr></thead>"
        rstart = 0 if headers else 1
        trs = "".join(
            f"<tr>{''.join(f'<td>{_escape_html(str(cell))}</td>' for cell in row)}</tr>"
            for row in (rows[rstart:] if headers and rows else rows)
        )
        return f"<div class=\"table-block\"><table>{thead}<tbody>{trs}</tbody></table></div>"
    if t == "algorithm":
        steps = c.get("steps", [])
        trace = c.get("trace", "")
        steps_html = "".join(f"<li>{_escape_html(str(s))}</li>" for s in steps)
        trace_html = f"<pre class=\"algorithm-trace\">{_escape_html(trace)}</pre>" if trace else ""
        return f"<div class=\"algorithm-block\"><ol>{steps_html}</ol>{trace_html}</div>"
    if t == "term":
        items = c.get("items", [])
        if not items:
            return "<p></p>"
        dl = "".join(
            f"<dt>{_escape_html(it.get('term', '') if isinstance(it, dict) else str(it))}</dt>"
            f"<dd>{_escape_html(it.get('definition', '') if isinstance(it, dict) else '')}</dd>"
            for it in items
        )
        return f"<dl class=\"term-block\">{dl}</dl>"
    if t == "whiteboard":
        strokes = c.get("strokes", [])
        if not strokes:
            return "<div class=\"whiteboard-block\"><p><em>Tableau blanc (vide)</em></p></div>"
        return "<div class=\"whiteboard-block\"><p><em>Tableau blanc (dessin non exporté en HTML)</em></p></div>"
    if t == "music_notation":
        clef = c.get("clef", "treble")
        key_sig = c.get("keySignature", "C")
        items = c.get("items", c.get("notes", []))
        parts = []
        for n in items if isinstance(n, dict):
            if n.get("type") == "rest":
                parts.append(f"silence ({n.get('duration', 'quarter')})")
            else:
                parts.append(f"{n.get('pitch', '?')} ({n.get('duration', 'quarter')})")
        return f"<div class=\"music-notation-block\"><p>Partition : clé {'de sol' if clef == 'treble' else 'de fa'}, armure {key_sig}. {_escape_html(', '.join(parts)) or '—'}</p></div>"
    if t == "highlight":
        text = c.get("text", "")
        color = c.get("color", "yellow")
        css_colors = {"yellow": "#fff59d", "green": "#c8e6c9", "pink": "#f8bbd9", "blue": "#bbdefb", "orange": "#ffe0b2"}
        bg = css_colors.get(color, "#fff59d")
        return f"<span class=\"highlight\" style=\"background:{bg};padding:0 2px;\">{_escape_html(text)}</span>"

    return f"<p>{c}</p>"


def _escape_html(s):
    return str(s).replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace('"', "&quot;")


def export_course_html(course):
    """Génère le HTML complet du cours (une page)."""
    parts_html = []
    for part in course.parts.prefetch_related("blocks").order_by("position"):
        blocks_html = []
        for block in part.blocks.order_by("position"):
            blocks_html.append(_block_content_to_html(block))
        part_html = f"""
        <section class="part">
            <h2>{part.title}</h2>
            {"".join(blocks_html)}
        </section>
        """
        parts_html.append(part_html)

    html = f"""<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>{course.title}</title>
    <style>
        body {{ font-family: system-ui, sans-serif; max-width: 720px; margin: 0 auto; padding: 1rem; line-height: 1.5; }}
        .part {{ margin-bottom: 2rem; }}
        .objective {{ background: #f0f4ff; padding: 0.5rem 1rem; border-radius: 6px; margin: 1rem 0; }}
    .qcu, .qcm {{ margin: 1rem 0; padding-left: 1rem; }}
    ul, ol {{ margin: 0.5rem 0; }}
    img {{ max-width: 100%; height: auto; }}
    .code-block {{ background: #1e1e1e; color: #d4d4d4; padding: 1rem; border-radius: 8px; overflow-x: auto; font-family: monospace; font-size: 13px; line-height: 1.4; }}
    .terminal-block {{ background: #1e1e1e; color: #9cdcfe; padding: 1rem; border-radius: 8px; overflow-x: auto; font-family: monospace; font-size: 13px; line-height: 1.5; }}
    .terminal-block .term-output {{ color: #ce9178; }}
    .scenario-block {{ background: #f8f9fa; padding: 1rem; border-radius: 8px; border-left: 4px solid #2563eb; margin: 1rem 0; }}
    .table-block {{ overflow-x: auto; margin: 1rem 0; }}
    .table-block table {{ border-collapse: collapse; width: 100%; }}
    .table-block th, .table-block td {{ border: 1px solid #e2e8f0; padding: 0.5rem 0.75rem; text-align: left; }}
    .table-block th {{ background: #f1f5f9; font-weight: 600; }}
    .algorithm-block {{ margin: 1rem 0; }}
    .algorithm-block ol {{ padding-left: 1.5rem; }}
    .algorithm-trace {{ background: #1e1e1e; color: #d4d4d4; padding: 0.75rem; border-radius: 6px; font-family: monospace; font-size: 12px; margin-top: 0.5rem; }}
    .term-block dt {{ font-weight: 600; color: #1e293b; margin-top: 0.75rem; }}
    .term-block dd {{ margin-left: 1rem; color: #475569; }}
    </style>
</head>
<body>
    <h1>{course.title}</h1>
    {course.description and f'<p class="description">{course.description}</p>' or ''}
    {"".join(parts_html)}
</body>
</html>"""
    filename = _sanitize_filename(course.title) + ".html"
    return html, filename


def export_course_pdf(course):
    """Génère le PDF du cours via WeasyPrint."""
    try:
        from weasyprint import HTML
        from weasyprint.text.fonts import FontConfiguration
    except ImportError:
        raise RuntimeError(
            "L'export PDF nécessite WeasyPrint. Installez avec : pip install weasyprint"
        )

    html_content, _ = export_course_html(course)
    font_config = FontConfiguration()
    html_doc = HTML(string=html_content)
    pdf_buffer = io.BytesIO()
    html_doc.write_pdf(pdf_buffer, font_config=font_config)
    pdf_buffer.seek(0)
    filename = _sanitize_filename(course.title) + ".pdf"
    return pdf_buffer, filename
