import '../interface/lucky_draw_repository.dart';
import '../models/lucky_result.dart';

/// Repository cụ thể: lưu lịch sử kết quả trong bộ nhớ.
class LuckyDrawRepositoryImpl implements LuckyDrawRepository {
  final List<LuckyResult> _history = [];

  @override
  List<LuckyResult> getHistory() {
    return List.unmodifiable(_history);
  }

  @override
  void addResult(LuckyResult result) {
    _history.insert(0, result);
  }

  @override
  void clearHistory() {
    _history.clear();
  }
}
