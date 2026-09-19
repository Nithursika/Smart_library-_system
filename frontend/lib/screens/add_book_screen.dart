import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/book_service.dart';
import '../services/led_service.dart';
import '../widgets/barcode_scan_page.dart';

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _author = TextEditingController();
  final _section = TextEditingController();
  final _position = TextEditingController(text: '1');
  final _barcode = TextEditingController();
  final _description = TextEditingController();

  String _shelf = 'S-01';
  String _status = 'available';
  bool _saving = false;
  bool _lightLed = true;

  static const _shelves = ['S-01', 'S-02', 'S-03'];

  @override
  void dispose() {
    _title.dispose();
    _author.dispose();
    _section.dispose();
    _position.dispose();
    _barcode.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _scanBarcode() async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Camera scan works on the Android APK')),
      );
      return;
    }

    final code = await BarcodeScanPage.open(context);
    if (code == null || !mounted) return;
    setState(() => _barcode.text = code);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      final book = await BookService.instance.addBook(
        title: _title.text.trim(),
        author: _author.text.trim(),
        section: _section.text.trim(),
        shelf: _shelf,
        position: int.parse(_position.text.trim()),
        status: _status,
        barcode: _barcode.text.trim().isEmpty ? null : _barcode.text.trim(),
        description:
            _description.text.trim().isEmpty ? null : _description.text.trim(),
      );

      if (_lightLed) {
        await LedService.instance.lightShelf(book.shelf);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added "${book.title}" on ${book.shelf}')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add book: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Book')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _title,
              decoration: const InputDecoration(
                labelText: 'Title *',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _author,
              decoration: const InputDecoration(
                labelText: 'Author',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _description,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _section,
              decoration: const InputDecoration(
                labelText: 'Section (e.g. Science)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Place on shelf',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _shelf,
              items: _shelves
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _shelf = v);
              },
              decoration: const InputDecoration(
                labelText: 'Shelf *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.view_column),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _position,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Position on shelf *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.pin_drop_outlined),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Required';
                if (int.tryParse(v.trim()) == null) return 'Enter a number';
                return null;
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _status,
              items: const [
                DropdownMenuItem(value: 'available', child: Text('Available')),
                DropdownMenuItem(value: 'borrowed', child: Text('Borrowed')),
                DropdownMenuItem(value: 'missing', child: Text('Missing')),
              ],
              onChanged: (v) {
                if (v != null) setState(() => _status = v);
              },
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Barcode',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _barcode,
              decoration: InputDecoration(
                labelText: 'Barcode',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.qr_code),
                suffixIcon: IconButton(
                  tooltip: 'Scan barcode',
                  onPressed: _scanBarcode,
                  icon: const Icon(Icons.qr_code_scanner),
                ),
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _scanBarcode,
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Scan barcode'),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Light shelf LED after adding'),
              value: _lightLed,
              onChanged: (v) => setState(() => _lightLed = v),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.add),
              label: Text(_saving ? 'Saving...' : 'Add book'),
            ),
          ],
        ),
      ),
    );
  }
}
