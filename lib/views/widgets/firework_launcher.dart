import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/firework_result.dart';

class _Particle {
  final double angle;
  final double speed;
  final Color color;
  final double size;

  _Particle({required this.angle, required this.speed, required this.color, required this.size});
}

class _ExplosionPainter extends CustomPainter {
  final double progress;
  final List<_Particle> particles;
  final Offset center;

  _ExplosionPainter({required this.progress, required this.particles, required this.center});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final eased = Curves.easeOut.transform(progress);
      final dist = p.speed * eased * 130;
      final dx = center.dx + cos(p.angle) * dist;
      final dy = center.dy + sin(p.angle) * dist;
      final opacity = (1.0 - eased).clamp(0.0, 1.0);
      final radius = p.size * (1.0 - eased * 0.5);

      canvas.drawCircle(
        Offset(dx, dy),
        radius,
        Paint()
          ..color = p.color.withOpacity(opacity)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      );

      // tail
      canvas.drawLine(
        Offset(center.dx + cos(p.angle) * dist * 0.85, center.dy + sin(p.angle) * dist * 0.85),
        Offset(dx, dy),
        Paint()
          ..color = p.color.withOpacity(opacity * 0.4)
          ..strokeWidth = radius * 0.6
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_ExplosionPainter old) => old.progress != progress;
}

class FireworkLauncher extends StatefulWidget {
  final bool isLaunching;
  final bool isExploding;
  final FireworkColor? fireworkColor;

  const FireworkLauncher({
    super.key,
    required this.isLaunching,
    required this.isExploding,
    this.fireworkColor,
  });

  @override
  State<FireworkLauncher> createState() => _FireworkLauncherState();
}

class _FireworkLauncherState extends State<FireworkLauncher> with TickerProviderStateMixin {
  late AnimationController _launchCtrl;
  late AnimationController _explodeCtrl;
  late Animation<double> _launchY;
  late Animation<double> _launchOpacity;
  late Animation<double> _explodeProgress;
  late Animation<double> _glowScale;

  List<_Particle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    _launchCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100));
    _launchY = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _launchCtrl, curve: Curves.easeIn));
    _launchOpacity = Tween<double>(begin: 1.0, end: 0.0)
        .animate(CurvedAnimation(parent: _launchCtrl, curve: const Interval(0.7, 1.0)));

    _explodeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
    _explodeProgress = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _explodeCtrl, curve: Curves.easeOut));
    _glowScale = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _explodeCtrl, curve: const Interval(0.0, 0.3, curve: Curves.elasticOut)));
  }

  @override
  void didUpdateWidget(FireworkLauncher old) {
    super.didUpdateWidget(old);
    if (widget.isLaunching && !old.isLaunching) {
      _launchCtrl.forward(from: 0);
    }
    if (widget.isExploding && !old.isExploding) {
      _generateParticles();
      _explodeCtrl.forward(from: 0);
    }
    if (!widget.isLaunching && !widget.isExploding) {
      _launchCtrl.reset();
      _explodeCtrl.reset();
    }
  }

  void _generateParticles() {
    final colors = widget.fireworkColor?.particleColors ?? FireworkColor.blue.particleColors;
    final isRed = widget.fireworkColor == FireworkColor.red;
    final count = isRed ? 64 : 40;

    _particles = List.generate(count, (i) => _Particle(
      angle: (i / count) * 2 * pi + _random.nextDouble() * 0.3,
      speed: 0.6 + _random.nextDouble() * (isRed ? 1.1 : 0.7),
      color: colors[_random.nextInt(colors.length)],
      size: 2.0 + _random.nextDouble() * (isRed ? 5.0 : 3.5),
    ));
  }

  @override
  void dispose() {
    _launchCtrl.dispose();
    _explodeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final w = constraints.maxWidth;
      final h = constraints.maxHeight;
      final explosionCenter = Offset(w / 2, h * 0.28);

      return Stack(children: [
        // Rocket
        if (widget.isLaunching)
          AnimatedBuilder(
            animation: _launchCtrl,
            builder: (_, __) {
              final yPos = h * 0.85 - (_launchY.value * h * 0.6);
              final color = widget.fireworkColor?.glowColor ?? Colors.white;
              return Positioned(
                left: w / 2 - 5,
                top: yPos,
                child: Opacity(
                  opacity: _launchOpacity.value,
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                      width: 6,
                      height: 22,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.white, color],
                        ),
                        borderRadius: BorderRadius.circular(3),
                        boxShadow: [BoxShadow(color: color.withOpacity(0.8), blurRadius: 8, spreadRadius: 2)],
                      ),
                    ),
                    Container(
                      width: 4,
                      height: 10,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.orange.withOpacity(0.9), Colors.transparent],
                        ),
                      ),
                    ),
                  ]),
                ),
              );
            },
          ),

        // Explosion particles
        if (widget.isExploding)
          AnimatedBuilder(
            animation: _explodeCtrl,
            builder: (_, __) => CustomPaint(
              size: Size(w, h),
              painter: _ExplosionPainter(
                progress: _explodeProgress.value,
                particles: _particles,
                center: explosionCenter,
              ),
            ),
          ),

        // Glow center
        if (widget.isExploding)
          AnimatedBuilder(
            animation: _explodeCtrl,
            builder: (_, __) {
              final opacity = (1.0 - _explodeProgress.value).clamp(0.0, 1.0) * 0.85;
              final glow = widget.fireworkColor?.glowColor ?? Colors.white;
              return Positioned(
                left: explosionCenter.dx - 40,
                top: explosionCenter.dy - 40,
                child: Transform.scale(
                  scale: _glowScale.value,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: glow.withOpacity(opacity), blurRadius: 40, spreadRadius: 20)],
                      gradient: RadialGradient(colors: [
                        Colors.white.withOpacity(opacity),
                        glow.withOpacity(opacity * 0.5),
                        Colors.transparent,
                      ]),
                    ),
                  ),
                ),
              );
            },
          ),
      ]);
    });
  }
}
