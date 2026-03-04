import 'package:flutter/material.dart';
import '../models/course.dart';
import '../core/theme.dart';

/// Bloc tableau blanc : dessin à main levée, sauvegardé sous forme de traits.
class WhiteboardBlockTile extends StatefulWidget {
  const WhiteboardBlockTile({
    super.key,
    required this.block,
    required this.onPatch,
  });

  final Block block;
  final void Function(Map<String, dynamic> patch) onPatch;

  @override
  State<WhiteboardBlockTile> createState() => _WhiteboardBlockTileState();
}

class _WhiteboardBlockTileState extends State<WhiteboardBlockTile> {
  List<List<Offset>> _strokes = [];
  bool _loaded = false;

  List<List<Offset>> _getStrokes() {
    if (_loaded) return _strokes;
    _loaded = true;
    final raw = widget.block.content['strokes'];
    if (raw is List) {
      _strokes = raw.map((stroke) {
        if (stroke is List) {
          return stroke.map((p) {
            if (p is Map && p['x'] != null && p['y'] != null) {
              return Offset((p['x'] as num).toDouble(), (p['y'] as num).toDouble());
            }
            return Offset.zero;
          }).toList();
        }
        return <Offset>[];
      }).toList();
    } else {
      _strokes = [];
    }
    return _strokes;
  }

  @override
  void didUpdateWidget(covariant WhiteboardBlockTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.block.content != widget.block.content) _loaded = false;
  }

  void _save() {
    final list = _strokes.map((stroke) {
      return stroke.map((p) => {'x': p.dx, 'y': p.dy}).toList();
    }).toList();
    widget.onPatch({'content': {...widget.block.content, 'strokes': list}});
  }

  @override
  Widget build(BuildContext context) {
    final strokes = _getStrokes();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Text(
              'Tableau blanc',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppTheme.onSurfaceVariant),
            ),
            const SizedBox(width: 8),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _strokes = [];
                  _loaded = true;
                  _save();
                });
              },
              icon: const Icon(Icons.delete_outline_rounded, size: 18),
              label: const Text('Effacer tout'),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 220,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: GestureDetector(
            onPanStart: (d) {
              setState(() {
                _strokes.add([d.localPosition]);
              });
            },
            onPanUpdate: (d) {
              setState(() {
                if (_strokes.isNotEmpty) {
                  _strokes.last.add(d.localPosition);
                }
              });
            },
            onPanEnd: (_) => _save(),
            child: CustomPaint(
              painter: _WhiteboardPainter(strokes: strokes),
              size: Size.infinite,
            ),
          ),
        ),
      ],
    );
  }
}

class _WhiteboardPainter extends CustomPainter {
  _WhiteboardPainter({required this.strokes});

  final List<List<Offset>> strokes;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (final stroke in strokes) {
      if (stroke.length < 2) continue;
      for (int i = 0; i < stroke.length - 1; i++) {
        canvas.drawLine(stroke[i], stroke[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _WhiteboardPainter old) => old.strokes != strokes;
}
