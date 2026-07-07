/// The API stores estimates as a plain integer of minutes; the UI has always
/// shown/edited them as free text like "1h 30m". These two functions are the
/// seam between the two representations.
String formatMinutes(int? minutes) {
  if (minutes == null || minutes <= 0) return '—';
  final hours = minutes ~/ 60;
  final mins = minutes % 60;
  if (hours == 0) return '${mins}m';
  if (mins == 0) return '${hours}h';
  return '${hours}h ${mins}m';
}

/// Parses free text like "1h 30m", "2h", "45m", "1.5h" into whole minutes.
/// Returns null if nothing recognizable was found.
int? parseMinutesFromLabel(String text) {
  final hMatch = RegExp(r'([\d.]+)\s*h').firstMatch(text);
  final mMatch = RegExp(r'([\d.]+)\s*m').firstMatch(text);
  double total = 0;
  var matched = false;
  if (hMatch != null) {
    total += double.parse(hMatch.group(1)!) * 60;
    matched = true;
  }
  if (mMatch != null) {
    total += double.parse(mMatch.group(1)!);
    matched = true;
  }
  if (!matched) {
    final bare = num.tryParse(text.trim());
    if (bare == null) return null;
    return bare.round();
  }
  return total.round();
}
