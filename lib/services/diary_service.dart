import '../models/diary_entry_model.dart';
import 'database/diary_dao.dart';

class DiaryService {
  final DiaryDao _dao = DiaryDao();

  Future<void> addEntry(DiaryEntry entry) async {
    await _dao.insertEntry(entry);
  }

  Future<void> updateEntry(DiaryEntry entry) async {
    await _dao.updateEntry(entry);
  }

  Future<void> deleteEntry(String id) async {
    await _dao.deleteEntry(id);
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