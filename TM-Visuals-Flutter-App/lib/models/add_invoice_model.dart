class AddInvoiceModel {
  final String invoiceId;
  final String adminId;
  final String bookingId;
  final String reference;
  final String filePath;
  final DateTime? createdAt;

  const AddInvoiceModel({
    required this.invoiceId,
    required this.adminId,
    required this.bookingId,
    required this.reference,
    required this.filePath,
    this.createdAt,
  });

  factory AddInvoiceModel.fromMap(Map<String, dynamic> map) {
    return AddInvoiceModel(
      invoiceId: map['invoice_id'].toString(),
      adminId: map['admin_id'].toString(),
      bookingId: map['booking_id'].toString(),
      reference: map['reference'].toString(),
      filePath: map['file_path'].toString(),
      createdAt: map['created_at'] == null
          ? null
          : DateTime.tryParse(map['created_at'].toString()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'invoice_id': invoiceId,
      'admin_id': adminId,
      'booking_id': bookingId,
      'reference': reference,
      'file_path': filePath,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

class InvoiceBooking {
  const InvoiceBooking({required this.id, required this.label});
  final String id, label;
}
