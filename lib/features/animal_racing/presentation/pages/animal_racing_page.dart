import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/tet_theme.dart';
import '../viewmodels/animal_racing_viewmodel.dart';
import '../widgets/racing_track.dart';
import '../widgets/racing_setup.dart';
import '../widgets/countdown_overlay.dart';
import '../widgets/racing_result.dart';

class AnimalRacingPage extends StatelessWidget {
  const AnimalRacingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AnimalRacingViewModel(),
      child: const _AnimalRacingPageContent(),
    );
  }
}

class _AnimalRacingPageContent extends StatelessWidget {
  const _AnimalRacingPageContent();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AnimalRacingViewModel>();
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              TetTheme.bgGradientStart,
              TetTheme.bgGradientMid,
              TetTheme.bgGradientEnd,
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Decorative background
              Positioned(
                top: -60,
                right: -60,
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: TetTheme.redPrimary.withOpacity(0.04),
                  ),
                ),
              ),
              Positioned(
                bottom: 100,
                left: -80,
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: TetTheme.gold.withOpacity(0.03),
                  ),
                ),
              ),
              
              // Main content
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: CustomScrollView(
                    slivers: [
                      // Header
                      SliverToBoxAdapter(
                        child: _buildHeader(context),
                      ),
                      
                      // Racing content based on state
                      if (vm.state == RacingState.setup)
                        SliverToBoxAdapter(
                          child: Column(
                            children: [
                              const SizedBox(height: 20),
                              RacingSetup(
                                racerCount: vm.racerCount,
                                racers: vm.racers,
                                onRacerCountChanged: vm.setRacerCount,
                                onRacerNameChanged: vm.updateRacerName,
                                onShuffle: vm.shuffleRacers,
                                onStart: () {
                                  HapticFeedback.heavyImpact();
                                  vm.startCountdown();
                                },
                              ),
                              const SizedBox(height: 20),
                              // Preview track
                              RacingTrack(
                                racers: vm.racers,
                                isRunning: false,
                              ),
                            ],
                          ),
                        ),
                      
                      if (vm.state == RacingState.racing ||
                          vm.state == RacingState.finished)
                        SliverToBoxAdapter(
                          child: Column(
                            children: [
                              const SizedBox(height: 20),
                              // Progress indicator
                              if (vm.state == RacingState.racing)
                                _buildProgressIndicator(vm),
                              const SizedBox(height: 16),
                              // Live track
                              RacingTrack(
                                racers: vm.racers,
                                isRunning: vm.state == RacingState.racing,
                              ),
                              const SizedBox(height: 20),
                              // Control buttons
                              if (vm.state == RacingState.finished)
                                _buildFinishedControls(context, vm),
                            ],
                          ),
                        ),
                      
                      const SliverToBoxAdapter(
                        child: SizedBox(height: 32),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Countdown overlay
              if (vm.state == RacingState.countdown)
                CountdownOverlay(countdownValue: vm.countdownValue),
              
              // Result dialog
              if (vm.state == RacingState.finished && vm.winner != null)
                RacingResult(
                  results: vm.results,
                  onPlayAgain: () {
                    vm.resetRace();
                    vm.startCountdown();
                  },
                  onClose: () {
                    vm.resetRace();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 16, 12),
      child: Row(
        children: [
          // Title
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  TetTheme.gold.withOpacity(0.9),
                  TetTheme.goldLight.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: TetTheme.gold.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Text('🏁', style: TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [TetTheme.goldLight, TetTheme.gold],
                  ).createShader(bounds),
                  child: const Text(
                    'Đua Thú',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Xem ai là ngườii chiến thắng! 🏆',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Colors.white.withOpacity(0.65),
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(AnimalRacingViewModel vm) {
    // Calculate average progress
    final avgProgress = vm.racers.fold<double>(0, (sum, r) => sum + r.position) /
        vm.racers.length;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tiến độ cuộc đua',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              Text(
                '${(avgProgress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: TetTheme.gold.withOpacity(0.9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: avgProgress,
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(
                TetTheme.gold.withOpacity(0.8),
              ),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          // Live positions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: vm.racers.map((racer) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    racer.emoji,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: racer.color.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${(racer.position * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          color: racer.color.withOpacity(0.9),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFinishedControls(BuildContext context, AnimalRacingViewModel vm) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => vm.resetRace(),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.settings_rounded,
                      color: Colors.white.withOpacity(0.7),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Thiết lập',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.heavyImpact();
                vm.resetRace();
                vm.startCountdown();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      TetTheme.goldLight,
                      TetTheme.gold,
                      TetTheme.goldDark,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: TetTheme.gold.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      '🏁',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'ĐUA LẠI',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: TetTheme.redDark,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
