import 'package:intl/intl.dart';

/// Utilities for ISO 8601 parsing, local timezone conversions, and human-readable formatting.
class DateFormatter {
  static final DateFormat _dateTimeFormat = DateFormat('MMM d, yyyy • hh:mm a');
  static final DateFormat _dateFormat = DateFormat('MMM d, yyyy');
  static final DateFormat _timeFormat = DateFormat('hh:mm a');

  /// Parse an ISO 8601 string safely into a local DateTime.
  static DateTime? parseToLocal(String? isoString) {
    if (isoString == null || isoString.trim().isEmpty) return null;
    try {
      final parsed = DateTime.parse(isoString.trim());
      return parsed.toLocal();
    } catch (_) {
      return null;
    }
  }

  /// Format a DateTime into readable date and time (e.g. "Oct 27, 2026 • 09:30 AM")
  static String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';
    return _dateTimeFormat.format(dateTime.toLocal());
  }

  /// Format an ISO 8601 string directly into readable date and time
  static String formatIso(String? isoString) {
    final dt = parseToLocal(isoString);
    return formatDateTime(dt);
  }

  /// Format date only (e.g. "Oct 27, 2026")
  static String formatDate(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';
    return _dateFormat.format(dateTime.toLocal());
  }

  /// Format time only (e.g. "09:30 AM")
  static String formatTime(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';
    return _timeFormat.format(dateTime.toLocal());
  }

  /// Check if a given DateTime falls on the same calendar date as today in the local timezone.
  static bool isToday(DateTime? dateTime, {DateTime? customToday}) {
    if (dateTime == null) return false;
    final localDt = dateTime.toLocal();
    final today = (customToday ?? DateTime.now()).toLocal();

    return localDt.year == today.year &&
        localDt.month == today.month &&
        localDt.day == today.day;
  }

  /// Check if an ISO 8601 string falls on today's local date.
  static bool isIsoToday(String? isoString, {DateTime? customToday}) {
    final dt = parseToLocal(isoString);
    return isToday(dt, customToday: customToday);
  }
}
