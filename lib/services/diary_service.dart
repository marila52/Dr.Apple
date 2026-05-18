import '../models/diary_entry_model.dart';
import 'database/diary_dao.dart';
import 'firestore_service.dart';

class DiaryService {
  final DiaryDao _dao = DiaryDao();
  final FirestoreService _firestore = FirestoreService();

  Future<void> addEntry(DiaryEntry entry) async {
    await _dao.insertEntry(entry);
    try {
      await _firestore.saveDiaryEntry(entry);
    } catch (_) {}
  }

  Future<void> updateEntry(DiaryEntry entry) async {
    await _dao.updateEntry(entry);
    try {
      await _firestore.updateDiaryEntry(entry);
    } catch (_) {}
  }

  Future<void> deleteEntry(String id) async {
    await _dao.deleteEntry(id);
    try {
      await _firestore.deleteDiaryEntry(id);
    } catch (_) {}
  }

  Future<List<DiaryEntry>> getEntriesByDate(DateTime date, String userId) {
    return _dao.getEntriesByDate(date, userId);
  }

  Future<Set<int>> getFilledDaysInMonth(
    String userId,
    int year,
    int month,
  ) async {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 0, 23, 59, 59);
    final entries = await _dao.getEntriesForPeriod(start, end, userId);
    return entries.map((e) => e.dateTime.day).toSet();
  }
}
