import 'package:flutter/material.dart';

import '../models/book.dart';
import '../widgets/status_chip.dart';
import 'navigate_screen.dart';
import 'report_missing_screen.dart';

class BookInfoScreen extends StatelessWidget {
  const BookInfoScreen({super.key, required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book Information')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              book.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text('Author: ${book.author}'),
            Text('Section: ${book.section}'),
            Text('Shelf: ${book.shelf}'),
            Text('Position: ${book.position}'),
            if (book.description != null && book.description!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Description',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 4),
              Text(book.description!),
            ],
            const SizedBox(height: 12),
            StatusChip(status: book.status),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => NavigateScreen(book: book),
                    ),
                  );
                },
                icon: const Icon(Icons.navigation_outlined),
                label: const Text('Navigate to Shelf'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReportMissingScreen(book: book),
                    ),
                  );
                },
                icon: const Icon(Icons.report_outlined),
                label: const Text('Report Missing'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
