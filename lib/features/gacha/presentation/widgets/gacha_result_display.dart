import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:confetti/confetti.dart';
import '../../data/models/gacha_result.dart';
import '../../../../core/theme/tet_theme.dart';

/// Widget hiển thị kết quả gacha với animation đẹp mắt
class GachaResultDisplay extends StatefulWidget {
  final GachaResult? result;
  final bool isVisible;
  final VoidCallback? onClose;

  const GachaResultDisplay({
    super.key,
    this.result,
    this.isVisible = false,
    this.onClose,
  });

  @override
  State<GachaResultDisplay> createState() => _GachaResultDisplayState();
}

class _GachaResultDisplayState extends State<GachaResultDisplay>
    with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _confettiController = ConfettiController(
      duration: const Duration(milliseconds: 3000),
    );

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _scaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(GachaResultDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isVisible && !oldWidget.isVisible && widget.result != null) {
      _showResult();
    } else if (!widget.isVisible && oldWidget.isVisible) {
      _hideResult();
    }
  }

  void _showResult() {
    HapticFeedback.heavyImpact();
    _confettiController.play();
    _scaleController.forward();
    _fadeController.forward();
  }

  void _hideResult() {
    _scaleController.reverse();
    _fadeController.reverse();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _scaleController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible || widget.result == null) {
      return const SizedBox.shrink();
    }

    return Stack(
      children: [
        // Confetti
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            emissionFrequency: 0.03,
            numberOfParticles: 40,
            maxBlastForce: 30,
            minBlastForce: 15,
            gravity: 0.2,
            colors: [
              TetTheme.redPrimary,
              const Color(0xFFE8D179),
              Colors.white,
              const Color(0xFFFF6B6B),
            ],
          ),
        ),

        // Result card
        Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: _buildResultCard(widget.result!),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultCard(GachaResult result) {
    return Container(
      margin: const EdgeInsets.all(20),
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            result.envelopeType.gradientStart.withOpacity(0.35),
            result.envelopeType.gradientEnd.withOpacity(0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: result.envelopeType.color.withOpacity(0.7),
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: result.envelopeType.color.withOpacity(0.6),
            blurRadius: 50,
            spreadRadius: 8,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 30,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Envelope emoji - Universal red envelope
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        result.envelopeType.gradientStart.withOpacity(0.9),
                        result.envelopeType.gradientEnd.withOpacity(0.95),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: result.envelopeType.color.withOpacity(0.6),
                        blurRadius: 25,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Text(
                    '🧧',
                    style: TextStyle(fontSize: 60),
                  ),
                ),
                const SizedBox(height: 20),

                // Title - Changed from envelope name
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [TetTheme.goldLight, TetTheme.gold],
                  ).createShader(bounds),
                  child: const Text(
                    'LÌ XÌ MAY MẮN',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Lucky message - Removed probability indicator
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: TetTheme.redPrimary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: TetTheme.redPrimary.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 16,
                        color: TetTheme.gold,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          _getLuckyMessage(result.envelopeType),
                          style: const TextStyle(
                            fontSize: 13,
                            color: TetTheme.gold,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Divider(
              color: TetTheme.gold.withOpacity(0.3),
              thickness: 1,
            ),
          ),

          // Good fortune section - Removed amount display
          Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Text(
                  'Phúc lộc đầu năm',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [TetTheme.goldLight, TetTheme.gold],
                  ).createShader(bounds),
                  child: const Text(
                    'VẠN SỰ NHƯ Ý',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Lucky message with Flexible to prevent overflow
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        TetTheme.redPrimary.withOpacity(0.2),
                        TetTheme.gold.withOpacity(0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: TetTheme.redPrimary.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('🎊 ', style: TextStyle(fontSize: 18)),
                      Flexible(
                        child: Text(
                          'Chúc mừng năm mới - Tấn tài tấn lộc!',
                          style: TextStyle(
                            fontSize: 14,
                            color: TetTheme.gold,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Close button
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: TetTheme.redPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
              ),
              onPressed: widget.onClose,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.celebration_rounded),
                  SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Nhận lộc may mắn!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getLuckyMessage(EnvelopeType type) {
    switch (type) {
      case EnvelopeType.red:
        return 'Đại cát đại lợi - Trăm sự như ý!';
      case EnvelopeType.green:
        return 'An khang thịnh vượng - Phúc lộc tràn đầy!';
      case EnvelopeType.yellow:
        return 'Tấn tài tấn lộc - Vàng bạc đầy nhà!';
    }
  }
}
