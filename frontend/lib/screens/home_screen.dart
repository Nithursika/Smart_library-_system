import 'package:flutter/material.dart';

import '../models/book.dart';
import '../services/book_service.dart';
import 'all_books_screen.dart';
import 'book_info_screen.dart';
import 'report_missing_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  List<Book> _results = [];
  bool _searching = false;
  String? _error;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    setState(() {
      _searching = true;
      _error = null;
    });
    try {
      final books =
          await BookService.instance.searchBooks(_searchController.text);
      if (!mounted) return;
      setState(() => _results = books);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Smart Library')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _search(),
            decoration: InputDecoration(
              hintText: 'Search by title or author',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: _search,
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _search,
            icon: const Icon(Icons.menu_book),
            label: const Text('Find a Book'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ReportMissingScreen(),
                ),
              );
            },
            icon: const Icon(Icons.report_gmailerrorred_outlined),
            label: const Text('Report Missing Book'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AllBooksScreen()),
              );
            },
            icon: const Icon(Icons.list_alt),
            label: const Text('View All Books'),
          ),
          const SizedBox(height: 24),
          if (_searching) const Center(child: CircularProgressIndicator()),
          if (_error != null)
            Text(_error!, style: const TextStyle(color: Colors.red)),
          ..._results.map(
            (book) => Card(
              child: ListTile(
                title: Text(book.title),
                subtitle: Text('${book.author} · ${book.shelf}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookInfoScreen(book: book),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
