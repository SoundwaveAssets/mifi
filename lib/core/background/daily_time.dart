/// Prochaine occurrence de l'heure [minutesOfDay] (minutes depuis minuit)
/// strictement après [now], en heure locale (gère les changements de mois et
/// d'heure d'été).
DateTime nextDailyOccurrence(int minutesOfDay, DateTime now) {
  final hour = minutesOfDay ~/ 60, minute = minutesOfDay % 60;
  final today = DateTime(now.year, now.month, now.day, hour, minute);
  if (today.isAfter(now)) return today;
  return DateTime(now.year, now.month, now.day + 1, hour, minute);
}
