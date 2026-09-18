import 'package:flutter/material.dart';

import '../models/book.dart';

class NavigateScreen extends StatelessWidget {
  const NavigateScreen({super.key, required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    final shelves = ['S-01', 'S-02', 'S-03'];

    return Scaffold(
      appBar: AppBar(title: const Text('Navigate to Shelf')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              book.title,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Go to shelf ${book.shelf} · position ${book.position}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: shelves.map((shelf) {
                  final active = shelf == book.shelf;
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: active
                            ? const Color(0xFF1565C0)
                            : const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: active
                              ? const Color(0xFF0D47A1)
                              : const Color(0xFF90CAF9),
                          width: active ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.view_column,
                            size: 36,
                            color: active ? Colors.white : Colors.blueGrey,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            shelf,
                            style: TextStyle(
                              color: active ? Colors.white : Colors.blueGrey,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          if (active) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Pos ${book.position}',
                              style: const TextStyle(color: Colors.white),
                            ),
                            const Icon(Icons.place, color: Colors.amber),
                          ],
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Follow the highlighted shelf on this map.\n(ESP32 LED will light the same shelf later.)',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
