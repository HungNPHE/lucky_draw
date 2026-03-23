import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../data/models/gacha_result.dart';

/// Widget hiển thị bao lì xì với animation đẹp mắt
class GachaEnvelope extends StatefulWidget {
  final EnvelopeType? envelopeType;
  final bool isSelected;
  final VoidCallback? onTap;
  final double size;

  const GachaEnvelope({
    super.key,
    this.envelopeType,
    this.isSelected = false,
    this.onTap,
    this.size = 120,
  });

  @override
  State<GachaEnvelope> createState() => _GachaEnvelopeState();
}

class _GachaEnvelopeState extends State<GachaEnvelope>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _pulseController;
  late Animation<double> _floatAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();

    // Floating animation
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _rotateAnimation = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    // Pulse animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final type = widget.envelopeType ?? EnvelopeType.yellow;

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _floatAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _floatAnimation.value),
            child: Transform.rotate(
              angle: _rotateAnimation.value * (widget.isSelected ? 0 : 1),
              child: Transform.scale(
                scale: widget.isSelected ? _pulseAnimation.value : 1.0,
                child: _buildEnvelope(type),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEnvelope(EnvelopeType type) {
    return Container(
      width: widget.size,
      height: widget.size * 1.2,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            type.gradientStart,
            type.gradientEnd,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: type.color.withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
          if (widget.isSelected)
            BoxShadow(
              color: Colors.white.withOpacity(0.3),
              blurRadius: 30,
              spreadRadius: 4,
              offset: const Offset(0, 0),
            ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative pattern
          Positioned.fill(
            child: CustomPaint(
              painter: _EnvelopePatternPainter(color: type.color),
            ),
          ),

          // Golden border
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFE8D179).withOpacity(0.6),
                width: 2,
              ),
            ),
          ),

          // Center content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '🧧',
                  style: const TextStyle(fontSize: 40),
                ),
                const SizedBox(height: 8),
                Text(
                  type.luckyText,  // Vietnamese lucky character specific to envelope type
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),

          // Sparkles when selected
          if (widget.isSelected) ...[
            Positioned(
              top: 8,
              left: 8,
              child: _Sparkle(size: 12),
            ),
            Positioned(
              top: 12,
              right: 8,
              child: _Sparkle(size: 8),
            ),
            Positioned(
              bottom: 12,
              left: 12,
              child: _Sparkle(size: 10),
            ),
            Positioned(
              bottom: 8,
              right: 12,
              child: _Sparkle(size: 14),
            ),
          ],
        ],
      ),
    );
  }
}

/// Painter để vẽ họa tiết trên bao lì xì
class _EnvelopePatternPainter extends CustomPainter {
  final Color color;

  _EnvelopePatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.3)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw decorative lines
    for (int i = 0; i < 5; i++) {
      final y = size.height * (i + 1) / 6;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Draw corner decorations
    final cornerSize = 20.0;
    canvas.drawRect(
      Rect.fromLTWH(8, 8, cornerSize, cornerSize),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(size.width - cornerSize - 8, 8, cornerSize, cornerSize),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(8, size.height - cornerSize - 8, cornerSize, cornerSize),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
          size.width - cornerSize - 8, size.height - cornerSize - 8, cornerSize, cornerSize),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Widget sparkles cho hiệu ứng lấp lánh
class _Sparkle extends StatefulWidget {
  final double size;

  const _Sparkle({required this.size});

  @override
  State<_Sparkle> createState() => _SparkleState();
}

class _SparkleState extends State<_Sparkle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Transform.rotate(
        angle: DateTime.now().millisecond / 1000.0 * 2 * math.pi,
        child: Icon(
          Icons.star,
          size: widget.size,
          color: Colors.white,
        ),
      ),
    );
  }
}
