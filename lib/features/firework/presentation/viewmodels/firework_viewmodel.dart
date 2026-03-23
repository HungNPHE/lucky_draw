import 'package:flutter/material.dart';
import '../../data/models/firework_result.dart';
import '../../data/services/firework_service.dart';

enum FireworkPhase { idle, launching, exploding, result }

class FireworkViewModel extends ChangeNotifier {
  final FireworkService _service = FireworkService();

  FireworkPhase phase = FireworkPhase.idle;
  FireworkResult? lastResult;
  final List<FireworkResult> history = [];

  bool get isLaunching => phase == FireworkPhase.launching;
  bool get isExploding => phase == FireworkPhase.exploding;
  bool get showResult => phase == FireworkPhase.result;

  Future<void> shoot() async {
    if (phase != FireworkPhase.idle) return;

    phase = FireworkPhase.launching;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 1200));

    lastResult = _service.shoot();
    phase = FireworkPhase.exploding;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 1500));

    history.insert(0, lastResult!);
    phase = FireworkPhase.result;
    notifyListeners();
  }

  void reset() {
    phase = FireworkPhase.idle;
    notifyListeners();
  }
}
