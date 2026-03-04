import 'package:flutter/material.dart';
import '../models/course.dart';
import '../core/theme.dart';

/// Durées pour notes et silences.
const List<String> durationIds = [
  'whole', 'half', 'quarter', 'eighth', 'sixteenth', 'thirty_second',
  'dotted_whole', 'dotted_half', 'dotted_quarter', 'dotted_eighth',
  'double_dotted_half', 'double_dotted_quarter', 'double_dotted_eighth',
];

const Map<String, String> durationLabels = {
  'whole': 'Ronde',
  'half': 'Blanche',
  'quarter': 'Noire',
  'eighth': 'Croche',
  'sixteenth': 'Double croche',
  'thirty_second': 'Triple croche',
  'dotted_whole': 'Ronde pointée',
  'dotted_half': 'Blanche pointée',
  'dotted_quarter': 'Noire pointée',
  'dotted_eighth': 'Croche pointée',
  'double_dotted_half': 'Blanche double pointée',
  'double_dotted_quarter': 'Noire double pointée',
  'double_dotted_eighth': 'Croche double pointée',
};

/// Silences (noms français courants).
const Map<String, String> restLabels = {
  'whole': 'Pause',
  'half': 'Demi-pause',
  'quarter': 'Soupir',
  'eighth': 'Demi-soupir',
  'sixteenth': 'Quart de soupir',
  'thirty_second': 'Huitième de soupir',
  'dotted_whole': 'Pause pointée',
  'dotted_half': 'Demi-pause pointée',
  'dotted_quarter': 'Soupir pointé',
  'dotted_eighth': 'Demi-soupir pointé',
};

/// Layout de portées : 1 grande, 4 portées, ou piano (2 portées).
enum StaffLayout { single, four, piano }

/// Bloc partition : portées (1, 4 ou piano), clés soignées, notes, silences, déplacement hauteur.
class MusicNotationBlockTile extends StatefulWidget {
  const MusicNotationBlockTile({
    super.key,
    required this.block,
    required this.onPatch,
  });

  final Block block;
  final void Function(Map<String, dynamic> patch) onPatch;

  @override
  State<MusicNotationBlockTile> createState() => _MusicNotationBlockTileState();
}

class _MusicNotationBlockTileState extends State<MusicNotationBlockTile> {
  String get _staffLayoutKey =>
      widget.block.content['staffLayout'] as String? ?? 'single';
  StaffLayout get _staffLayout {
    switch (_staffLayoutKey) {
      case 'four':
        return StaffLayout.four;
      case 'piano':
        return StaffLayout.piano;
      default:
        return StaffLayout.single;
    }
  }

  String get _clef => widget.block.content['clef'] as String? ?? 'treble';
  String get _keySignature => widget.block.content['keySignature'] as String? ?? 'C';
  List<dynamic> get _items =>
      widget.block.content['items'] is List
          ? widget.block.content['items'] as List
          : (widget.block.content['notes'] is List
              ? (widget.block.content['notes'] as List)
                  .map((e) => {...?e as Map?, 'type': 'note'})
                  .toList()
              : []);
  String get _timeSignature =>
      widget.block.content['timeSignature'] as String? ?? '4/4';

  int? _selectedIndex;

  double get _staffHeight {
    switch (_staffLayout) {
      case StaffLayout.single:
        return 220;
      case StaffLayout.four:
        return 320;
      case StaffLayout.piano:
        return 200;
    }
  }

  void _updateItem(int index, Map<String, dynamic> patch) {
    final items =
        _items.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    while (items.length <= index) {
      items.add({'type': 'note', 'pitch': 'C4', 'duration': 'quarter'});
    }
    items[index].addAll(patch);
    widget.onPatch({'content': {...widget.block.content, 'items': items}});
  }

  void _addNote() {
    final items =
        _items.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    items.add({'type': 'note', 'pitch': 'C4', 'duration': 'quarter'});
    widget.onPatch({'content': {...widget.block.content, 'items': items}});
  }

  void _addRest() {
    final items =
        _items.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    items.add({'type': 'rest', 'duration': 'quarter'});
    widget.onPatch({'content': {...widget.block.content, 'items': items}});
  }

