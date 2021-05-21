class Attachment {
  final String fileUrl;
  final String fileName;
  final String fileExtension;
  final String fileMimeType;
  final int fileSize;

  Attachment(
    this.fileUrl,
    this.fileName,
    this.fileExtension,
    this.fileMimeType,
    this.fileSize,
  );

  factory Attachment.fromMap(dynamic map) {
    if (map == null) throw ArgumentError('The type of map is null');

    return Attachment(
      map['fileUrl'],
      map['fileName'],
      map['fileExtension'],
      map['fileMimeType'],
      map['fileSize'],
    );
  }
}
