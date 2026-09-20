import 'package:flutter/material.dart';

import '../models/book.dart';
import '../services/led_service.dart';

class NavigateScreen extends StatefulWidget {
  const NavigateScreen({super.key, required this.book});

  final Book book;

  @override
  State<NavigateScreen> createState() => _NavigateScreenState();
}

class _NavigateScreenState extends State<NavigateScreen> {
  String _ledStatus = 'Lighting shelf LED...';

  @override
  void initState() {
    super.initState();
    _lightLed();
  }

  @override
  void dispose() {
    // Turn LED off when leaving this screen
    LedService.instance.turnOff();
    super.dispose();
  }

  Future<void> _lightLed() async {
    final message = await LedService.instance.lightShelf(widget.book.shelf);
    if (!mounted) return;
    setState(() => _ledStatus = message);
  }

  Future<void> _turnOffLed() async {
    final message = await LedService.instance.turnOff();
    if (!mounted) return;
    setState(() => _ledStatus = message);
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.book;
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
            const SizedBox(height: 8),
            Text(
              _ledStatus,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _ledStatus.contains('off')
                    ? Colors.grey.shade700
                    : _ledStatus.startsWith('LED on')
                        ? Colors.green.shade700
                        : Colors.orange.shade800,
              ),
            ),
            const SizedBox(height: 16),
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
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: _lightLed,
              icon: const Icon(Icons.lightbulb_outline),
              label: const Text('Light LED again'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _turnOffLed,
              icon: const Icon(Icons.lightbulb),
              label: const Text('Found it — turn LED off'),
            ),
            const SizedBox(height: 8),
            const Text(
              'LED also auto-offs after 30s, or when you go back.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
