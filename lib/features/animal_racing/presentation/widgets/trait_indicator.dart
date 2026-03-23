import 'package:flutter/material.dart';
import '../../data/models/racer.dart';

// Visual indicator showing animal's current state/trait
class TraitIndicator extends StatelessWidget {
  final Racer racer;
  final bool isRunning;

  const TraitIndicator({
    super.key,
    required this.racer,
    required this.isRunning,
  });

  @override
  Widget build(BuildContext context) {
    if (!isRunning) return const SizedBox.shrink();

    // Show special effects based on trait and current state
    List<Widget> indicators = [];

    // Burst energy indicator (Rabbit, Tiger)
    if (racer.trait == AnimalTrait.burst) {
      if (racer.burstEnergy < 30) {
        // Tired - needs rest
        indicators.add(_createStatusIcon('💤', Colors.blue.withOpacity(0.7)));
      } else if (racer.acceleration > 0.5) {
        // In burst mode!
        indicators.add(_createStatusIcon('⚡', Colors.yellow));
      }
    }

    // Pause indicator (Cat)
    if (racer.trait == AnimalTrait.paused && racer.isPaused) {
      indicators.add(_createStatusIcon('😼', Colors.orange.withOpacity(0.8)));
    }

    // Fatigue indicator (Pig, Cow)
    if (racer.trait == AnimalTrait.tiring) {
      if (racer.fatigue > 0.7) {
        indicators.add(_createStatusIcon('😮‍💨', Colors.red.withOpacity(0.6)));
      } else if (racer.fatigue > 0.4) {
        indicators.add(_createStatusIcon('💦', Colors.blue.withOpacity(0.5)));
      }
    }

    // Eratic behavior indicator (Chicken, Hamster)
    if (racer.trait == AnimalTrait.eratic) {
      if (racer.acceleration < -0.05) {
        indicators.add(_createStatusIcon('❓', Colors.purple.withOpacity(0.6)));
      } else if (racer.acceleration > 0.4) {
        indicators.add(_createStatusIcon('🎯', Colors.green.withOpacity(0.7)));
      }
    }

    // Slow start progress (Frog, Fox)
    if (racer.trait == AnimalTrait.slowStart) {
      if (racer.position > 0.7 && racer.acceleration > 0.2) {
        indicators.add(_createStatusIcon('🔥', Colors.red));
      }
    }

    if (indicators.isEmpty) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: indicators,
    );
  }

  Widget _createStatusIcon(String emoji, Color color) {
    return Container(
      margin: const EdgeInsets.only(left: 2),
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.3),
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        emoji,
        style: const TextStyle(fontSize: 12),
      ),
    );
  }
}