  void _removeItem(int index) {
    final items =
        _items.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    if (index < items.length) {
      items.removeAt(index);
      widget.onPatch({'content': {...widget.block.content, 'items': items}});
      if (_selectedIndex == index) {
        _selectedIndex = null;
      } else if (_selectedIndex != null && _selectedIndex! > index) {
        _selectedIndex = _selectedIndex! - 1;
      }
    }
  }

  String _yToPitch(double y, double centerY, double lineSpacing) {
    const order = ['C', 'D', 'E', 'F', 'G', 'A', 'B'];
    final halfStep = lineSpacing / 2;
    final dy = y - centerY;
    final steps = (dy / halfStep).round();
    final lineIndex = steps ~/ 2;
    final spaceOffset = steps % 2;
    final noteIndex = (7 - (lineIndex % 7) + 7) % 7;
    final octave = 4 + (lineIndex ~/ 7) - (lineIndex < 0 ? 1 : 0);
    return '${order[noteIndex]}$octave';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Text('Type de portée : ', style: TextStyle(fontSize: 13)),
              DropdownButton<String>(
                value: _staffLayoutKey,
                isDense: true,
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(value: 'single', child: Text('1 portée (grande)')),
                  DropdownMenuItem(value: 'four', child: Text('4 portées')),
                  DropdownMenuItem(value: 'piano', child: Text('Piano (2 portées doubles)')),
                ],
                onChanged: (v) {
                  if (v != null) {
                    widget.onPatch({'content': {...widget.block.content, 'staffLayout': v}});
                  }
                },
              ),
              const SizedBox(width: 16),
              if (_staffLayout == StaffLayout.single) ...[
                DropdownButton<String>(
                  value: _clef,
                  isDense: true,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: 'treble', child: Text('Clé de sol')),
                    DropdownMenuItem(value: 'bass', child: Text('Clé de fa')),
                  ],
                  onChanged: (v) {
                    if (v != null) {
                      widget.onPatch({'content': {...widget.block.content, 'clef': v}});
                    }
                  },
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _keySignature,
                  isDense: true,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: 'C', child: Text('Do')),
                    DropdownMenuItem(value: 'G', child: Text('Sol')),
                    DropdownMenuItem(value: 'D', child: Text('Ré')),
                    DropdownMenuItem(value: 'A', child: Text('La')),
                    DropdownMenuItem(value: 'E', child: Text('Mi')),
                    DropdownMenuItem(value: 'B', child: Text('Si')),
                    DropdownMenuItem(value: 'F', child: Text('Fa')),
                  ],
                  onChanged: (v) {
                    if (v != null) {
                      widget.onPatch({'content': {...widget.block.content, 'keySignature': v}});
                    }
                  },
                ),
              ],
              const Spacer(),
              FilledButton.icon(
                onPressed: _addNote,
                icon: const Icon(Icons.music_note_rounded, size: 18),
                label: const Text('Note'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: _addRest,
                icon: const Icon(Icons.music_off_rounded, size: 18),
                label: const Text('Silence'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                height: _staffHeight,
                decoration: BoxDecoration(
                  color: const Color(0xFFFDFBF7),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.brown.shade300),
                ),
                clipBehavior: Clip.antiAlias,
                child: GestureDetector(
                  onTapUp: (details) {
                    _staffHitTest(details.localPosition, constraints.maxWidth);
                  },
                  onVerticalDragUpdate: _selectedIndex != null
                      ? (details) {
                          _staffDragPitch(details.localPosition, constraints.maxWidth);
                        }
                      : null,
                  child: CustomPaint(
                    painter: _StaffPainter(
                      staffLayout: _staffLayout,
                      clef: _clef,
                      keySignature: _keySignature,
                      items: _items,
                      selectedIndex: _selectedIndex,
                    ),
                    size: Size(constraints.maxWidth, _staffHeight),
                  ),
                ),
              );
            },
          ),
          if (_items.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('Éléments',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(_items.length, (i) {
                final it = _items[i] is Map ? _items[i] as Map : <String, dynamic>{};
                final type = it['type'] as String? ?? 'note';
                final duration = it['duration'] as String? ?? 'quarter';
                final isSelected = _selectedIndex == i;
                return Material(
                  color: isSelected
                      ? AppTheme.primary.withValues(alpha: 0.15)
                      : AppTheme.surfaceVariant.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedIndex = _selectedIndex == i ? null : i;
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            type == 'rest'
                                ? Icons.music_off_rounded
                                : Icons.music_note_rounded,
                            size: 18,
                            color: AppTheme.primary,
                          ),
                          const SizedBox(width: 6),
                          if (type == 'note') ...[
                            DropdownButton<String>(
                              value: it['pitch'] as String? ?? 'C4',
                              isDense: true,
                              underline: const SizedBox(),
                              items: ['C3', 'D3', 'E3', 'F3', 'G3', 'A3', 'B3', 'C4', 'D4', 'E4', 'F4', 'G4', 'A4', 'B4', 'C5', 'D5', 'E5', 'F5', 'G5']
                                  .map((p) => DropdownMenuItem(
                                      value: p, child: Text(p)))
                                  .toList(),
                              onChanged: (v) {
                                if (v != null) _updateItem(i, {'pitch': v});
                              },
                            ),
                            DropdownButton<String>(
                              value: it['accidental'] ?? 'natural',
                              isDense: true,
                              underline: const SizedBox(),
                              items: const [
                                DropdownMenuItem(
                                    value: 'natural', child: Text('♮')),
                                DropdownMenuItem(
                                    value: 'sharp', child: Text('♯')),
                                DropdownMenuItem(
                                    value: 'flat', child: Text('♭')),
                              ],
                              onChanged: (v) {
                                _updateItem(
                                    i,
                                    {'accidental': v == 'natural' ? null : v});
                              },
                            ),
                          ],
                          DropdownButton<String>(
                            value: duration,
                            isDense: true,
                            underline: const SizedBox(),
                            items: durationIds
                                .map((d) => DropdownMenuItem(
                                      value: d,
                                      child: Text(
                                          type == 'rest'
                                              ? (restLabels[d] ?? durationLabels[d] ?? d)
                                              : (durationLabels[d] ?? d),
                                          style: const TextStyle(fontSize: 12)),
                                    ))
                                .toList(),
                            onChanged: (v) {
                              if (v != null) _updateItem(i, {'duration': v});
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, size: 18),
                            onPressed: () => _removeItem(i),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  double _centerYForStaff(double localDy) {
    final h = _staffHeight;
    switch (_staffLayout) {
      case StaffLayout.single:
        return h / 2;
      case StaffLayout.four:
        final band = h / 4;
        final index = (localDy / band).clamp(0, 3).toInt();
        return index * band + band / 2;
      case StaffLayout.piano:
        return localDy < h / 2 ? h / 4 : 3 * h / 4;
    }
  }

  void _staffHitTest(Offset local, double width) {
    final n = _items.length;
    if (n == 0) return;
    const lineSpacing = 14.0;
    final centerY = _centerYForStaff(local.dy);
    final left = 56.0;
    final step = (width - left - 24) / n.clamp(1, 64);
    for (int i = 0; i < n; i++) {
      final cx = left + i * step + step / 2;
      final it = _items[i] is Map ? _items[i] as Map : <String, dynamic>{};
      if (it['type'] == 'rest') continue;
      final pitch = it['pitch'] as String? ?? 'C4';
      final y = _pitchToY(pitch, centerY, lineSpacing);
      if ((local.dx - cx).abs() < step / 2 && (local.dy - y).abs() < 20) {
        setState(() => _selectedIndex = i);
        return;
      }
    }
    setState(() => _selectedIndex = null);
  }

  void _staffDragPitch(Offset local, double width) {
    if (_selectedIndex == null || _selectedIndex! >= _items.length) return;
    final it = _items[_selectedIndex!] as Map?;
    if (it == null || it['type'] == 'rest') return;
    const lineSpacing = 14.0;
    final centerY = _centerYForStaff(local.dy);
    final pitch = _yToPitch(local.dy, centerY, lineSpacing);
    _updateItem(_selectedIndex!, {'pitch': pitch});
  }

  double _pitchToY(String pitch, double centerY, double lineSpacing) {
    const order = ['C', 'D', 'E', 'F', 'G', 'A', 'B'];
    final note = pitch.length >= 2 ? pitch[0].toUpperCase() : 'C';
    final octave = pitch.length >= 2 ? int.tryParse(pitch.substring(1)) ?? 4 : 4;
    final noteIndex = order.indexOf(note);
    if (noteIndex < 0) return centerY;
    final semitones = (4 - octave) * 7 - noteIndex;
    return centerY + semitones * (lineSpacing / 2);
  }
}

/// Dessin des portées, clés (style propre), notes et silences.
class _StaffPainter extends CustomPainter {
  _StaffPainter({
    required this.staffLayout,
    required this.clef,
    required this.keySignature,
    required this.items,
    this.selectedIndex,
  });

  final StaffLayout staffLayout;
  final String clef;
  final String keySignature;
  final List<dynamic> items;
  final int? selectedIndex;

  static const double _lineSpacing = 14;
  static const int _lines = 5;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.brown.shade800
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

    switch (staffLayout) {
      case StaffLayout.single:
        _drawOneStaff(canvas, size, 0, size.height, paint, items, null);
        break;
      case StaffLayout.four:
        final h = size.height / 4;
        for (int i = 0; i < 4; i++) {
          _drawOneStaff(canvas, size, i * h, (i + 1) * h, paint,
              i == 0 ? items : [], null);
        }
        break;
      case StaffLayout.piano:
        final h = size.height / 2;
        _drawOneStaff(canvas, size, 0, h, paint, items, 'treble');
        _drawOneStaff(canvas, size, h, size.height, paint, [], 'bass');
        break;
    }
  }

  void _drawOneStaff(Canvas canvas, Size size, double top, double bottom,
      Paint linePaint, List<dynamic> staffItems, String? forceClef) {
    final staffHeight = bottom - top;
    final centerY = top + staffHeight / 2;
    final left = 44.0;
    final right = size.width - 16;

    for (int i = 0; i < _lines; i++) {
      final y = centerY - _lineSpacing * 2 + i * _lineSpacing;
      canvas.drawLine(Offset(left, y), Offset(right, y), linePaint);
    }

    final c = forceClef ?? clef;
    _drawClef(canvas, left, centerY, c);
    final n = staffItems.length;
    if (n == 0) return;
    final startX = left + 52;
    final step = (right - startX - 20) / n.clamp(1, 64);
    for (int i = 0; i < n; i++) {
      final it = staffItems[i] is Map ? staffItems[i] as Map : <String, dynamic>{};
      final x = startX + i * step;
      if (it['type'] == 'rest') {
        _drawRest(canvas, x, centerY, it['duration'] as String? ?? 'quarter');
      } else {
        final pitch = it['pitch'] as String? ?? 'C4';
        final y = _pitchToY(pitch, centerY);
        _drawNoteHead(canvas, x, y, selectedIndex == i);
      }
    }
  }

  void _drawClef(Canvas canvas, double x, double centerY, String clefType) {
    final p = Paint()
      ..color = Colors.brown.shade900
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    if (clefType == 'treble') {
      _drawTrebleClef(canvas, x, centerY, p);
    } else {
      _drawBassClef(canvas, x, centerY, p);
    }
  }

  /// Clé de sol (G) — forme type MuseScore / notation standard.
  void _drawTrebleClef(Canvas canvas, double x, double centerY, Paint p) {
    final path = Path();
    final s = _lineSpacing;
    final cx = x + 4;
    path.moveTo(cx + 2, centerY + s * 2.2);
    path.cubicTo(cx - 2, centerY + s * 1.2, cx - 2, centerY - s * 0.8, cx + 4, centerY - s * 1.8);
    path.cubicTo(cx + 10, centerY - s * 2.4, cx + 14, centerY - s * 1.6, cx + 12, centerY);
    path.cubicTo(cx + 10, centerY + s * 0.8, cx + 6, centerY + s * 1.4, cx + 2, centerY + s * 2.2);
    path.moveTo(cx + 12, centerY);
    path.cubicTo(cx + 16, centerY + s * 1.2, cx + 14, centerY + s * 2.2, cx + 10, centerY + s * 2.8);
    path.cubicTo(cx + 6, centerY + s * 3.2, cx + 2, centerY + s * 2.6, cx + 2, centerY + s * 2.2);
    canvas.drawPath(path, p);
    path.reset();
    path.moveTo(cx + 6, centerY - s * 2.6);
    path.lineTo(cx + 6, centerY + s * 2.8);
    canvas.drawPath(path, p);
  }

  /// Clé de fa (F) — avec les deux points.
  void _drawBassClef(Canvas canvas, double x, double centerY, Paint p) {
    final path = Path();
    final s = _lineSpacing;
    final cx = x + 10;
    final fLine = centerY + s * 0.8;
    path.moveTo(cx + 8, centerY - s * 1.2);
    path.cubicTo(cx + 2, centerY, cx + 2, centerY + s * 1.8, cx + 8, centerY + s * 2.4);
    path.cubicTo(cx + 14, centerY + s * 2.2, cx + 18, centerY + s * 0.6, cx + 16, fLine);
    path.moveTo(cx + 16, fLine);
    path.lineTo(cx + 4, fLine);
    path.moveTo(cx + 6, centerY - s * 1.2);
    path.lineTo(cx + 18, centerY + s * 2.4);
    canvas.drawPath(path, p);
    p.style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx + 4, fLine - 2), 2.2, p);
    canvas.drawCircle(Offset(cx + 12, fLine - 2), 2.2, p);
  }

  double _pitchToY(String pitch, double centerY) {
    const order = ['C', 'D', 'E', 'F', 'G', 'A', 'B'];
    final note = pitch.length >= 2 ? pitch[0].toUpperCase() : 'C';
    final octave = pitch.length >= 2 ? int.tryParse(pitch.substring(1)) ?? 4 : 4;
    final noteIndex = order.indexOf(note);
    if (noteIndex < 0) return centerY;
    final semitones = (4 - octave) * 7 - noteIndex;
    return centerY + semitones * (_lineSpacing / 2);
  }

  void _drawNoteHead(Canvas canvas, double x, double y, bool selected) {
    final p = Paint()
      ..color = selected ? Colors.blue.shade700 : Colors.brown.shade900
      ..style = PaintingStyle.fill;
    canvas.drawOval(Rect.fromCenter(center: Offset(x, y), width: 11, height: 8), p);
  }

  void _drawRest(Canvas canvas, double x, double centerY, String duration) {
    final stroke = Paint()
      ..color = Colors.brown.shade900
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    switch (duration) {
      case 'whole':
        canvas.drawRect(
            Rect.fromCenter(center: Offset(x, centerY - _lineSpacing), width: 14, height: 8), stroke);
        break;
      case 'half':
        canvas.drawRect(
            Rect.fromCenter(center: Offset(x, centerY), width: 14, height: 8), stroke);
        break;
      case 'quarter':
      case 'eighth':
      case 'sixteenth':
      case 'thirty_second':
        _drawQuarterRest(canvas, x, centerY, stroke);
        break;
      default:
        _drawQuarterRest(canvas, x, centerY, stroke);
    }
  }

  void _drawQuarterRest(Canvas canvas, double x, double centerY, Paint p) {
    final path = Path();
    path.moveTo(x + 4, centerY - _lineSpacing * 1.5);
    path.quadraticBezierTo(
        x + 10, centerY - _lineSpacing * 0.5, x + 6, centerY + _lineSpacing * 0.5);
    path.quadraticBezierTo(
        x + 2, centerY + _lineSpacing * 1.2, x + 8, centerY + _lineSpacing * 1.8);
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(covariant _StaffPainter old) =>
      old.staffLayout != staffLayout ||
      old.clef != clef ||
      old.keySignature != keySignature ||
      old.items != items ||
      old.selectedIndex != selectedIndex;
}
