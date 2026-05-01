import '../models/quest.dart';

bool isQuestCurrentlyComplete(Quest quest, DateTime? completedAt) {
  if (completedAt == null) return false;
  final freq = (quest.frequency ?? '').toLowerCase();
  final now = DateTime.now();
  switch (freq) {
    case 'daily':
      return _isSameDay(completedAt, now);
    case 'weekly':
      return _isSameWeek(completedAt, now);
    case 'habit':
      return true;
    default:
      return _isSameDay(completedAt, now);
  }
}

bool _isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

bool _isSameWeek(DateTime a, DateTime b) {
  final aStart = _startOfWeek(a);
  final bStart = _startOfWeek(b);
  return _isSameDay(aStart, bStart);
}

DateTime _startOfWeek(DateTime d) {
  final daysFromMonday = d.weekday - DateTime.monday;
  return DateTime(d.year, d.month, d.day).subtract(
    Duration(days: daysFromMonday),
  );
}
