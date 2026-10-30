import 'package:flutter/material.dart';
import '../models/booking_list_model.dart';

class BookingStatusChip extends StatelessWidget {
  const BookingStatusChip(this.status, {super.key});
  final BookingStatus status;

  // Icon + label + color, so status never depends on color alone.
  (Color, IconData) get _style => switch (status) {
    BookingStatus.pending => (const Color(0xFFD9A406), Icons.hourglass_top),
    BookingStatus.confirmed => (const Color(0xFF2F9E5E), Icons.check_circle),
    BookingStatus.completed => (const Color(0xFF3B7DD8), Icons.task_alt),
    BookingStatus.declined => (const Color(0xFFCF4444), Icons.cancel),
    BookingStatus.cancelled => (const Color(0xFF8A8A85), Icons.block),
    BookingStatus.unknown => (const Color(0xFF8A8A85), Icons.help_outline),
  };

  @override
  Widget build(BuildContext context) {
    final (color, icon) = _style;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
