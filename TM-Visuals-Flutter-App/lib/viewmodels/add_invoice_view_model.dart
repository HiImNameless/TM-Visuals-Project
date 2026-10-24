import 'package:flutter/foundation.dart';
import '../models/add_invoice_model.dart';
import '../services/add_invoice_service.dart';

class AddInvoiceViewModel extends ChangeNotifier {
  AddInvoiceViewModel({
    AddInvoiceService? service,
  }) : _service = service ?? AddInvoiceService();

  final AddInvoiceService _service;

  bool _isLoading = false;
  String? _errorMessage;
  AddInvoiceModel? _invoice;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  AddInvoiceModel? get invoice => _invoice;

  Future<bool> uploadInvoice({
    required String bookingId,
    required String reference,
    required String fileName,
    required Uint8List fileBytes,
  }) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      if (reference.trim().isEmpty) {
        throw Exception('Reference is required.');
      }

      if (fileBytes.isEmpty) {
        throw Exception('Please select a PDF file.');
      }

      _invoice = await _service.uploadInvoice(
        bookingId: bookingId,
        reference: reference.trim(),
        fileName: fileName,
        fileBytes: fileBytes,
      );

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void reset() {
    _invoice = null;
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}