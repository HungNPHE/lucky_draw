import 'dart:math';
import '../models/gacha_result.dart';

/// Service xử lý quay gacha với weighted probabilities
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
