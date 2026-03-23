import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../lucky_draw/presentation/viewmodels/lucky_draw_viewmodel.dart';
import '../../data/models/gacha_result.dart';
import '../../../../core/theme/tet_theme.dart';
import 'gacha_envelope.dart';
import 'gacha_result_display.dart';

/// Widget quay gacha bao lì xì
class GachaWheel extends StatefulWidget {
  const GachaWheel({super.key});

  @override
  State<GachaWheel> createState() => _GachaWheelState();
}

class _GachaWheelState extends State<GachaWheel>
    with TickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _shakeAnimation = Tween<double>(begin: -0.1, end: 0.1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticInOut),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LuckyDrawViewModel>();

    return Stack(
      children: [
        // Background glow effect
        Center(
          child: AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, child) {
              return Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      TetTheme.gold.withOpacity(_glowAnimation.value * 0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Main content
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Three envelopes - Yellow in middle, Green on right
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildEnvelopeSlot(
                  EnvelopeType.red,
                  vm.isSpinning,
                  vm.currentGachaResult?.envelopeType == EnvelopeType.red,
                ),
                _buildEnvelopeSlot(
                  EnvelopeType.yellow,  // Yellow in middle
                  vm.isSpinning,
                  vm.currentGachaResult?.envelopeType == EnvelopeType.yellow,
                ),
                _buildEnvelopeSlot(
                  EnvelopeType.green,  // Green on right
                  vm.isSpinning,
                  vm.currentGachaResult?.envelopeType == EnvelopeType.green,
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Probability indicators
            _buildProbabilitySection(),

            const SizedBox(height: 24),

            // Draw button
            _buildDrawButton(vm),
          ],
        ),

        // Result display overlay
        GachaResultDisplay(
          result: vm.currentGachaResult,
          isVisible: vm.isShowingGachaResult,
          onClose: () => vm.closeGachaResult(),
        ),
      ],
    );
  }

  Widget _buildEnvelopeSlot(
    EnvelopeType type,
    bool isSpinning,
    bool isSelected,
  ) {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.rotate(
          angle: isSpinning ? _shakeAnimation.value : 0,
          child: child,
        );
      },
      child: GachaEnvelope(
        envelopeType: type,
        isSelected: isSelected,
        size: 100,
      ),
    );
  }

  Widget _buildProbabilitySection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Text(
            'Tỷ lệ may mắn',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _ProbabilityChip(
                type: EnvelopeType.red,
                probability: 0.1,
              ),
              _ProbabilityChip(
                type: EnvelopeType.yellow,  // Yellow in middle
                probability: 0.30,
              ),
              _ProbabilityChip(
                type: EnvelopeType.green,  // Green on right
                probability: 0.60,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDrawButton(LuckyDrawViewModel vm) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            TetTheme.goldLight.withOpacity(0.95),
            TetTheme.gold.withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: TetTheme.gold.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: vm.isSpinning
              ? null
              : () async {
                  HapticFeedback.heavyImpact();
                  await vm.drawGacha();
                },
          child: Center(
            child: vm.isSpinning
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Đang quay...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white.withOpacity(0.9),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text('🎁', style: TextStyle(fontSize: 22)),
                      SizedBox(width: 10),
                      Text(
                        'QUAY NGAY',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: TetTheme.redDark,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _ProbabilityChip extends StatelessWidget {
  final EnvelopeType type;
  final double probability;

  const _ProbabilityChip({
    required this.type,
    required this.probability,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: type.color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: type.color.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                type.emoji,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(width: 4),
              Text(
                '${(probability * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 12,
                  color: type.color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          type.name.split(' ').last,
          style: TextStyle(
            fontSize: 11,
            color: type.color.withOpacity(0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
