import 'package:intl/intl.dart';

class DateFormatter {
  static String formatDate(DateTime date) {
    final DateFormat formatter = DateFormat('d MMM yyyy', 'ar');
    return formatter.format(date);
  }

  static String formatDateShort(DateTime date) {
    final DateFormat formatter = DateFormat('d MMM', 'ar');
    return formatter.format(date);
  }

  static String formatTime(DateTime date) {
    final DateFormat formatter = DateFormat('hh:mm a', 'ar');
    return formatter.format(date);
  }

  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'صباح الخير';
    } else if (hour < 17) {
      return 'مساء النور';
    } else {
      return 'مساء الخير';
    }
  }
}
