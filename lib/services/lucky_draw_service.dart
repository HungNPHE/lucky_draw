import 'dart:math';

class LuckyDrawService {
  final Random _random = Random();

  int generateLuckyNumberInRange(int min, int max) {
    if (min > max) {
      final temp = min;
      min = max;
      max = temp;
    }
    final span = max - min + 1;
    return _random.nextInt(span) + min;
  }

  int generateLuckyNumberFromList(List<int> values) {
    if (values.isEmpty) {
      throw ArgumentError('values must not be empty');
    }
    final index = _random.nextInt(values.length);
    return values[index];
  }
}