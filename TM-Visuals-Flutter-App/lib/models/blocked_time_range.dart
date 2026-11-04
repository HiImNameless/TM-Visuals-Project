/// A closure within one SAST calendar day, with an exclusive end time.
class BlockedTimeRange {
  BlockedTimeRange({required this.startMinutes, required this.endMinutes}) {
    if (startMinutes < 0 ||
        endMinutes >= 24 * 60 ||
        endMinutes <= startMinutes) {
      throw ArgumentError(
        'A blocked period must start and end on the same day, with its end later than its start.',
      );
    }
  }

  final int startMinutes;
  final int endMinutes;

  static String? validate(List<BlockedTimeRange> ranges) {
    final ordered = [...ranges]
      ..sort((a, b) => a.startMinutes.compareTo(b.startMinutes));
    for (var index = 1; index < ordered.length; index++) {
      if (ordered[index].startMinutes < ordered[index - 1].endMinutes) {
        return 'Blocked periods cannot overlap.';
      }
    }
    return null;
  }
}
