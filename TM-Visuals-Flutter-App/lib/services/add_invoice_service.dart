
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/add_invoice_model.dart';

class AddInvoiceService {
  AddInvoiceService({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  //Database table and storage bucket names
  static const String _invoiceBucket = 'invoices';
  static const String _invoiceTable = 'invoice';

  /// Returns the admin_id for the currently signed-in administrator.
  Future<String> requireAdminId() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('Please log in first.');
    }

    final admin = await _supabase
        .from('admins')
        .select('admin_id')
        .eq('user_id', user.id)
        .maybeSingle();

    if (admin == null) {
      throw Exception(
        'Only the administrator can upload invoices.',
      );
    }

    return admin['admin_id'].toString();
  }

  /// Uploads a PDF and saves its details in the invoice table.
  ///
  /// Returns the saved invoice.
  Future<AddInvoiceModel> uploadInvoice({
    required String bookingId,
    required String reference,
    required String fileName,
    required Uint8List fileBytes,
  }) async {
    final adminId = await requireAdminId();

    // Create a unique file path inside the invoice bucket.
    final safeFileName = fileName.replaceAll(
      RegExp(r'[^a-zA-Z0-9._-]'),
      '_',
    );

    final storagePath =
        '$bookingId/${DateTime.now().microsecondsSinceEpoch}_$safeFileName';

    bool uploaded = false;

    try {
      // Upload the PDF to Supabase Storage.
      await _supabase.storage
          .from(_invoiceBucket)
          .uploadBinary(
            storagePath,
            fileBytes,
            fileOptions: const FileOptions(
              contentType: 'application/pdf',
              upsert: false,
            ),
          );

      uploaded = true;

      // Insert invoice metadata into PostgreSQL.
      final response = await _supabase
          .from(_invoiceTable)
          .insert({
            'admin_id': adminId,
            'booking_id': bookingId,
            'reference': reference.trim(),
            'file_path': storagePath,
          })
          .select()
          .single();

      return AddInvoiceModel.fromMap(response);
    } catch (e) {
      // If the database insert fails, remove the uploaded PDF.
      if (uploaded) {
        try {
          await _supabase.storage
              .from(_invoiceBucket)
              .remove([storagePath]);
        } catch (_) {
          // Preserve the original upload/database error.
        }
      }

      rethrow;
    }
  }
}
