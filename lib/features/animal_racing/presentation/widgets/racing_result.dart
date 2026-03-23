import 'dart:math';

import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../../data/models/racer.dart';
import '../../../../core/theme/tet_theme.dart';

class RacingResult extends StatefulWidget {
  final List<Racer> results;
  final VoidCallback onPlayAgain;
  final VoidCallback onClose;

  const RacingResult({
    super.key,
    required this.results,
    required this.onPlayAgain,
    required this.onClose,
  });

  @override
  State<RacingResult> createState() => _RacingResultState();
}

class _RacingResultState extends State<RacingResult> with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _celebrationController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 5), // Increased from 3 to 5 seconds
    );
    _confettiController.play();
    
    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _bounceAnimation = Tween<double>(begin: 0.0, end: 1.0).chain(
      CurveTween(curve: Curves.elasticOut),
    ).animate(_celebrationController);
    _celebrationController.forward();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _celebrationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final winner = widget.results.isNotEmpty ? widget.results.first : null;
    
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF2a0a0a),
              const Color(0xFF1a0505),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: TetTheme.gold.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 30,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Confetti
              Positioned.fill(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConfettiWidget(
                    confettiController: _confettiController,
                    blastDirectionality: BlastDirectionality.explosive,
                    shouldLoop: false,
                    emissionFrequency: 0.05,
                    numberOfParticles: 50,
                    maxBlastForce: 30,
                    minBlastForce: 15,
                    gravity: 0.3,
                    colors: const [
                      TetTheme.redPrimary,
                      TetTheme.gold,
                      TetTheme.goldLight,
                      Colors.yellow,
                      Colors.white,
                      Color(0xFFFF6B6B),
                    ],
                  ),
                ),
              ),
              
              // Content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Trophy icon with bounce animation
                    ScaleTransition(
                      scale: _bounceAnimation,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              TetTheme.gold.withOpacity(0.3),
                              TetTheme.gold.withOpacity(0.1),
                            ],
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: TetTheme.gold.withOpacity(0.5),
                            width: 2,
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            '🏆',
                            style: TextStyle(fontSize: 40),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Winner announcement with sparkle effect
                    const Text(
                      'CHÚC MỪNG!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: TetTheme.gold,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SparkleText(
                      text: 'Người chiến thắng',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Winner display
                    if (winner != null)
                      ScaleTransition(
                        scale: _bounceAnimation,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 20,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                TetTheme.gold.withOpacity(0.2),
                                TetTheme.gold.withOpacity(0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: TetTheme.gold.withOpacity(0.4),
                              width: 2,
                            ),
                          ),
                          child: Column(
                            children: [
                              JubilationAnimation(emoji: winner.emoji),
                              const SizedBox(height: 8),
                              Text(
                                winner.name,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: TetTheme.gold,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  '#1',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    color: TetTheme.redDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    
                    const SizedBox(height: 24),
                    
                    // Results list
                    if (widget.results.length > 1)
                      Container(
                        constraints: const BoxConstraints(maxHeight: 150),
                        child: SingleChildScrollView(
                          child: Column(
                            children: widget.results
                                .skip(1)
                                .map((racer) => _ResultItem(racer: racer))
                                .toList(),
                          ),
                        ),
                      ),
                    
                    const SizedBox(height: 24),
                    
                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: widget.onClose,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                ),
                              ),
                              child: const Center(
                                child: Text(
                                  'ĐÓNG',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: widget.onPlayAgain,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    TetTheme.redPrimary,
                                    Color(0xFFE0323A),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: TetTheme.redPrimary.withOpacity(0.3),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Text(
                                  'CHƠI LẠI',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultItem extends StatelessWidget {
  final Racer racer;

  const _ResultItem({required this.racer});

  Color get _rankColor {
    switch (racer.finishRank) {
      case 2:
        return Colors.grey.shade300;
      case 3:
        return Colors.orange.shade300;
      default:
        return Colors.white.withOpacity(0.5);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: _rankColor.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '#${racer.finishRank}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _rankColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            racer.emoji,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              racer.name,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.8),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// Sparkle text effect for celebration
class SparkleText extends StatefulWidget {
  final String text;
  final TextStyle style;

  const SparkleText({super.key, required this.text, required this.style});

  @override
  State<SparkleText> createState() => _SparkleTextState();
}

class _SparkleTextState extends State<SparkleText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final opacity = 0.6 + (sin(_controller.value * 2 * 3.14159) * 0.2);
        return Opacity(
          opacity: opacity,
          child: Text(widget.text, style: widget.style),
        );
      },
    );
  }
}

// Jubilation animation - animal jumps and celebrates
class JubilationAnimation extends StatefulWidget {
  final String emoji;

  const JubilationAnimation({super.key, required this.emoji});

  @override
  State<JubilationAnimation> createState() => _JubilationAnimationState();
}

class _JubilationAnimationState extends State<JubilationAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _jumpAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _jumpAnimation = Tween<double>(begin: 0.0, end: 1.0).chain(
      CurveTween(curve: Curves.easeInOut),
    ).animate(_controller);
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).chain(
      CurveTween(curve: Curves.elasticOut),
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
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -_jumpAnimation.value * 20),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Text(
              widget.emoji,
              style: const TextStyle(fontSize: 50),
            ),
          ),
        );
      },
    );
  }
}
