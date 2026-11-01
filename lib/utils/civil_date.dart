// Civil dates never undergo device timezone conversion.
String? canonicalDate(String value) {
  final text = value.trim();
  final iso = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(text);
  final local = RegExp(r'^(\d{2})/(\d{2})/(\d{4})$').firstMatch(text);
  if (iso == null && local == null) return null;
  final year = int.parse(iso?[1] ?? local![3]!);
  final month = int.parse(iso?[2] ?? local![2]!);
  final day = int.parse(iso?[3] ?? local![1]!);
  final date = DateTime.utc(year, month, day);
  if (year < 1 || date.year != year || date.month != month || date.day != day)
    return null;
  return '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
}

String displayDate(String? value) {
  if (value == null || value.isEmpty) return 'Não informado';
  final iso = canonicalDate(value);
  return iso == null
      ? value
      : '${iso.substring(8)}/${iso.substring(5, 7)}/${iso.substring(0, 4)}';
}

bool validApplicationDate(String value, {DateTime? now}) {
  final date = canonicalDate(value);
  // Shelter's current civil offset; the server enforces the IANA timezone.
  final today = (now ?? DateTime.now()).toUtc().subtract(
    const Duration(hours: 3),
  );
  final limit =
      '${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
  return date != null && date.compareTo(limit) <= 0;
}
