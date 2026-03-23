import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/tet_theme.dart';
import '../viewmodels/lucky_draw_viewmodel.dart';
import '../models/gacha_result.dart';
import 'widgets/gacha_wheel.dart';
import 'widgets/history_list.dart';

class GachaPage extends StatefulWidget {
  const GachaPage({super.key});

  @override
  State<GachaPage> createState() => _GachaPageState();
}

class _GachaPageState extends State<GachaPage> {
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LuckyDrawViewModel>();

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
          child: Column(
            children: [
              // Header
              _buildHeader(context),

              // Main content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Gacha wheel
                      const GachaWheel(),

                      const SizedBox(height: 24),

                      // History section
                      _buildHistorySection(vm),
                    ],
                  ),
                ),
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
          // Icon bao lì xì
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
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: TetTheme.gold.withOpacity(0.3),
                  blurRadius: 8,
                ),
              ],
            ),
            child: const Text(
              '🧧',
              style: TextStyle(fontSize: 24),
            ),
          ),
          const SizedBox(width: 12),
          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'LÌ XÌ MAY MẮN',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Chọn bao lì xì và nhận thưởng',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection(LuckyDrawViewModel vm) {
    if (vm.gachaHistory.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            const Text(
              '🎁',
              style: TextStyle(fontSize: 40),
            ),
            const SizedBox(height: 12),
            Text(
              'Chưa có lịch sử quay nào',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Hãy quay ngay để nhận phần thưởng!',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.4),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: TetTheme.gold,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Lịch sử quay',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: TetTheme.gold,
                letterSpacing: 0.3,
              ),
            ),
            const Spacer(),
            Text(
              '${vm.gachaHistory.length}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...vm.gachaHistory.take(10).map((result) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  result.envelopeType.color.withOpacity(0.2),
                  Colors.transparent,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: result.envelopeType.color.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Text(
                  '🧧',  // Universal red envelope emoji
                  style: TextStyle(fontSize: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Lì Xì May Mắn',  // Changed from result.envelopeType.name
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        _getLuckyMessage(result.envelopeType),  // Changed from currency display
                        style: const TextStyle(
                          fontSize: 12,
                          color: TetTheme.gold,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Text(
                  _formatTime(result.timestamp),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.4),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  String _formatCurrency(int amount) {
    return '₫${(amount / 1000).toStringAsFixed(0)}k';
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) {
      return 'Vừa xong';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}p trước';
    } else if (diff.inDays < 1) {
      return '${diff.inHours}h trước';
    } else {
      return '${time.day}/${time.month}';
    }
  }

  String _getLuckyMessage(EnvelopeType type) {
    switch (type) {
      case EnvelopeType.red:
        return 'Đại cát đại lợi';
      case EnvelopeType.green:
        return 'An khang thịnh vượng';
      case EnvelopeType.yellow:
        return 'Tấn tài tấn lộc';
    }
  }
}
