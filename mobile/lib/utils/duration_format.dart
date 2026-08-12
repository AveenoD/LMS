/// Exact "M:SS" / "H:MM:SS" duration text from a precise second count —
/// unlike a whole-minutes value, this never rounds a video's real length
/// into a misleading number (e.g. a 3:34 video showing as "4 min").
/// Falls back to whole-minute text only when seconds aren't available
/// (older content rows from before duration_seconds was tracked).
String formatExactDuration(int? totalSeconds, {int? fallbackMinutes}) {
  if (totalSeconds != null && totalSeconds > 0) {
    final h = totalSeconds ~/ 3600;
    final m = (totalSeconds % 3600) ~/ 60;
    final s = totalSeconds % 60;
    final ss = s.toString().padLeft(2, '0');
    if (h > 0) return '$h:${m.toString().padLeft(2, '0')}:$ss';
    return '$m:$ss';
  }
  if (fallbackMinutes != null && fallbackMinutes > 0) {
    if (fallbackMinutes < 60) return '~$fallbackMinutes min';
    final hours = fallbackMinutes ~/ 60;
    final mins = fallbackMinutes % 60;
    return mins == 0 ? '~$hours hr' : '~$hours hr $mins min';
  }
  return 'Duration unknown';
}
