import 'package:flutter/material.dart';
import '../interface/lucky_draw_repository.dart';
import '../models/lucky_result.dart';
import '../models/gacha_result.dart';
import '../repository/lucky_draw_repository_impl.dart';
import '../services/lucky_draw_service.dart';
import '../services/gacha_service.dart' hide GachaService;

enum SpinMode {
  range,
  customList,
}

/// Class lưu trữ giá trị cho danh sách quay (có thể là chữ, số hoặc kết hợp)
class NamedValue {
  final String display;  // Giá trị hiển thị (có thể là "1", "a", "An", "Giải 1")
  final int? numericValue;  // Giá trị số để quay (nếu có)

  const NamedValue({required this.display, this.numericValue});
}

class LuckyDrawViewModel extends ChangeNotifier {
  final LuckyDrawService _service = LuckyDrawService();
  final LuckyDrawRepository _repository;

  LuckyDrawViewModel({LuckyDrawRepository? repository})
      : _repository = repository ?? _createDefaultRepository();

  static LuckyDrawRepository _createDefaultRepository() {
    return LuckyDrawRepositoryImpl();
  }

  int? currentNumber;
  String? currentName;

  List<LuckyResult> get history => _repository.getHistory();

  bool isSpinning = false;

  int minNumber = 1;
  int maxNumber = 100;

  String customValuesInput = "1,10";

  SpinMode mode = SpinMode.range;

  // Gacha feature
  GachaResult? currentGachaResult;
  bool isShowingGachaResult = false;
  final GachaService _gachaService = GachaService();
  final List<GachaResult> _gachaHistory = [];
  
  List<GachaResult> get gachaHistory => List.unmodifiable(_gachaHistory);

  List<int> get customValues => _parseCustomValues();
  
  /// Danh sách giá trị để hiển thị trên vòng quay cho range mode
  List<int> get rangeValues {
    if (mode != SpinMode.range) return [];
    
    // Only show start and end values
    if (minNumber > maxNumber) {
      return [];
    }
    
    // Return only 2 values: min and max
    return [minNumber, maxNumber];
  }

  /// Danh sách các giá trị (chữ, số hoặc kết hợp)
  List<NamedValue> namedValues = [];
  
  /// Danh sách giá trị để hiển thị trên vòng quay
  List<String> get wheelValues => namedValues.map((nv) => nv.display).toList();

  void setMode(SpinMode newMode) {
    if (mode == newMode) return;
    mode = newMode;
    
    // Clear values when switching modes
    currentNumber = null;
    currentName = null;
    
    notifyListeners();
  }

  void setRangeMin(String value) {
    final parsed = int.tryParse(value);
    if (parsed == null) return;
    minNumber = parsed;
    
    // Clear current result when range changes
    currentNumber = null;
    currentName = null;
    
    notifyListeners();
  }

  void setRangeMax(String value) {
    final parsed = int.tryParse(value);
    if (parsed == null) return;
    maxNumber = parsed;
    
    // Clear current result when range changes
    currentNumber = null;
    currentName = null;
    
    notifyListeners();
  }

  void setCustomValuesInput(String value) {
    customValuesInput = value;
    notifyListeners();
  }

  void setNamedValues(List<NamedValue> values) {
    namedValues = values;
    notifyListeners();
  }

  void removeCustomValue(dynamic value) {
    // Remove from named values by display string
    namedValues.removeWhere((nv) => nv.display == value.toString());
    
    // Also update legacy customValuesInput if value is int
    if (value is int) {
      final values = _parseCustomValues();
      final index = values.indexOf(value);
      if (index >= 0) {
        values.removeAt(index);
        customValuesInput = values.join(',');
      }
    }
    notifyListeners();
  }

  void clearHistory() {
    _repository.clearHistory();
    notifyListeners();
  }

  /// Thực hiện quay gacha
  Future<void> drawGacha() async {
    if (isSpinning) return;

    isSpinning = true;
    notifyListeners();

    // Simulate drawing animation time
    await Future.delayed(const Duration(milliseconds: 1500));

    // Draw result
    currentGachaResult = _gachaService.draw();
    
    // Save to history
    _gachaHistory.insert(0, currentGachaResult!);
    
    isShowingGachaResult = true;
    isSpinning = false;
    notifyListeners();
  }

  /// Đóng hiển thị kết quả gacha
  void closeGachaResult() {
    isShowingGachaResult = false;
    currentGachaResult = null;
    notifyListeners();
  }

  List<int> _parseCustomValues() {
    final parts = customValuesInput.split(RegExp(r'[,\s]+'));
    final result = <int>[];
    for (final p in parts) {
      if (p.isEmpty) continue;
      final v = int.tryParse(p);
      if (v != null) result.add(v);
    }
    return result;
  }

  Future<void> spin() async {
    if (isSpinning) return;

    late final int number;
    String? selectedDisplay;

    if (mode == SpinMode.range) {
      number = _service.generateLuckyNumberInRange(minNumber, maxNumber);
    } else {
      // Use namedValues for custom list mode
      if (namedValues.isEmpty) {
        number = _service.generateLuckyNumberInRange(minNumber, maxNumber);
      } else {
        // Pick a random item from namedValues
        final random = DateTime.now().millisecondsSinceEpoch % namedValues.length;
        final selected = namedValues[random];
        selectedDisplay = selected.display;
        number = selected.numericValue ?? random + 1;
      }
    }

    currentNumber = number;
    currentName = selectedDisplay;
    isSpinning = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 2200));

    isSpinning = false;
    _repository.addResult(LuckyResult(
      number: number,
      name: selectedDisplay,
      time: DateTime.now(),
    ));
    notifyListeners();
  }
}