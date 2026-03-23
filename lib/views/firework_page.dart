import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/tet_theme.dart';
import '../models/firework_result.dart';
import '../viewmodels/firework_viewmodel.dart';
import 'widgets/firework_launcher.dart';

class FireworkPage extends StatelessWidget {
  const FireworkPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FireworkViewModel(),
      child: const _FireworkPageContent(),
    );
  }
}

class _FireworkPageContent extends StatelessWidget {
  const _FireworkPageContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF050510), Color(0xFF0A0A20), Color(0xFF0D0818)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              // Sky canvas
              const Expanded(child: _FireworkCanvas()),
              // Shoot button
              const _ShootButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                TetTheme.gold.withOpacity(0.9),
                TetTheme.goldLight.withOpacity(0.7),
              ]),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: TetTheme.gold.withOpacity(0.3), blurRadius: 8)],
            ),
            child: const Text('🎆', style: TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'PHÁO HOA MAY MẮN',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.5),
              ),
              Text(
                'Bắn pháo và xem màu may mắn của bạn',
                style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.5)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FireworkCanvas extends StatelessWidget {
  const _FireworkCanvas();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FireworkViewModel>();

    return Stack(children: [
      const _StarField(),

      FireworkLauncher(
        isLaunching: vm.isLaunching,
        isExploding: vm.isExploding,
        fireworkColor: vm.lastResult?.color,
      ),

      if (vm.showResult && vm.lastResult != null)
        _ResultOverlay(result: vm.lastResult!),
    ]);
  }
}

/// Nền sao tĩnh
class _StarField extends StatelessWidget {
  const _StarField();

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _StarPainter(), size: Size.infinite);
}

class _StarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.35);
    for (int i = 0; i < 60; i++) {
      final x = (i * 137.5 % 1.0) * size.width;
      final y = (i * 97.3 % 1.0) * size.height;
      canvas.drawCircle(Offset(x % size.width, y % size.height), 1.0, paint);
    }
  }

  @override
  bool shouldRepaint(_StarPainter old) => false;
}

/// Overlay kết quả
class _ResultOverlay extends StatefulWidget {
  final FireworkResult result;
  const _ResultOverlay({required this.result});

  @override
  State<_ResultOverlay> createState() => _ResultOverlayState();
}

class _ResultOverlayState extends State<_ResultOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _scale = Tween<double>(begin: 0.5, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _fade = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.read<FireworkViewModel>();
    final r = widget.result;
    final isRed = r.color == FireworkColor.red;

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Opacity(
        opacity: _fade.value,
        child: Transform.scale(
          scale: _scale.value,
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    r.color.glowColor.withOpacity(0.25),
                    const Color(0xFF0D0818).withOpacity(0.92),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: r.color.glowColor.withOpacity(0.5), width: 1.5),
                boxShadow: [
                  BoxShadow(color: r.color.glowColor.withOpacity(0.35), blurRadius: 30, spreadRadius: 4),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Rarity badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: r.color.glowColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: r.color.glowColor.withOpacity(0.4)),
                    ),
                    child: Text(
                      r.color.rarity.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: r.color.glowColor,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Color swatch
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(colors: [
                        r.color.particleColors.first,
                        r.color.glowColor,
                      ]),
                      boxShadow: [
                        BoxShadow(color: r.color.glowColor.withOpacity(0.6), blurRadius: 20, spreadRadius: 4),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  Text(
                    r.color.label,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: r.color.particleColors.first,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    r.color.luckyMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isRed ? 15 : 13,
                      color: Colors.white.withOpacity(isRed ? 0.9 : 0.65),
                      fontStyle: FontStyle.italic,
                      fontWeight: isRed ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),

                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: vm.reset,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: r.color.glowColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 6,
                      shadowColor: r.color.glowColor.withOpacity(0.5),
                    ),
                    child: const Text('Bắn tiếp', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Nút bắn pháo
class _ShootButton extends StatelessWidget {
  const _ShootButton();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FireworkViewModel>();
    final isActive = vm.phase != FireworkPhase.idle;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: isActive ? null : () => vm.shoot(),
          style: ElevatedButton.styleFrom(
            backgroundColor: isActive ? Colors.grey[800] : TetTheme.redPrimary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: isActive ? 0 : 10,
            shadowColor: TetTheme.redPrimary.withOpacity(0.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(isActive ? '✨' : '🚀', style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Text(
                isActive ? 'Đang bắn...' : 'BẮN PHÁO HOA',
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, letterSpacing: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
