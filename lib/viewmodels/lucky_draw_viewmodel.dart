import 'package:flutter/material.dart';
import '../interface/lucky_draw_repository.dart';
import '../models/lucky_result.dart';
import '../repository/lucky_draw_repository_impl.dart';
import '../services/lucky_draw_service.dart';

enum SpinMode {
  range,
  customList,
}

class LuckyDrawViewModel extends ChangeNotifier {
  final LuckyDrawService _service = LuckyDrawService();
  final LuckyDrawRepository _repository;

  LuckyDrawViewModel({LuckyDrawRepository? repository})
      : _repository = repository ?? _defaultRepository;

  static final _defaultRepository = _createDefaultRepository();

  static LuckyDrawRepository _createDefaultRepository() {
    return LuckyDrawRepositoryImpl();
  }

  int? currentNumber;

  List<LuckyResult> get history => _repository.getHistory();

  bool isSpinning = false;

  //  quay theo khoảng
  int minNumber = 1;
  int maxNumber = 100;

  //  quay theo danh sách giá trị
  String customValuesInput = "1,10";

  SpinMode mode = SpinMode.range;

  List<int> get customValues => _parseCustomValues();

  void setMode(SpinMode newMode) {
    if (mode == newMode) return;
    mode = newMode;
    notifyListeners();
  }

  void setRangeMin(String value) {
    final parsed = int.tryParse(value);
    if (parsed == null) return;
    minNumber = parsed;
    notifyListeners();
  }

  void setRangeMax(String value) {
    final parsed = int.tryParse(value);
    if (parsed == null) return;
    maxNumber = parsed;
    notifyListeners();
  }

  void setCustomValuesInput(String value) {
    customValuesInput = value;
    notifyListeners();
  }

  void removeCustomValue(int value) {
    final values = _parseCustomValues();
    final index = values.indexOf(value);
    if (index < 0) return;
    values.removeAt(index);
    customValuesInput = values.join(',');
    notifyListeners();
  }

  List<int> _parseCustomValues() {
    final parts = customValuesInput.split(RegExp(r'[,\s]+'));
    final result = <int>[];
    for (final p in parts) {
      if (p.isEmpty) continue;
      final v = int.tryParse(p);
      if (v != null) {
        result.add(v);
      }
    }
    return result;
  }

  Future<void> spin() async {
    if (isSpinning) return;

    late final int number;

    if (mode == SpinMode.range) {
      number = _service.generateLuckyNumberInRange(minNumber, maxNumber);
    } else {
      final values = _parseCustomValues();
      if (values.isEmpty) {
        // Nếu người dùng chưa nhập gì hợp lệ, fallback về khoảng mặc định
        number = _service.generateLuckyNumberInRange(minNumber, maxNumber);
      } else {
        number = _service.generateLuckyNumberFromList(values);
      }
    }

    currentNumber = number;
    isSpinning = true;
    notifyListeners();

    // Đồng bộ với thời gian animation của vòng quay
    await Future.delayed(const Duration(milliseconds: 2200));

    isSpinning = false;
    _repository.addResult(LuckyResult(number: number, time: DateTime.now()));
    notifyListeners();
  }
}