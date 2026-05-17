import '../models/weight_entry_model.dart';
import 'database/weight_dao.dart';
import 'firestore_service.dart';

class WeightHistoryService {
  final WeightDao _dao = WeightDao();
  final FirestoreService _firestore = FirestoreService();

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

    try {
      await _firestore.saveWeightEntry(entry);
    } catch (_) {
      // Офлайн: останется только в SQLite, синхронизируется позже
    }
  }

  Future<List<WeightEntry>> loadHistory(String userId) async {
    var local = await _dao.getByUser(userId);

    try {
      final remote = await _firestore.getWeightHistory(userId);
      if (remote.isNotEmpty) {
        final merged = _mergeEntries(local, remote);
        await _dao.replaceAllForUser(userId, merged);
        local = merged;
      }
    } catch (_) {}

    if (local.isEmpty) {
      return [];
    }

    return local;
  }

  List<WeightEntry> _mergeEntries(
    List<WeightEntry> local,
    List<WeightEntry> remote,
  ) {
    final map = <String, WeightEntry>{};
    for (final e in [...local, ...remote]) {
      map[e.id] = e;
    }
    final merged = map.values.toList()
      ..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));
    return merged;
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
