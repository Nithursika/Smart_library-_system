import 'package:supabase_flutter/supabase_flutter.dart';

import '../config.dart';
import '../models/book.dart';

class BookService {
  BookService._();
  static final BookService instance = BookService._();

  SupabaseClient? get _client =>
      AppConfig.isConfigured ? Supabase.instance.client : null;

  static final _mockBooks = [
    Book(
      id: 'b1',
      title: 'Grade 10 Chemistry',
      author: 'NCERT',
      section: 'Science',
      shelf: 'S-03',
      position: 12,
      status: 'available',
      barcode: '8901001000001',
    ),
    Book(
      id: 'b2',
      title: 'World History',
      author: 'A. Smith',
      section: 'History',
      shelf: 'S-01',
      position: 4,
      status: 'borrowed',
      barcode: '8901001000002',
    ),
    Book(
      id: 'b3',
      title: 'Algebra Basics',
      author: 'R. Khan',
      section: 'Math',
      shelf: 'S-02',
      position: 8,
      status: 'missing',
      barcode: '8901001000003',
    ),
    Book(
      id: 'b4',
      title: 'English Grammar',
      author: 'Wren & Martin',
      section: 'Language',
      shelf: 'S-01',
      position: 15,
      status: 'available',
      barcode: '8901001000004',
    ),
  ];

  Future<List<Book>> getAllBooks() async {
    final client = _client;
    if (client == null) return List.of(_mockBooks);

    final rows = await client.from('books').select().order('title');
    return (rows as List)
        .map((row) => Book.fromMap(Map<String, dynamic>.from(row as Map)))
        .toList();
  }

  Future<List<Book>> searchBooks(String query) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return getAllBooks();

    final client = _client;
    if (client == null) {
      return _mockBooks
          .where(
            (b) =>
                b.title.toLowerCase().contains(q) ||
                b.author.toLowerCase().contains(q) ||
                (b.barcode?.toLowerCase().contains(q) ?? false),
          )
          .toList();
    }

    try {
      final rows = await client
          .from('books')
          .select()
          .or('title.ilike.%$q%,author.ilike.%$q%,barcode.ilike.%$q%')
          .order('title');

      return (rows as List)
          .map((row) => Book.fromMap(Map<String, dynamic>.from(row as Map)))
          .toList();
    } catch (_) {
      final rows = await client
          .from('books')
          .select()
          .or('title.ilike.%$q%,author.ilike.%$q%')
          .order('title');

      return (rows as List)
          .map((row) => Book.fromMap(Map<String, dynamic>.from(row as Map)))
          .toList();
    }
  }

  Future<Book?> getBookByBarcode(String code) async {
    final barcode = code.trim();
    if (barcode.isEmpty) return null;

    final client = _client;
    if (client == null) {
      try {
        return _mockBooks.firstWhere(
          (b) => b.barcode == barcode || b.id == barcode,
        );
      } catch (_) {
        return null;
      }
    }

    try {
      final row = await client
          .from('books')
          .select()
          .eq('barcode', barcode)
          .maybeSingle();
      if (row != null) {
        return Book.fromMap(Map<String, dynamic>.from(row));
      }
    } catch (_) {
      // barcode column may not exist yet — fall through
    }

    return getBookById(barcode);
  }

  Future<Book?> getBookById(String id) async {
    final client = _client;
    if (client == null) {
      try {
        return _mockBooks.firstWhere((b) => b.id == id);
      } catch (_) {
        return null;
      }
    }

    final row =
        await client.from('books').select().eq('id', id).maybeSingle();
    if (row == null) return null;
    return Book.fromMap(Map<String, dynamic>.from(row));
  }

  Future<void> reportMissing(String id, {String? note}) async {
    final client = _client;
    if (client == null) return;

    await client.from('books').update({
      'status': 'missing',
      'missing_note': note,
      'missing_reported_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', id);
  }

  Future<Book> addBook({
    required String title,
    required String author,
    required String section,
    required String shelf,
    required int position,
    String status = 'available',
    String? barcode,
    String? description,
  }) async {
    final client = _client;
    if (client == null) {
      final book = Book(
        id: 'local_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        author: author,
        section: section,
        shelf: shelf,
        position: position,
        status: status,
        barcode: barcode,
        description: description,
      );
      _mockBooks.add(book);
      return book;
    }

    final payload = <String, dynamic>{
      'title': title,
      'author': author,
      'section': section,
      'shelf': shelf,
      'position': position,
      'status': status,
    };
    if (barcode != null && barcode.trim().isNotEmpty) {
      payload['barcode'] = barcode.trim();
    }
    if (description != null && description.trim().isNotEmpty) {
      payload['description'] = description.trim();
    }

    final row = await client
        .from('books')
        .insert(payload)
        .select()
        .single();

    return Book.fromMap(Map<String, dynamic>.from(row));
  }
}
