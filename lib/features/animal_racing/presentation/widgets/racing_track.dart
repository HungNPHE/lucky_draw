import 'package:flutter/material.dart';
import '../../data/models/racer.dart';
import '../../../../core/theme/tet_theme.dart';
import 'animal_racer.dart';

class RacingTrack extends StatelessWidget {
  final List<Racer> racers;
  final bool isRunning;
  final double progress;

  const RacingTrack({
    super.key,
    required this.racers,
    this.isRunning = false,
    this.progress = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final trackWidth = constraints.maxWidth - 32;
        
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: TetTheme.gold.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Track header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        TetTheme.redPrimary.withOpacity(0.3),
                        TetTheme.redPrimary.withOpacity(0.1),
                      ],
                    ),
                    border: Border(
                      bottom: BorderSide(
                        color: TetTheme.gold.withOpacity(0.2),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.flag_rounded,
                        color: TetTheme.gold.withOpacity(0.8),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Đường đua',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: TetTheme.gold.withOpacity(0.9),
                        ),
                      ),
                      const Spacer(),
                      if (isRunning)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.green.withOpacity(0.5),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Đang đua...',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                
                // Lanes
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    children: racers.asMap().entries.map((entry) {
                      final index = entry.key;
                      final racer = entry.value;
                      final isLast = index == racers.length - 1;
                      
                      return _Lane(
                        racer: racer,
                        laneWidth: trackWidth,
                        isRunning: isRunning,
                        isLast: isLast,
                        laneNumber: index + 1,
                      );
                    }).toList(),
                  ),
                ),
                
                // Finish line
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        TetTheme.gold.withOpacity(0.8),
                        TetTheme.goldLight,
                        TetTheme.gold.withOpacity(0.8),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: TetTheme.gold.withOpacity(0.3),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Lane extends StatelessWidget {
  final Racer racer;
  final double laneWidth;
  final bool isRunning;
  final bool isLast;
  final int laneNumber;

  const _Lane({
    required this.racer,
    required this.laneWidth,
    required this.isRunning,
    required this.isLast,
    required this.laneNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: racer.color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: racer.color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          // Lane background pattern
          Positioned.fill(
            child: CustomPaint(
              painter: _LanePatternPainter(
                color: racer.color.withOpacity(0.05),
              ),
            ),
          ),
          
          // Lane number
          Positioned(
            left: 8,
            top: 22,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: racer.color.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$laneNumber',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: racer.color.withOpacity(0.9),
                  ),
                ),
              ),
            ),
          ),
          
          // The racer
          Padding(
            padding: const EdgeInsets.only(left: 40),
            child: AnimalRacer(
              racer: racer,
              laneWidth: laneWidth - 80,
              showName: true,
              isRunning: isRunning,
            ),
          ),
          
          // Finish line indicator
          Positioned(
            right: 16,
            top: 0,
            bottom: 0,
            child: Container(
              width: 2,
              color: TetTheme.gold.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }
}

class _LanePatternPainter extends CustomPainter {
  final Color color;

  _LanePatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    
    // Draw diagonal lines
    const spacing = 20.0;
    for (double i = -size.height; i < size.width; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
