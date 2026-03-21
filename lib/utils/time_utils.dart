import 'package:intl/intl.dart';
import 'package:zerotierapi/l10n/app_localizations.dart';

String formatLastOnline(int? timestamp, AppLocalizations l10n) {
  if (timestamp == null || timestamp <= 0) return l10n.neverOnline;
  
  final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
  final formatter = DateFormat('yyyy-MM-dd HH:mm');
  
  return formatter.format(dateTime.toLocal());
}

String timeAgo(int? timestamp, AppLocalizations l10n) {
  if (timestamp == null || timestamp <= 0) return l10n.neverOnline;
  
  final now = DateTime.now();
  final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
  final difference = now.difference(dateTime);
  
  if (difference.inSeconds < 60) return l10n.justNowOnline;
  if (difference.inMinutes < 60) return l10n.minutesAgo(difference.inMinutes);
  if (difference.inHours < 24) return l10n.hoursAgo(difference.inHours);
  if (difference.inDays < 30) return l10n.daysAgo(difference.inDays);
  
  return DateFormat('yyyy-MM-dd').format(dateTime);
}