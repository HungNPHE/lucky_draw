import 'dart:math';
import 'package:flutter/material.dart';
import '../../theme/tet_theme.dart';

class LuckyWheel extends StatefulWidget {
  final bool isSpinning;
  final dynamic result;  // Có thể là int hoặc String
  final List<int>? values;  // Danh sách số (cho mode range)
  final List<String>? stringValues;  // Danh sách chuỗi (cho mode custom list)

  const LuckyWheel({
    super.key,
    required this.isSpinning,
    required this.result,
    this.values,
    this.stringValues,
  });

  @override
  State<LuckyWheel> createState() => _LuckyWheelState();
}

class _LuckyWheelState extends State<LuckyWheel>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotation;
  double _baseTurns = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    _rotation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.decelerate),
    );
  }

  @override
  void didUpdateWidget(covariant LuckyWheel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSpinning && !oldWidget.isSpinning) {
      final random = Random();
      final extraTurns = 4 + random.nextInt(4);

      // Ưu tiên stringValues nếu có
      final stringValues = widget.stringValues;
      final values = widget.values;
      final selected = widget.result;

      double? targetFraction;
      if (stringValues != null && stringValues.isNotEmpty && selected != null) {
        final i = stringValues.indexOf(selected.toString());
        if (i >= 0) {
          final n = stringValues.length;
          targetFraction = ((-(i + 0.5) / n) % 1 + 1) % 1;
        }
      } else if (values != null && values.isNotEmpty && selected != null) {
        final i = values.indexOf(selected is int ? selected : int.tryParse(selected.toString()) ?? 0);
        if (i >= 0) {
          final n = values.length;
          targetFraction = ((-(i + 0.5) / n) % 1 + 1) % 1;
        }
      }

      final start = _baseTurns;
      double end;
      if (targetFraction != null) {
        final startInt = start.floorToDouble();
        end = startInt + extraTurns + targetFraction;
        if (end <= start) end += 1;
      } else {
        final offset = random.nextDouble();
        end = start + extraTurns + offset;
      }

      _rotation = Tween<double>(begin: start, end: end).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );

      _controller
        ..reset()
        ..forward();

      _baseTurns = end;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stringValues = widget.stringValues;
    final intValues = widget.values;
    final hasStringValues = stringValues != null && stringValues.isNotEmpty;
    final hasIntValues = intValues != null && intValues.isNotEmpty;
    final hasValues = hasStringValues || hasIntValues;

    final isShowingResult = widget.result != null && !widget.isSpinning;
    final centerLabel = widget.isSpinning
        ? '🎡'
        : (isShowingResult ? widget.result!.toString() : '🎁');

    return SizedBox(
      width: 240,
      height: 240,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Glow ring behind wheel - dịu hơn
          Container(
            width: 224,
            height: 224,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: TetTheme.redPrimary.withOpacity(
                      widget.isSpinning ? 0.4 : 0.15),
                  blurRadius: widget.isSpinning ? 20 : 12,
                  spreadRadius: widget.isSpinning ? 4 : 1,
                ),
                BoxShadow(
                  color: TetTheme.gold.withOpacity(0.15),
                  blurRadius: 16,
                  spreadRadius: 0,
                ),
              ],
            ),
          ),

          // Spinning wheel
          RotationTransition(
            turns: _rotation,
            child: Container(
              width: 214,
              height: 214,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: TetTheme.gold,
                  width: 3,
                ),
              ),
              child: ClipOval(
                child: hasStringValues
                    ? CustomPaint(
                  painter: _StringWheelPainter(values: stringValues!),
                )
                    : hasIntValues
                    ? CustomPaint(
                  painter: _LuckyWheelPainter(values: intValues!),
                )
                    : _RangeModeWheel(isSpinning: widget.isSpinning),
              ),
            ),
          ),

          // Center circle
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: isShowingResult ? 110 : 100,
            height: isShowingResult ? 110 : 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: isShowingResult
                    ? [
                  const Color(0xFF2a0505),
                  const Color(0xFF1a0505),
                ]
                    : [
                  const Color(0xFF1a0505),
                  const Color(0xFF0d0202),
                ],
              ),
              border: Border.all(
                color: isShowingResult ? TetTheme.gold : TetTheme.gold.withOpacity(0.6),
                width: isShowingResult ? 3 : 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 10,
                ),
                if (isShowingResult)
                  BoxShadow(
                    color: TetTheme.gold.withOpacity(0.25),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
              ],
            ),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  centerLabel,
                  key: ValueKey(centerLabel),
                  style: TextStyle(
                    fontSize: isShowingResult &&
                        widget.result != null &&
                        (widget.result is int && widget.result! > 999)
                        ? 22
                        : isShowingResult
                        ? 30
                        : 32,
                    fontWeight: FontWeight.w900,
                    color: isShowingResult ? TetTheme.goldLight : Colors.white70,
                  ),
                ),
              ),
            ),
          ),

          // Pointer (kim)
          Positioned(
            top: 4,
            child: Column(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        TetTheme.goldLight.withOpacity(0.9),
                        TetTheme.gold.withOpacity(0.85),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.9), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: TetTheme.gold.withOpacity(0.3),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
                CustomPaint(
                  size: const Size(12, 28),
                  painter: _PointerPainter(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RangeModeWheel extends StatelessWidget {
  final bool isSpinning;
  const _RangeModeWheel({required this.isSpinning});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _RangeWheelPainter(isSpinning: isSpinning),
    );
  }
}

class _RangeWheelPainter extends CustomPainter {
  final bool isSpinning;
  const _RangeWheelPainter({required this.isSpinning});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;

    final segments = 8;
    final sweep = 2 * pi / segments;
    final colors = [
      const Color(0xFFC41E3A),  // Đỏ Tết đậm
      const Color(0xFF9A1B2C),  // Đỏ đậm hơn
      const Color(0xFFD4A520),  // Vàng đậm
      const Color(0xFFB8860B),  // Vàng đồng
      const Color(0xFFC41E3A),
      const Color(0xFF9A1B2C),
      const Color(0xFFD4A520),
      const Color(0xFFB8860B),
    ];

    for (int i = 0; i < segments; i++) {
      final start = -pi / 2 + i * sweep;
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = colors[i % colors.length];

      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..arcTo(
          Rect.fromCircle(center: center, radius: radius),
          start,
          sweep,
          false,
        )
        ..close();

      canvas.drawPath(path, paint);

      final borderPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = TetTheme.gold.withOpacity(0.4);
      canvas.drawPath(path, borderPaint);

      // Question marks
      final tp = TextPainter(
        text: TextSpan(
          text: '?',
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontWeight: FontWeight.w900,
            fontSize: 16,
            shadows: const [Shadow(color: Colors.black45, blurRadius: 4)],
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();

      final angle = start + sweep / 2;
      final labelRadius = radius * 0.65;
      final pos = Offset(
        center.dx + cos(angle) * labelRadius,
        center.dy + sin(angle) * labelRadius,
      );

      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(angle + pi / 2);
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _RangeWheelPainter oldDelegate) =>
      oldDelegate.isSpinning != isSpinning;
}

class _PointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [TetTheme.goldLight, TetTheme.gold],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final shadow = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(path, shadow);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LuckyWheelPainter extends CustomPainter {
  final List<int> values;
  const _LuckyWheelPainter({required this.values});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;
    final n = values.length;
    if (n == 0) return;

    final sweep = 2 * pi / n;
    final startBase = -pi / 2;

    final textStyle = TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w800,
      fontSize: n <= 6
          ? 18
          : n <= 10
          ? 15
          : n <= 14
          ? 12
          : 10,
      shadows: const [
        Shadow(color: Colors.black87, blurRadius: 3),
        Shadow(color: Colors.black45, blurRadius: 6),
      ],
    );

    final tetColors = [
      const Color(0xFFC41E3A),  // Đỏ Tết
      const Color(0xFF9A1B2C),  // Đỏ đậm
      const Color(0xFFD4A520),  // Vàng
      const Color(0xFFB8860B),  // Vàng đồng
      const Color(0xFFE85D5D),  // Đỏ nhạt
      const Color(0xFF7A1525),  // Đỏ sẫm
    ];

    for (var i = 0; i < n; i++) {
      final start = startBase + i * sweep;
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = tetColors[i % tetColors.length];

      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..arcTo(
          Rect.fromCircle(center: center, radius: radius),
          start,
          sweep,
          false,
        )
        ..close();

      canvas.drawPath(path, paint);

      // Subtle gradient overlay
      final overlayPaint = Paint()
        ..style = PaintingStyle.fill
        ..shader = RadialGradient(
          colors: [
            Colors.white.withOpacity(0.05),
            Colors.transparent,
          ],
          center: Alignment.topCenter,
        ).createShader(Rect.fromCircle(center: center, radius: radius));
      canvas.drawPath(path, overlayPaint);

      final borderPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = Colors.white.withOpacity(0.2);
      canvas.drawPath(path, borderPaint);

      // Draw text
      final label = values[i].toString();
      final textStyle = TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w800,
        fontSize: n <= 6
            ? 16
            : n <= 10
            ? 13
            : n <= 14
            ? 11
            : 9,
        shadows: const [
          Shadow(color: Colors.black87, blurRadius: 3),
          Shadow(color: Colors.black45, blurRadius: 6),
        ],
      );
      
      final tp = TextPainter(
        text: TextSpan(text: label, style: textStyle),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();

      final angle = start + sweep / 2;
      final labelRadius = radius * 0.66;
      final pos = Offset(
        center.dx + cos(angle) * labelRadius,
        center.dy + sin(angle) * labelRadius,
      );

      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(angle + pi / 2);
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _LuckyWheelPainter oldDelegate) {
    if (oldDelegate.values.length != values.length) return true;
    for (var i = 0; i < values.length; i++) {
      if (oldDelegate.values[i] != values[i]) return true;
    }
    return false;
  }
}

class _StringWheelPainter extends CustomPainter {
  final List<String> values;
  const _StringWheelPainter({required this.values});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;
    final n = values.length;
    if (n == 0) return;

    final sweep = 2 * pi / n;
    final startBase = -pi / 2;

    final tetColors = [
      const Color(0xFFC41E3A),  // Đỏ Tết
      const Color(0xFF9A1B2C),  // Đỏ đậm
      const Color(0xFFD4A520),  // Vàng
      const Color(0xFFB8860B),  // Vàng đồng
      const Color(0xFFE85D5D),  // Đỏ nhạt
      const Color(0xFF7A1525),  // Đỏ sẫm
    ];

    for (var i = 0; i < n; i++) {
      final start = startBase + i * sweep;
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = tetColors[i % tetColors.length];

      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..arcTo(
          Rect.fromCircle(center: center, radius: radius),
          start,
          sweep,
          false,
        )
        ..close();

      canvas.drawPath(path, paint);

      // Subtle gradient overlay
      final overlayPaint = Paint()
        ..style = PaintingStyle.fill
        ..shader = RadialGradient(
          colors: [
            Colors.white.withOpacity(0.05),
            Colors.transparent,
          ],
          center: Alignment.topCenter,
        ).createShader(Rect.fromCircle(center: center, radius: radius));
      canvas.drawPath(path, overlayPaint);

      final borderPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = Colors.white.withOpacity(0.2);
      canvas.drawPath(path, borderPaint);

      // Draw text
      final label = values[i];
      final textStyle = TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w800,
        fontSize: n <= 6
            ? 16
            : n <= 10
            ? 13
            : n <= 14
            ? 11
            : 9,
        shadows: const [
          Shadow(color: Colors.black87, blurRadius: 3),
          Shadow(color: Colors.black45, blurRadius: 6),
        ],
      );
      
      final tp = TextPainter(
        text: TextSpan(text: label, style: textStyle),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout();

      final angle = start + sweep / 2;
      final labelRadius = radius * 0.66;
      final pos = Offset(
        center.dx + cos(angle) * labelRadius,
        center.dy + sin(angle) * labelRadius,
      );

      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(angle + pi / 2);
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _StringWheelPainter oldDelegate) {
    if (oldDelegate.values.length != values.length) return true;
    for (var i = 0; i < values.length; i++) {
      if (oldDelegate.values[i] != values[i]) return true;
    }
    return false;
  }
}