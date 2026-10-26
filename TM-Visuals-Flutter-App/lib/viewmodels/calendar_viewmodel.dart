import 'package:flutter/foundation.dart';
import '../models/calendar_model.dart';
import '../services/calendar_service.dart';

class CalendarViewModel extends ChangeNotifier {
  CalendarViewModel(this.service, {DateTime? initialDate})
    : selected = initialDate ?? businessToday();
  final CalendarDataSource service;
  DateTime selected;
  List<CalendarSlot> slots = [];
  Map<String, bool> availability = {};
  bool loading = true, _disposed = false;
  Object? error;
  int _version = 0;
  void _changed() {
    if (!_disposed) notifyListeners();
  }

  List<CalendarSlot> forDate(DateTime date) =>
      slots.where((s) => dateKey(s.date) == dateKey(date)).toList();
  String status(DateTime date) {
    if (loading || error != null) return 'Not loaded';
    if (availability[dateKey(date)] == false) return 'Unavailable';
    return forDate(date).any((s) => s.reserved) ? 'Reserved' : 'Available';
  }

  Future<void> load() async {
    final current = ++_version;
    loading = true;
    error = null;
    _changed();
    try {
      final result = await Future.wait<Object>([
        service.loadMonth(selected),
        service.loadAvailability(selected),
      ]);
      if (!_disposed && current == _version) {
        slots = result[0] as List<CalendarSlot>;
        availability = result[1] as Map<String, bool>;
      }
    } catch (e) {
      if (!_disposed && current == _version) error = e;
    } finally {
      if (!_disposed && current == _version) {
        loading = false;
        _changed();
      }
    }
  }

  Future<void> moveMonth(int delta) {
    selected = DateTime(selected.year, selected.month + delta);
    return load();
  }

  Future<void> today() {
    selected = businessToday();
    return load();
  }

  void selectDate(DateTime date) {
    selected = date;
    _changed();
  }

  @override
  void dispose() {
    _disposed = true;
    _version++;
    super.dispose();
  }
}
