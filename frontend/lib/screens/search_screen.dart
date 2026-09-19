import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/book.dart';
import '../services/book_service.dart';
import '../widgets/barcode_scan_page.dart';
import '../widgets/status_chip.dart';
import 'book_info_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(icon: Icon(Icons.qr_code_scanner), text: 'Barcode'),
            Tab(icon: Icon(Icons.text_fields), text: 'Text search'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: const [
          _BarcodeSearchTab(),
          _TextSearchTab(),
        ],
      ),
    );
  }
}

class _TextSearchTab extends StatefulWidget {
  const _TextSearchTab();

  @override
  State<_TextSearchTab> createState() => _TextSearchTabState();
}

class _TextSearchTabState extends State<_TextSearchTab> {
  final _controller = TextEditingController();
  List<Book> _results = [];
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final books = await BookService.instance.searchBooks(_controller.text);
      if (!mounted) return;
      setState(() => _results = books);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _openBook(Book book) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BookInfoScreen(book: book)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          controller: _controller,
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => _search(),
          decoration: InputDecoration(
            hintText: 'Search by title, author, or barcode',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            suffixIcon: IconButton(
              icon: const Icon(Icons.arrow_forward),
              onPressed: _search,
            ),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: _search,
          icon: const Icon(Icons.search),
          label: const Text('Search'),
        ),
        const SizedBox(height: 16),
        if (_loading) const Center(child: CircularProgressIndicator()),
        if (_error != null)
          Text(_error!, style: const TextStyle(color: Colors.red)),
        ..._results.map(
          (book) => Card(
            child: ListTile(
              title: Text(book.title),
              subtitle: Text('${book.author} · ${book.shelf}'),
              trailing: StatusChip(status: book.status),
              onTap: () => _openBook(book),
            ),
          ),
        ),
      ],
    );
  }
}

class _BarcodeSearchTab extends StatefulWidget {
  const _BarcodeSearchTab();

  @override
  State<_BarcodeSearchTab> createState() => _BarcodeSearchTabState();
}

class _BarcodeSearchTabState extends State<_BarcodeSearchTab> {
  final _manualController = TextEditingController();
  bool _handling = false;
  String? _status;

  @override
  void dispose() {
    _manualController.dispose();
    super.dispose();
  }

  Future<void> _openScanner() async {
    if (kIsWeb) {
      setState(() {
        _status = 'Camera scan needs the Android APK. Type the barcode below.';
      });
      return;
    }

    final code = await BarcodeScanPage.open(context);
    if (code == null || !mounted) return;
    await _lookup(code);
  }

  Future<void> _lookup(String code) async {
    if (_handling) return;
    final value = code.trim();
    if (value.isEmpty) return;

    setState(() {
      _handling = true;
      _status = 'Looking up $value...';
    });

    try {
      final book = await BookService.instance.getBookByBarcode(value);
      if (!mounted) return;

      if (book == null) {
        setState(() => _status = 'No book found for $value');
        return;
      }

      setState(() => _status = 'Found: ${book.title}');
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => BookInfoScreen(book: book)),
      );
      if (!mounted) return;
      setState(() => _status = 'Scan another barcode');
    } catch (e) {
      if (!mounted) return;
      setState(() => _status = 'Lookup failed: $e');
    } finally {
      if (mounted) setState(() => _handling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Scan a book barcode with the camera, or type the number.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: _handling ? null : _openScanner,
          icon: const Icon(Icons.qr_code_scanner),
          label: const Text('Open camera scanner'),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
          ),
        ),
        const SizedBox(height: 24),
        if (_status != null) ...[
          Text(_status!, textAlign: TextAlign.center),
          const SizedBox(height: 16),
        ],
        TextField(
          controller: _manualController,
          decoration: InputDecoration(
            labelText: 'Or type barcode',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.qr_code),
          ),
          onSubmitted: _lookup,
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: _handling ? null : () => _lookup(_manualController.text),
          child: const Text('Find by barcode'),
        ),
      ],
    );
  }
}
