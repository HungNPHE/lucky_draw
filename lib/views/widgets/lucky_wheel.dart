import 'dart:math';
import 'package:flutter/material.dart';
import '../../theme/tet_theme.dart';

class LuckyWheel extends StatefulWidget {
  final bool isSpinning;
  final int? result;
  final List<int>? values;

  const LuckyWheel({
    super.key,
    required this.isSpinning,
    required this.result,
    this.values,
  });

  @override
  State<LuckyWheel> createState() => _LuckyWheelState();
}

class _LuckyWheelState extends State<LuckyWheel>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotation;

  // Lưu tổng số vòng quay để không bị "giật" khi quay nhiều lần
  double _baseTurns = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _rotation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.decelerate,
      ),
    );
  }

  @override
  void didUpdateWidget(covariant LuckyWheel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSpinning && !oldWidget.isSpinning) {
      final random = Random();
      final extraTurns = 4 + random.nextInt(4); // 4 -> 7 vòng

      final values = widget.values ?? const <int>[];
      final selected = widget.result;

      double? targetFraction;
      if (values.isNotEmpty && selected != null) {
        final i = values.indexOf(selected);
        if (i >= 0) {
          final n = values.length;
          // Pointer ở đỉnh (-pi/2). Segment bắt đầu từ -pi/2.
          // Muốn pointer trỏ vào trung tâm segment i khi kết thúc:
          // endTurns fractional part = (- (i + 0.5)/n) mod 1
          targetFraction = ((-(i + 0.5) / n) % 1 + 1) % 1;
        }
      }

      final start = _baseTurns;
      double end;
      if (targetFraction != null) {
        final startInt = start.floorToDouble();
        end = startInt + extraTurns + targetFraction;
        if (end <= start) {
          end += 1;
        }
      } else {
        // Fallback: quay ngẫu nhiên (range mode hoặc chưa có data hợp lệ)
        final offset = random.nextDouble(); // lệch thêm 0..1 vòng
        end = start + extraTurns + offset;
      }

      _rotation = Tween<double>(begin: start, end: end).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOutCubic,
        ),
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
    final values = widget.values ?? const <int>[];
    final hasValues = values.isNotEmpty;

    final centerLabel = widget.isSpinning
        ? "🎁"
        : (widget.result?.toString() ?? "🎁");

    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Vòng quay
          RotationTransition(
            turns: _rotation,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: TetTheme.gold, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: TetTheme.redPrimary.withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 4,
                  ),
                  BoxShadow(
                    color: TetTheme.gold.withOpacity(0.4),
                    blurRadius: 12,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: ClipOval(
                child: hasValues
                    ? CustomPaint(
                        painter: _LuckyWheelPainter(values: values),
                      )
                    : DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: SweepGradient(
                            colors: [
                              TetTheme.redPrimary,
                              TetTheme.gold,
                              TetTheme.goldLight,
                              TetTheme.redPrimary,
                            ],
                          ),
                        ),
                      ),
              ),
            ),
          ),

          // Hiển thị kết quả ở giữa (không xoay theo vòng)
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  TetTheme.cream,
                  TetTheme.gold.withOpacity(0.3),
                ],
              ),
              border: Border.all(color: TetTheme.gold, width: 4),
              boxShadow: [
                BoxShadow(
                  color: TetTheme.redDark.withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Center(
              child: Text(
                centerLabel,
                style: const TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.w800,
                  color: TetTheme.redDark,
                ),
              ),
            ),
          ),

          // Kim chỉ
          Positioned(
            top: 10,
            child: Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: TetTheme.gold,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: TetTheme.redDark.withOpacity(0.4),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
                CustomPaint(
                  size: const Size(14, 32),
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

class _PointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = TetTheme.gold
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..close();

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
      fontWeight: FontWeight.w700,
      fontSize: n <= 12 ? 14 : 12,
      shadows: const [
        Shadow(color: Colors.black45, blurRadius: 3),
        Shadow(color: TetTheme.redDark, blurRadius: 1),
      ],
    );

    final tetColors = [
      TetTheme.redPrimary,
      TetTheme.redDark,
      TetTheme.gold,
      Color.lerp(TetTheme.redPrimary, TetTheme.gold, 0.3)!,
      Color.lerp(TetTheme.redDark, TetTheme.gold, 0.2)!,
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

      final borderPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = TetTheme.gold.withOpacity(0.6);
      canvas.drawPath(path, borderPaint);

      final label = values[i].toString();
      final tp = TextPainter(
        text: TextSpan(text: label, style: textStyle),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();

      final angle = start + sweep / 2;
      final labelRadius = radius * 0.68;
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