import 'package:intl/intl.dart';

class AppDateUtils {
  static final _dateFormat = DateFormat('dd/MM/yyyy');
  static final _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');
  static final _timeFormat = DateFormat('HH:mm');
  static final _apiFormat = DateFormat('yyyy-MM-dd');
  static final _apiDateTimeFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

  static String formatDate(DateTime date) => _dateFormat.format(date);

  static String formatDateTime(DateTime date) => _dateTimeFormat.format(date);

  static String formatTime(DateTime date) => _timeFormat.format(date);

  static String toApiDate(DateTime date) => _apiFormat.format(date);

  static String toApiDateTime(DateTime date) => _apiDateTimeFormat.format(date);

  static DateTime? parseDate(String dateStr) {
    try {
      return _dateFormat.parse(dateStr);
    } catch (_) {
      return null;
    }
  }

  static DateTime? parseApiDate(String dateStr) {
    try {
      return _apiFormat.parse(dateStr);
    } catch (_) {
      return null;
    }
  }

  static bool isOverdue(DateTime dueDate) {
    return dueDate.isBefore(DateTime.now()) &&
        dueDate.day != DateTime.now().day;
  }

  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  static String timeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays > 365) return '${diff.inDays ~/ 365} năm trước';
    if (diff.inDays > 30) return '${diff.inDays ~/ 30} tháng trước';
    if (diff.inDays > 7) return '${diff.inDays ~/ 7} tuần trước';
    if (diff.inDays > 0) return '${diff.inDays} ngày trước';
    if (diff.inHours > 0) return '${diff.inHours} giờ trước';
    if (diff.inMinutes > 0) return '${diff.inMinutes} phút trước';
    return 'Vừa xong';
  }

  static String daysRemaining(DateTime dueDate) {
    final now = DateTime.now();
    final diff = dueDate.difference(DateTime(now.year, now.month, now.day));
    final days = diff.inDays;
    if (days < 0) return 'Quá hạn ${-days} ngày';
    if (days == 0) return 'Hôm nay';
    if (days == 1) return 'Còn 1 ngày';
    return 'Còn $days ngày';
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static DateTime startOfDay(DateTime date) => DateTime(date.year, date.month, date.day);

  static DateTime endOfDay(DateTime date) => DateTime(date.year, date.month, date.day, 23, 59, 59);

  static DateTime startOfWeek(DateTime date) {
    final diff = date.weekday - DateTime.monday;
    return DateTime(date.year, date.month, date.day - diff);
  }

  static DateTime startOfMonth(DateTime date) => DateTime(date.year, date.month, 1);

  static DateTime endOfMonth(DateTime date) => DateTime(date.year, date.month + 1, 0);

  static List<DateTime> getDaysInMonth(DateTime date) {
    final first = startOfMonth(date);
    final last = endOfMonth(date);
    final days = <DateTime>[];
    for (var i = 0; i < last.day; i++) {
      days.add(DateTime(first.year, first.month, i + 1));
    }
    return days;
  }

  static String monthYear(DateTime date) => DateFormat('MM/yyyy').format(date);

  static String weekdayName(DateTime date) => DateFormat('EEEE', 'vi_VN').format(date);
}
