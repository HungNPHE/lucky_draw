import 'dart:math';
import '../models/firework_result.dart';

class FireworkService {
  final Random _random = Random();

  FireworkColor drawColor() {
    final v = _random.nextDouble();
    double cumulative = 0;
    for (final color in FireworkColor.values) {
      cumulative += color.probability;
      if (v < cumulative) return color;
    }
    return FireworkColor.blue;
  }

  FireworkResult shoot() {
    return FireworkResult(color: drawColor(), timestamp: DateTime.now());
  }
}
