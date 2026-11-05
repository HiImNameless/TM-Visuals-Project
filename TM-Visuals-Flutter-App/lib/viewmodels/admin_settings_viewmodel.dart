import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/admin_settings.dart';

class AdminSettingsViewModel extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  AdminSettings settings = AdminSettings(password: '', email: '', phone: '');

  bool hidePassword = true;
  bool isLoading = false;
  bool isSaving = false;
  String? errorMessage;
  String? successMessage;

  // Values as they are in the database, used to detect what changed
  String _originalEmail = '';
  String _originalPhone = '';

  void toggleHidePassword() {
    hidePassword = !hidePassword;
    notifyListeners();
  }

  /// Call once when the settings screen opens to prefill email and phone.
  Future<void> load() async {
    final uid = _supabase.auth.currentUser?.id;
    if (uid == null) return;

    isLoading = true;
    notifyListeners();
    try {
      final row = await _supabase
          .from('users')
          .select('email, phone')
          .eq('user_id', uid)
          .maybeSingle();

      _originalEmail = (row?['email'] as String?) ??
          _supabase.auth.currentUser?.email ??
          '';
      _originalPhone = (row?['phone'] as String?) ?? '';

      settings.email = _originalEmail;
      settings.phone = _originalPhone;
    } catch (e) {
      errorMessage = 'Could not load your details: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Returns true if everything the user changed was saved.
  Future<bool> save() async {
    errorMessage = null;
    successMessage = null;

    final user = _supabase.auth.currentUser;
    if (user == null) {
      errorMessage = 'You are not signed in.';
      notifyListeners();
      return false;
    }

    final newEmail = settings.email.trim();
    final newPhone = settings.phone.trim();
    final newPassword = settings.password;

    final emailChanged = newEmail.isNotEmpty && newEmail != _originalEmail;
    final phoneChanged = newPhone != _originalPhone;
    final passwordChanged = newPassword.isNotEmpty;

    if (!emailChanged && !phoneChanged && !passwordChanged) {
      successMessage = 'Nothing to update.';
      notifyListeners();
      return true;
    }
    if (passwordChanged && newPassword.length < 6) {
      errorMessage = 'Password must be at least 6 characters.';
      notifyListeners();
      return false;
    }

    isSaving = true;
    notifyListeners();

    try {
      final messages = <String>[];

      // 1. Password and email live in Supabase Auth
      if (passwordChanged) {
        await _supabase.auth.updateUser(UserAttributes(password: newPassword));
        messages.add('Password updated.');
      }

      var emailConfirmedNow = false;
      if (emailChanged) {
        final res = await _supabase.auth.updateUser(
          UserAttributes(email: newEmail),
        );
        // If email confirmation is on, the login email only changes after the
        // user clicks the link sent to the new address.
        emailConfirmedNow = res.user?.email == newEmail;
        if (!emailConfirmedNow) {
          messages.add('Check $newEmail to confirm the new email address.');
        }
      }

      // 2. Profile copy in public.users (phone now, email once it is confirmed)
      final updates = <String, dynamic>{};
      if (phoneChanged) updates['phone'] = newPhone;
      if (emailChanged && emailConfirmedNow) updates['email'] = newEmail;

      if (updates.isNotEmpty) {
        // .select() matters: if RLS blocks the update, Supabase returns zero
        // rows with NO error, so we must check the result.
        final updated = await _supabase
            .from('users')
            .update(updates)
            .eq('user_id', user.id)
            .select('user_id');

        if (updated.isEmpty) {
          throw Exception(
              'Update was blocked. Check the grant and RLS policy on public.users.');
        }
        if (updates.containsKey('phone')) {
          _originalPhone = newPhone;
          messages.add('Phone updated.');
        }
        if (updates.containsKey('email')) {
          _originalEmail = newEmail;
          messages.add('Email updated.');
        }
      }

      settings.password = '';
      successMessage = messages.join(' ');
      return true;
    } on AuthException catch (e) {
      errorMessage = e.message;
      return false;
    } on PostgrestException catch (e) {
      errorMessage = 'Could not save: ${e.message}';
      return false;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }
}