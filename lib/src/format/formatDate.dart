import 'package:intl/intl.dart';

String formatDate(DateTime dateTime) {
  final today = DateTime.now();
  final koreaTime = dateTime.add(const Duration(hours: 9)); // 9시간 추가

  final isSameDay = koreaTime.year == today.year &&
      koreaTime.month == today.month &&
      koreaTime.day == today.day;
  final isYesterday = koreaTime.year == today.year &&
      koreaTime.month == today.month &&
      koreaTime.day + 1 == today.day;

  if (isSameDay) {
    return DateFormat('HH:mm').format(koreaTime);
  } else if (isYesterday) {
    return '어제';
  } else {
    return DateFormat('yyyy.MM.dd').format(koreaTime);
  }
}
