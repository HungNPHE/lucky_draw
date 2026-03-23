import 'package:flutter/material.dart';
import '../../data/models/lucky_result.dart';
import '../../../../core/theme/tet_theme.dart';

class HistoryList extends StatelessWidget {
  final List<LuckyResult> history;

  const HistoryList({super.key, required this.history});

  static Widget buildTile({required LuckyResult item, int index = 0}) {
    final time = item.time;
    final timeStr =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}  '
        '${time.day.toString().padLeft(2, '0')}/${time.month.toString().padLeft(2, '0')}/${time.year}';

    // Màu medal cho top 3
    Color? medalColor;
    String? medalEmoji;
    if (index == 0) {
      medalColor = const Color(0xFFFFD700);
      medalEmoji = '🥇';
    } else if (index == 1) {
      medalColor = const Color(0xFFC0C0C0);
      medalEmoji = '🥈';
    } else if (index == 2) {
      medalColor = const Color(0xFFCD7F32);
      medalEmoji = '🥉';
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: index == 0 
            ? TetTheme.gold.withOpacity(0.06)
            : Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: index == 0
              ? TetTheme.gold.withOpacity(0.2)
              : Colors.white.withOpacity(0.06),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: medalEmoji != null
            ? Text(medalEmoji, style: const TextStyle(fontSize: 26))
            : Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: TetTheme.redPrimary.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${index + 1}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.4),
              ),
            ),
          ),
        ),
        title: RichText(
          text: TextSpan(
            children: [
              if (item.name != null && item.name!.isNotEmpty)
                TextSpan(
                  text: '${item.name}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withOpacity(0.9),
                    letterSpacing: 0.3,
                  ),
                )
              else
                TextSpan(
                  text: '${item.number}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: medalColor ?? TetTheme.goldLight,
                    letterSpacing: 0.5,
                  ),
                ),
            ],
          ),
        ),
        subtitle: Text(
          timeStr,
          style: TextStyle(
            fontSize: 11.5,
            color: Colors.white.withOpacity(0.35),
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: TetTheme.gold.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.card_giftcard_rounded,
            color: TetTheme.gold,
            size: 18,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: history.length,
        itemBuilder: (context, index) =>
            buildTile(item: history[index], index: index),
      ),
    );
  }
}