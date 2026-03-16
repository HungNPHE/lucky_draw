import 'package:flutter/material.dart';
import '../../models/lucky_result.dart';
import '../../theme/tet_theme.dart';

class HistoryList extends StatelessWidget {
  final List<LuckyResult> history;

  const HistoryList({super.key, required this.history});

  static Widget buildTile({required LuckyResult item}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: TetTheme.redPrimary.withOpacity(0.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: TetTheme.gold.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.card_giftcard_rounded,
              color: TetTheme.redPrimary, size: 24),
        ),
        title: Text(
          "Số may mắn: ${item.number}",
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: TetTheme.redDark,
          ),
        ),
        subtitle: Text(
          item.time.toString(),
          style: TextStyle(
            fontSize: 12,
            color: TetTheme.redDark.withOpacity(0.7),
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
        itemBuilder: (context, index) => buildTile(item: history[index]),
      ),
    );
  }
}