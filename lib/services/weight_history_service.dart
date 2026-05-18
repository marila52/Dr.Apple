import '../models/weight_entry_model.dart';
import 'database/weight_dao.dart';

class WeightHistoryService {
  final WeightDao _dao = WeightDao();

  Future<void> recordWeight({
    required String userId,
    required double weight,
    DateTime? recordedAt,
  }) async {
    final entry = _dao.createEntry(
      userId: userId,
      weight: weight,
      recordedAt: recordedAt,
    );

    await _dao.insert(entry);
  }

  Future<List<WeightEntry>> loadHistory(String userId) async {
    final local = await _dao.getByUser(userId);
    return local;
  }

  /// Первая запись из текущего веса профиля, если истории ещё нет.
  Future<List<WeightEntry>> ensureInitialFromProfile({
    required String userId,
    required double? currentWeight,
  }) async {
    var history = await loadHistory(userId);
    if (history.isNotEmpty || currentWeight == null) {
      return history;
    }

    await recordWeight(userId: userId, weight: currentWeight);
    return loadHistory(userId);
  }
}