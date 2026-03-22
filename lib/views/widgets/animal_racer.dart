import 'package:flutter/material.dart';
import '../../models/racer.dart';
import '../../theme/tet_theme.dart';
import 'trait_indicator.dart';

class AnimalRacer extends StatelessWidget {
  final Racer racer;
  final double laneWidth;
  final bool showName;
  final bool isRunning;

  const AnimalRacer({
    super.key,
    required this.racer,
    required this.laneWidth,
    this.showName = true,
    this.isRunning = false,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate position in pixels
    final positionX = racer.position * (laneWidth - 70);
    
    return SizedBox(
      height: 70,
      child: Stack(
        children: [
          // Cloud effects when jumping or finishing
          if (racer.isJumping || (racer.isFinished && racer.jumpHeight > 0))
            Positioned(
              left: positionX + 10,
              top: 25 - (racer.jumpHeight * 30),
              child: _CloudEffects(isJumping: racer.isJumping, intensity: racer.speed),
            ),
          
          // Dust particles behind the racer
          if (isRunning && racer.speed > 0.2)
            Positioned(
              left: positionX - 30,
              top: 35,
              child: _DustParticles(intensity: racer.dustIntensity),
            ),
          
          // Speed lines
          if (isRunning && racer.speed > 0.4)
            Positioned(
              left: positionX - 60,
              top: 25,
              child: _SpeedLines(speed: racer.speed),
            ),
          
          // The racer with jump animation
          AnimatedPositioned(
            duration: const Duration(milliseconds: 16),
            curve: Curves.linear,
            left: positionX,
            top: 10 + racer.bounceOffset - (racer.jumpHeight * 30),
            child: Transform.rotate(
              angle: racer.headBobAngle,
              child: _RacerAvatar(racer: racer, isRunning: isRunning),
            ),
          ),
          
          // Tail wag indicator (visual effect on the side)
          if (isRunning && racer.tailWagAngle.abs() > 0.1)
            Positioned(
              left: positionX - 15,
              top: 25 + (racer.tailWagAngle * 20),
              child: Transform.rotate(
                angle: racer.tailWagAngle,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: racer.color.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          
          // Name tag
          if (showName)
            Positioned(
              left: positionX + 10,
              top: 50 - (racer.jumpHeight * 20),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      racer.name,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Trait status indicators
                  TraitIndicator(racer: racer, isRunning: isRunning),
                ],
              ),
            ),
          
          // Rank badge when finished
          if (racer.isFinished && racer.finishRank != null)
            Positioned(
              left: positionX + 45,
              top: 5,
              child: _RankBadge(rank: racer.finishRank!),
            ),
        ],
      ),
    );
  }
}

class _RacerAvatar extends StatelessWidget {
  final Racer racer;
  final bool isRunning;

  const _RacerAvatar({required this.racer, required this.isRunning});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      transform: Matrix4.identity()
        ..scale(
          1.0 + (racer.stretchFactor * 0.2).clamp(-0.15, 0.15),
          1.0 - (racer.stretchFactor * 0.1).clamp(-0.1, 0.1),
        ),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              racer.color.withOpacity(0.9),
              racer.color.withOpacity(0.6),
            ],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: racer.color.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
            if (racer.isJumping)
              BoxShadow(
                color: Colors.white.withOpacity(0.6),
                blurRadius: 15,
                spreadRadius: 3,
                offset: const Offset(0, 0),
              ),
          ],
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Center(
          child: AnimatedScale(
            scale: isRunning ? 1.1 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: Text(
              racer.emoji,
              style: TextStyle(
                fontSize: 28 + (racer.jumpHeight * 5),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DustParticles extends StatelessWidget {
  final double intensity;

  const _DustParticles({required this.intensity});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        final delay = index * 0.2;
        final size = 4.0 + (intensity * 4) - (index * 1.5);
        
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: EdgeInsets.only(right: 4 + (index * 2)),
          width: size.clamp(2, 8),
          height: size.clamp(2, 8),
          decoration: BoxDecoration(
            color: Colors.brown.withOpacity(0.4 - (index * 0.1)),
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}

class _SpeedLines extends StatelessWidget {
  final double speed;

  const _SpeedLines({required this.speed});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(2, (index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 4),
          width: 20 + (speed * 30),
          height: 2,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.0),
                Colors.white.withOpacity(0.3 - (index * 0.1)),
              ],
            ),
            borderRadius: BorderRadius.circular(1),
          ),
        );
      }),
    );
  }
}

class _RankBadge extends StatelessWidget {
  final int rank;

  const _RankBadge({required this.rank});

  Color get _badgeColor {
    switch (rank) {
      case 1:
        return TetTheme.gold;
      case 2:
        return Colors.grey.shade300;
      case 3:
        return Colors.orange.shade300;
      default:
        return Colors.white.withOpacity(0.6);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 500),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: _badgeColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: _badgeColor.withOpacity(0.5),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Center(
          child: Text(
            '#$rank',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: rank == 1 ? TetTheme.redDark : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}

class _CloudEffects extends StatelessWidget {
  final bool isJumping;
  final double intensity;

  const _CloudEffects({required this.isJumping, required this.intensity});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        final delay = index * 0.15;
        final size = 8.0 + (intensity * 6);
        
        return AnimatedOpacity(
          duration: Duration(milliseconds: (150 + (delay * 100)).toInt()),
          opacity: 0.6 - (index * 0.15),
          child: Container(
            margin: EdgeInsets.only(right: 6 + (index * 2)),
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: isJumping 
                  ? Colors.white.withOpacity(0.8 - (index * 0.2))
                  : Colors.grey.shade200.withOpacity(0.6 - (index * 0.15)),
              shape: BoxShape.circle,
            ),
          ),
        );
      }),
    );
  }
}
