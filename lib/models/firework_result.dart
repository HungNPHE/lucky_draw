import 'package:flutter/material.dart';

/// Màu pháo hoa - đỏ hiếm nhất
enum FireworkColor {
  blue,   // 35%
  green,  // 30%
  gold,   // 20%
  purple, // 10%
  red,    //  5% - hiếm nhất
}

extension FireworkColorExt on FireworkColor {
  double get probability {
    switch (this) {
      case FireworkColor.blue:   return 0.35;
      case FireworkColor.green:  return 0.30;
      case FireworkColor.gold:   return 0.20;
      case FireworkColor.purple: return 0.10;
      case FireworkColor.red:    return 0.05;
    }
  }

  String get label {
    switch (this) {
      case FireworkColor.blue:   return 'Pháo Xanh';
      case FireworkColor.green:  return 'Pháo Lục';
      case FireworkColor.gold:   return 'Pháo Vàng';
      case FireworkColor.purple: return 'Pháo Tím';
      case FireworkColor.red:    return 'Pháo Đỏ ✨';
    }
  }

  String get luckyMessage {
    switch (this) {
      case FireworkColor.blue:   return 'Bình an vô sự';
      case FireworkColor.green:  return 'An khang thịnh vượng';
      case FireworkColor.gold:   return 'Tấn tài tấn lộc';
      case FireworkColor.purple: return 'Phú quý vinh hoa';
      case FireworkColor.red:    return '🎊 Đại cát đại lợi! 🎊';
    }
  }

  String get rarity {
    switch (this) {
      case FireworkColor.blue:   return 'Phổ thông';
      case FireworkColor.green:  return 'Phổ thông';
      case FireworkColor.gold:   return 'Hiếm';
      case FireworkColor.purple: return 'Rất hiếm';
      case FireworkColor.red:    return 'Siêu hiếm';
    }
  }

  List<Color> get particleColors {
    switch (this) {
      case FireworkColor.blue:
        return [const Color(0xFF4FC3F7), const Color(0xFF0288D1), const Color(0xFFB3E5FC), const Color(0xFF29B6F6)];
      case FireworkColor.green:
        return [const Color(0xFF66BB6A), const Color(0xFF2E7D32), const Color(0xFFA5D6A7), const Color(0xFF43A047)];
      case FireworkColor.gold:
        return [const Color(0xFFFFD700), const Color(0xFFFFA500), const Color(0xFFFFEC8B), const Color(0xFFC9A227)];
      case FireworkColor.purple:
        return [const Color(0xFFCE93D8), const Color(0xFF7B1FA2), const Color(0xFFE1BEE7), const Color(0xFFAB47BC)];
      case FireworkColor.red:
        return [const Color(0xFFFF5252), const Color(0xFFD50000), const Color(0xFFFF8A80), const Color(0xFFFFD700)];
    }
  }

  Color get glowColor {
    switch (this) {
      case FireworkColor.blue:   return const Color(0xFF29B6F6);
      case FireworkColor.green:  return const Color(0xFF43A047);
      case FireworkColor.gold:   return const Color(0xFFFFA500);
      case FireworkColor.purple: return const Color(0xFFAB47BC);
      case FireworkColor.red:    return const Color(0xFFFF5252);
    }
  }
}

class FireworkResult {
  final FireworkColor color;
  final DateTime timestamp;

  const FireworkResult({required this.color, required this.timestamp});
}
