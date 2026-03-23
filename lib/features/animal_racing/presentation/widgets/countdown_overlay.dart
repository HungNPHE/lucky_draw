import 'package:flutter/material.dart';
import '../../../../core/theme/tet_theme.dart';

class CountdownOverlay extends StatelessWidget {
  final int countdownValue;

  const CountdownOverlay({
    super.key,
    required this.countdownValue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return ScaleTransition(
              scale: animation,
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
          child: countdownValue > 0
              ? _CountdownNumber(key: ValueKey(countdownValue), value: countdownValue)
              : const _GoText(key: ValueKey('go')),
        ),
      ),
    );
  }
}

class _CountdownNumber extends StatelessWidget {
  final int value;

  const _CountdownNumber({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.5, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.elasticOut,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: ShakeAnimation(
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    TetTheme.redPrimary,
                    TetTheme.redPrimary.withOpacity(0.8),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: TetTheme.redPrimary.withOpacity(0.5),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                  BoxShadow(
                    color: TetTheme.gold.withOpacity(0.3),
                    blurRadius: 60,
                    spreadRadius: 20,
                  ),
                ],
                border: Border.all(
                  color: TetTheme.gold.withOpacity(0.5),
                  width: 4,
                ),
              ),
              child: Center(
                child: Text(
                  '$value',
                  style: const TextStyle(
                    fontSize: 80,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class ShakeAnimation extends StatefulWidget {
  final Widget child;

  const ShakeAnimation({super.key, required this.child});

  @override
  State<ShakeAnimation> createState() => _ShakeAnimationState();
}

class _ShakeAnimationState extends State<ShakeAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animation = Tween<double>(begin: -0.2, end: 0.2).chain(
      CurveTween(curve: Curves.easeInOut),
    ).animate(_controller);
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_animation.value * 10, 0),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _GoText extends StatelessWidget {
  const _GoText({super.key});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.elasticOut,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: PulseAnimation(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 30),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    TetTheme.goldLight,
                    TetTheme.gold,
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: TetTheme.gold.withOpacity(0.6),
                    blurRadius: 50,
                    spreadRadius: 15,
                  ),
                ],
              ),
              child: const Text(
                'GO!',
                style: TextStyle(
                  fontSize: 60,
                  fontWeight: FontWeight.w900,
                  color: TetTheme.redDark,
                  letterSpacing: 4,
                  shadows: [
                    Shadow(
                      color: Colors.white54,
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class PulseAnimation extends StatefulWidget {
  final Widget child;

  const PulseAnimation({super.key, required this.child});

  @override
  State<PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<PulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animation = Tween<double>(begin: 1.0, end: 1.15).chain(
      CurveTween(curve: Curves.easeInOut),
    ).animate(_controller);
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

// Alternative: Animated countdown with bouncing animals
class AnimatedCountdownOverlay extends StatefulWidget {
  final int countdownValue;
  final List<String> animalEmojis;

  const AnimatedCountdownOverlay({
    super.key,
    required this.countdownValue,
    required this.animalEmojis,
  });

  @override
  State<AnimatedCountdownOverlay> createState() => _AnimatedCountdownOverlayState();
}

class _AnimatedCountdownOverlayState extends State<AnimatedCountdownOverlay>
    with TickerProviderStateMixin {
  late List<AnimationController> _bounceControllers;

  @override
  void initState() {
    super.initState();
    _bounceControllers = List.generate(
      widget.animalEmojis.length,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      )..repeat(reverse: true),
    );
  }

  @override
  void dispose() {
    for (final controller in _bounceControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Stack(
        children: [
          // Background animated animals
          ...widget.animalEmojis.asMap().entries.map((entry) {
            final index = entry.key;
            final emoji = entry.value;
            final controller = _bounceControllers[index];
            
            return AnimatedBuilder(
              animation: controller,
              builder: (context, child) {
                return Positioned(
                  left: 50.0 + (index * 80),
                  bottom: 100 + (controller.value * 20),
                  child: Opacity(
                    opacity: 0.3,
                    child: Text(
                      emoji,
                      style: const TextStyle(fontSize: 40),
                    ),
                  ),
                );
              },
            );
          }),
          
          // Countdown
          Center(
            child: widget.countdownValue > 0
                ? _CountdownNumber(value: widget.countdownValue)
                : const _GoText(),
          ),
        ],
      ),
    );
  }
}
