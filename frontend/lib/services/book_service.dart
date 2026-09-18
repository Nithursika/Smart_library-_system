import 'package:supabase_flutter/supabase_flutter.dart';

import '../config.dart';
import '../models/book.dart';

class BookService {
  BookService._();
  static final BookService instance = BookService._();

  SupabaseClient? get _client =>
      AppConfig.isConfigured ? Supabase.instance.client : null;

  static const _mockBooks = [
    Book(
      id: 'b1',
      title: 'Grade 10 Chemistry',
      author: 'NCERT',
      section: 'Science',
      shelf: 'S-03',
      position: 12,
      status: 'available',
    ),
    Book(
      id: 'b2',
      title: 'World History',
      author: 'A. Smith',
      section: 'History',
      shelf: 'S-01',
      position: 4,
      status: 'borrowed',
    ),
    Book(
      id: 'b3',
      title: 'Algebra Basics',
      author: 'R. Khan',
      section: 'Math',
      shelf: 'S-02',
      position: 8,
      status: 'missing',
    ),
    Book(
      id: 'b4',
      title: 'English Grammar',
      author: 'Wren & Martin',
      section: 'Language',
      shelf: 'S-01',
      position: 15,
      status: 'available',
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
                b.author.toLowerCase().contains(q),
          )
          .toList();
    }

    final rows = await client
        .from('books')
        .select()
        .or('title.ilike.%$q%,author.ilike.%$q%')
        .order('title');

    return (rows as List)
        .map((row) => Book.fromMap(Map<String, dynamic>.from(row as Map)))
        .toList();
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
}
