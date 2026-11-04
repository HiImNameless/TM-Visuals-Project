import 'package:flutter/foundation.dart';
import '../models/calendar_model.dart';
import '../models/blocked_time_range.dart';
import '../services/calendar_service.dart';

class DateAvailabilityViewModel extends ChangeNotifier {
  DateAvailabilityViewModel(this.service, this.date);
  final CalendarDataSource service;
  final DateTime date;
  List<CalendarSlot> slots = [];
  List<BlockedTimeRange> blockedTimes = [];
  bool loading = true, saving = false, available = true, _disposed = false;
  Object? loadError, saveError;
  bool get canSave => !loading && !saving && loadError == null;
  void _changed() {
    if (!_disposed) notifyListeners();
  }

  Future<void> load() async {
    if (saving) return;
    loading = true;
    loadError = null;
    _changed();
    try {
      final values = await Future.wait<Object>([
        service.loadDate(date),
        service.loadAvailability(date),
      ]);
      if (_disposed) return;
      slots = values[0] as List<CalendarSlot>;
      final day =
          (values[1] as Map<String, CalendarDayAvailability>)[dateKey(date)];
      if (day == null) {
        throw const FormatException(
          'Availability for this date was not returned. Please retry.',
        );
      }
      available = day.available;
      blockedTimes = List.of(day.blockedTimes);
    } catch (e) {
      if (!_disposed) loadError = e;
    } finally {
      if (!_disposed) {
        loading = false;
        _changed();
      }
    }
  }

  void setAvailable(bool value) {
    if (canSave) {
      available = value;
      _changed();
    }
  }

  void setBlockedTimes(List<BlockedTimeRange> values) {
    if (!canSave || !available) return;
    final issue = BlockedTimeRange.validate(values);
    if (issue != null) throw FormatException(issue);
    blockedTimes = List.unmodifiable(values);
    saveError = null;
    _changed();
  }

  bool get overlapsBookings => slots.where((slot) => slot.reserved).any((slot) {
    if (!available) return true;
    int minutes(String value) {
      final parts = value.split(':');
      return int.parse(parts[0]) * 60 + int.parse(parts[1]);
    }

    return blockedTimes.any(
      (range) =>
          range.startMinutes < minutes(slot.end) &&
          range.endMinutes > minutes(slot.start),
    );
  });

  Future<bool> save() async {
    if (!canSave) return false;
    saving = true;
    saveError = null;
    _changed();
    try {
      await service.saveAvailability(
        date,
        available,
        blockedTimes: blockedTimes,
      );
      return true;
    } catch (e) {
      if (!_disposed) saveError = e;
      return false;
    } finally {
      if (!_disposed) {
        saving = false;
        _changed();
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
