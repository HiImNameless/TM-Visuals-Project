import 'package:flutter/foundation.dart';
import '../models/calendar_model.dart';
import '../services/calendar_service.dart';

class DateAvailabilityViewModel extends ChangeNotifier {
  DateAvailabilityViewModel(this.service, this.date);
  final CalendarDataSource service;
  final DateTime date;
  List<CalendarSlot> slots = [];
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
      available = (values[1] as Map<String, bool>)[dateKey(date)] ?? true;
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

  Future<bool> save() async {
    if (!canSave) return false;
    saving = true;
    saveError = null;
    _changed();
    try {
      await service.saveAvailability(date, available);
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
