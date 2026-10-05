import '../../l10n/app_localizations.dart';

/// Durée lisible et traduite : « 45 s », « 3 min 12 s », « 2 h 05 min »,
/// « 1 j 4 h 10 min ».
String formatDuration(AppLocalizations l, Duration duration) {
  final total = duration.isNegative ? 0 : duration.inSeconds;
  final days = total ~/ 86400;
  final hours = (total % 86400) ~/ 3600;
  final minutes = (total % 3600) ~/ 60;
  final seconds = total % 60;
  if (days > 0) return l.durationDaysHoursMinutes(days, hours, minutes);
  if (hours > 0) return l.durationHoursMinutes(hours, minutes);
  if (minutes > 0) return l.durationMinutesSeconds(minutes, seconds);
  return l.durationSeconds(seconds);
}
