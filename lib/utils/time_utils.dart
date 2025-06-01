import 'package:intl/intl.dart';

String formatLastOnline(int? timestamp) {
  if (timestamp == null || timestamp <= 0) return '从未在线';
  
  final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
  final formatter = DateFormat('yyyy-MM-dd HH:mm');
  
  return formatter.format(dateTime.toLocal());
}

String timeAgo(int? timestamp) {
  if (timestamp == null || timestamp <= 0) return '从未在线';
  
  final now = DateTime.now();
  final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
  final difference = now.difference(dateTime);
  
  if (difference.inSeconds < 60) return '刚刚在线';
  if (difference.inMinutes < 60) return '${difference.inMinutes}分钟前';
  if (difference.inHours < 24) return '${difference.inHours}小时前';
  if (difference.inDays < 30) return '${difference.inDays}天前';
  
  return DateFormat('yyyy-MM-dd').format(dateTime);
}