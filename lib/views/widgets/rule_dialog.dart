import 'package:flutter/material.dart';
import '../../theme/tet_theme.dart';

class RuleDialog extends StatelessWidget {
  const RuleDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: TetTheme.gold.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text("🎯", style: TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 12),
          const Text(
            "Luật chơi",
            style: TextStyle(
              color: TetTheme.redDark,
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
        ],
      ),
      content: const Text(
        "1. Chọn chế độ quay:\n"
        "   • Quay theo khoảng: nhập 2 số (VD: 1 và 100) để random từ 1 đến 100.\n"
        "   • Quay theo danh sách: nhập danh sách số (VD: 1,10) để random một trong các số đó.\n"
        "2. Nhấn nút Quay ngay để nhận số may mắn.\n"
        "3. Số càng lớn lì xì càng nhiều 🧧\n"
        "4. Lịch sử sẽ được lưu bên dưới.",
        style: TextStyle(
          color: TetTheme.redDark,
          height: 1.5,
          fontSize: 15,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Đóng"),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: TetTheme.redPrimary,
            foregroundColor: Colors.white,
          ),
          child: const Text("Đã hiểu"),
        ),
      ],
    );
  }
}