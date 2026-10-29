import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/admin_auth_service.dart';

class AdminAuthViewModel extends ChangeNotifier {
  AdminAuthViewModel(this.service) {
    _subscription = service.changes.listen(
      (_) => check(),
      onError: (Object e) {
        _version++;
        adminId = null;
        checking = false;
        error = e;
        _changed();
      },
    );
    check();
  }
  final AdminAuthService service;
  StreamSubscription<Object>? _subscription;
  String? userId, adminId;
  Object? error;
  bool checking = true, busy = false, _disposed = false;
  int _version = 0;
  bool get authorized => userId != null && adminId != null;
  void _changed() {
    if (!_disposed) notifyListeners();
  }

  Future<void> check() async {
    final version = ++_version;
    final next = service.userId;
    final keep = next != null && next == userId && adminId != null;
    userId = next;
    if (!keep) adminId = null;
    checking = !keep && next != null;
    error = null;
    _changed();
    if (next == null) return;
    try {
      final id = await service.currentAdminId();
      if (!_disposed && version == _version) adminId = id;
    } catch (e) {
      if (!_disposed && version == _version) {
        error = e;
        adminId = null;
      }
    } finally {
      if (!_disposed && version == _version) {
        checking = false;
        _changed();
      }
    }
  }

  Future<void> signIn(String email, String password) async {
    if (busy) return;
    busy = true;
    error = null;
    _changed();
    try {
      await service.signIn(email, password);
    } catch (e) {
      if (!_disposed) error = e;
    } finally {
      if (!_disposed) {
        busy = false;
        _changed();
      }
    }
  }

  Future<void> signOut() async {
    if (busy) return;
    busy = true;
    _changed();
    try {
      await service.signOut();
    } catch (e) {
      if (!_disposed) error = e;
    } finally {
      if (!_disposed) {
        busy = false;
        _changed();
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _version++;
    _subscription?.cancel();
    super.dispose();
  }
}
