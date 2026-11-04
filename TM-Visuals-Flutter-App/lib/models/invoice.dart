class Invoice {
  String reference;
  String dateCreated;
  String id;
  String filePath;

  Invoice({
    required this.reference,
    required this.dateCreated,
    this.id = '',
    this.filePath = '',
  });
}
