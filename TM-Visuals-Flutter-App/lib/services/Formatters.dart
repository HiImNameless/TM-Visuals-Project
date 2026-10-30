import 'package:intl/intl.dart';
import '../models/booking_list_model.dart';

final _day = DateFormat('EEE d MMM');
final _dayLong = DateFormat('EEEE d MMMM yyyy');
final _dateTime = DateFormat('d MMM yyyy, HH:mm');

String fmtDay(DateTime d) => _day.format(d);
String fmtDayLong(DateTime d) => _dayLong.format(d);
String fmtDateTime(DateTime d) => _dateTime.format(d);

/// "Sat 7 Nov, 09:00–12:00"
String fmtBlock(TimeBlock b) => '${fmtDay(b.date)}, ${b.start}–${b.end}';

/// Lists up to [max] blocks, then "+N more".
String fmtBlocks(List<TimeBlock> blocks, {int max = 2}) {
  if (blocks.isEmpty) return 'No time slots';
  final shown = blocks.take(max).map(fmtBlock).join('; ');
  final extra = blocks.length - max;
  return extra > 0 ? '$shown; +$extra more' : shown;
}

const kCurrencySymbol = 'R';

String fmtMoney(double? v) {
  if (v == null) return 'Not given';
  final n = NumberFormat('#,##0.00').format(v);
  return kCurrencySymbol.isEmpty ? n : '$kCurrencySymbol$n';
}

String timeAgo(DateTime t, {DateTime? now}) {
  final diff = (now ?? DateTime.now()).difference(t);
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
  if (diff.inHours < 24) return '${diff.inHours} h ago';
  if (diff.inDays < 7) return '${diff.inDays} d ago';
  return fmtDay(t);
}
