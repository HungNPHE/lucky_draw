import '../models/lucky_result.dart';

abstract class LuckyDrawRepository {
  /// Lấy toàn bộ lịch sử kết quả (mới nhất trước).
  List<LuckyResult> getHistory();

  /// Thêm một kết quả vào lịch sử.
  void addResult(LuckyResult result);

  /// Xóa toàn bộ lịch sử.
  void clearHistory();
}
