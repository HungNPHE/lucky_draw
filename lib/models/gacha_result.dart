import 'package:flutter/material.dart';
import 'dart:math';

/// Kết quả quay gacha
class GachaResult {
  final EnvelopeType envelopeType;
  final int amount;
  final DateTime timestamp;

  GachaResult({
    required this.envelopeType,
    required this.amount,
    required this.timestamp,
  });
}

/// Các loại bao lì xì
enum EnvelopeType {
  red,    // Đỏ - hiếm nhất (10%)
  green,  // Xanh lá cây - phổ biến nhất (60%)
  yellow, // Vàng - phổ biến vừa (30%)
}

/// Extension để lấy thông tin envelope
extension EnvelopeTypeExtension on EnvelopeType {
  String get name {
    switch (this) {
      case EnvelopeType.red:
        return 'Bao Đỏ';
      case EnvelopeType.green:
        return 'Bao Xanh';
      case EnvelopeType.yellow:
        return 'Bao Vàng';
    }
  }

  String get emoji {
    switch (this) {
      case EnvelopeType.red:
        return '🧧';
      case EnvelopeType.green:
        return '💚';
      case EnvelopeType.yellow:
        return '💛';
    }
  }

  Color get color {
    switch (this) {
      case EnvelopeType.red:
        return const Color(0xFFE85D5D);
      case EnvelopeType.green:
        return const Color(0xFF4CAF50);  // Xanh lá cây (leaf green)
      case EnvelopeType.yellow:
        return const Color(0xFFFFD93D);
    }
  }

  Color get gradientStart {
    switch (this) {
      case EnvelopeType.red:
        return const Color(0xFFFF6B6B);
      case EnvelopeType.green:
        return const Color(0xFF66BB6A);  // Xanh lá cây sáng
      case EnvelopeType.yellow:
        return const Color(0xFFFDE047);
    }
  }

  Color get gradientEnd {
    switch (this) {
      case EnvelopeType.red:
        return const Color(0xFFB83240);
      case EnvelopeType.green:
        return const Color(0xFF2E7D32);  // Xanh lá cây đậm
      case EnvelopeType.yellow:
        return const Color(0xFFF59E0B);
    }
  }

  /// Chữ may mắn tiếng Việt cho mỗi loại bao lì xì
  String get luckyText {
    switch (this) {
      case EnvelopeType.red:
        return 'PHÚC';  // Phúc đức, may mắn
      case EnvelopeType.green:
        return 'THỌ';   // Trường thọ, bình an (đã đổi từ LỘC)
      case EnvelopeType.yellow:
        return 'LỘC';   // Lộc lái, tài lộc (đã đổi từ THỌ)
    }
  }

  /// Tỷ lệ trúng (càng cao càng dễ trúng)
  double get probability {
    switch (this) {
      case EnvelopeType.red:
        return 0.1;   // 10% - hiếm nhất
      case EnvelopeType.green:
        return 0.60;   // 60% - phổ biến nhất (tăng từ 55%)
      case EnvelopeType.yellow:
        return 0.30;   // 30% - phổ biến vừa (giảm từ 35%)
    }
  }

  /// Số tiền thưởng tương ứng
  int get baseAmount {
    switch (this) {
      case EnvelopeType.red:
        return 100000;  // 100k
      case EnvelopeType.green:
        return 50000;   // 50k
      case EnvelopeType.yellow:
        return 10000;   // 10k
    }
  }
}

/// Service xử lý quay gacha
class GachaService {
  final Random _random = Random();

  /// Quay gacha với weighted probability
  EnvelopeType drawEnvelope() {
    final value = _random.nextDouble();
    
    if (value < EnvelopeType.red.probability) {
      return EnvelopeType.red;
    } else if (value < EnvelopeType.red.probability + EnvelopeType.green.probability) {
      return EnvelopeType.green;
    } else {
      return EnvelopeType.yellow;
    }
  }

  /// Tạo số tiền thưởng ngẫu nhiên dựa trên loại envelope
  int generateAmount(EnvelopeType type) {
    final base = type.baseAmount;
    final variance = base * 0.2; // ±20%
    final amount = base + (_random.nextDouble() * 2 * variance - variance);
    return amount.round();
  }

  /// Thực hiện quay gacha và trả kết quả
  GachaResult draw() {
    final envelopeType = drawEnvelope();
    final amount = generateAmount(envelopeType);
    return GachaResult(
      envelopeType: envelopeType,
      amount: amount,
      timestamp: DateTime.now(),
    );
  }
}
