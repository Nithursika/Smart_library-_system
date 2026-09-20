import 'package:flutter/material.dart';

import '../models/book.dart';
import '../services/book_service.dart';

class ReportMissingScreen extends StatefulWidget {
  const ReportMissingScreen({super.key, this.book});

  final Book? book;

  @override
  State<ReportMissingScreen> createState() => _ReportMissingScreenState();
}

class _ReportMissingScreenState extends State<ReportMissingScreen> {
  final _noteController = TextEditingController();
  List<Book> _books = [];
  Book? _selected;
  bool _loading = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _selected = widget.book;
    _load();
  }

  Future<void> _load() async {
    try {
      final books = await BookService.instance.getAllBooks();
      if (!mounted) return;
      setState(() {
        _books = books;
        _selected ??= books.isNotEmpty ? books.first : null;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load books: $e')),
      );
    }
  }

  Future<void> _submit() async {
    final book = _selected;
    if (book == null) return;

    setState(() => _submitting = true);
    try {
      await BookService.instance.reportMissing(
        book.id,
        note: _noteController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reported missing: ${book.title}')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report Missing Book')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<Book>(
                    key: ValueKey(_selected?.id),
                    initialValue: _selected,
                    items: _books
                        .map(
                          (b) => DropdownMenuItem(
                            value: b,
                            child: Text(b.title),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => _selected = value),
                    decoration: const InputDecoration(
                      labelText: 'Book',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_selected != null) ...[
                    Text('Last known location: ${_selected!.shelf}'),
                    Text('Position: ${_selected!.position}'),
                    Text('Current status: ${_selected!.status}'),
                    const SizedBox(height: 16),
                  ],
                  TextField(
                    controller: _noteController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Note (optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: _submitting ? null : _submit,
                    child: _submitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Submit Report'),
                  ),
                ],
              ),
            ),
    );
  }
}
