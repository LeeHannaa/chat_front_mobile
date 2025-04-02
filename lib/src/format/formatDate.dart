import 'package:intl/intl.dart';

String formatDate(DateTime dateTime) {
  final today = DateTime.now();

  final isSameDay = dateTime.year == today.year &&
      dateTime.month == today.month &&
      dateTime.day == today.day;
  final isYesterday = dateTime.year == today.year &&
      dateTime.month == today.month &&
      dateTime.day + 1 == today.day;

  if (isSameDay) {
    return DateFormat('HH:mm').format(dateTime);
  } else if (isYesterday) {
    return '어제';
  } else {
    return DateFormat('yyyy.MM.dd').format(dateTime);
  }
}
