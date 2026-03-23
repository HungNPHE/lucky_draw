import 'package:flutter/material.dart';
import '../../core/theme/tet_theme.dart';

class RuleDialog extends StatelessWidget {
  const RuleDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF1e0606),
          borderRadius: BorderRadius.circular(24),
          border:
          Border.all(color: TetTheme.gold.withOpacity(0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: TetTheme.redPrimary.withOpacity(0.3),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [TetTheme.gold, TetTheme.goldLight],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('🎯', style: TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 12),
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [TetTheme.goldLight, TetTheme.gold],
                  ).createShader(bounds),
                  child: const Text(
                    'Luật chơi',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _RuleItem(
              number: '1',
              title: 'Chọn chế độ quay',
              desc:
              'Quay theo khoảng: nhập giá trị nhỏ nhất và lớn nhất (VD: 1, 100).\n'
                  'Quay theo danh sách: nhập từng số (VD: 1, 5, 10, 50).',
            ),
            const SizedBox(height: 12),
            _RuleItem(
              number: '2',
              title: 'Nhập số dễ hơn',
              desc:
              'Gõ số rồi nhấn dấu phẩy (,), dấu cách hoặc Enter để xác nhận. '
                  'Nhấn ✕ trên mỗi tag để xóa.',
            ),
            const SizedBox(height: 12),
            _RuleItem(
              number: '3',
              title: 'Quay và nhận quà',
              desc:
              'Nhấn QUAY NGAY để nhận số may mắn. Số càng lớn → lì xì càng to 🧧',
            ),
            const SizedBox(height: 12),
            _RuleItem(
              number: '4',
              title: 'Quản lý lịch sử',
              desc:
              'Mỗi lượt quay được lưu bên dưới. Xóa toàn bộ bằng nút Xóa.',
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Đóng',
                    style: TextStyle(color: Colors.white.withOpacity(0.5)),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [TetTheme.redPrimary, Color(0xFFE0323A)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Đã hiểu!',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RuleItem extends StatelessWidget {
  final String number;
  final String title;
  final String desc;

  const _RuleItem({
    required this.number,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [TetTheme.redPrimary, Color(0xFFE0323A)],
            ),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: TetTheme.goldLight,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                desc,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}