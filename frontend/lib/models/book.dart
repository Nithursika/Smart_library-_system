class Book {
  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.section,
    required this.shelf,
    required this.position,
    required this.status,
    this.barcode,
    this.description,
  });

  final String id;
  final String title;
  final String author;
  final String section;
  final String shelf;
  final int position;
  final String status; // available | borrowed | missing
  final String? barcode;
  final String? description;

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'] as String,
      title: map['title'] as String,
      author: map['author'] as String? ?? '',
      section: map['section'] as String? ?? '',
      shelf: map['shelf'] as String,
      position: (map['position'] as num).toInt(),
      status: map['status'] as String? ?? 'available',
      barcode: map['barcode'] as String?,
      description: map['description'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'section': section,
      'shelf': shelf,
      'position': position,
      'status': status,
      if (barcode != null) 'barcode': barcode,
      if (description != null) 'description': description,
    };
  }
}
