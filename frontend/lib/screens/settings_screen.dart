import 'package:flutter/material.dart';

import '../config.dart';
import '../services/led_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _espController = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await LedService.instance.loadSavedUrl();
    _espController.text = LedService.instance.baseUrl.contains('ESP32_IP_HERE')
        ? ''
        : LedService.instance.baseUrl;
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _save() async {
    var url = _espController.text.trim();
    if (url.isNotEmpty && !url.startsWith('http')) {
      url = 'http://$url';
    }
    await LedService.instance.setBaseUrl(url);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('ESP32 address saved')),
    );
    setState(() {});
  }

  @override
  void dispose() {
    _espController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    AppConfig.isConfigured
                        ? Icons.cloud_done
                        : Icons.cloud_off,
                    color: AppConfig.isConfigured ? Colors.green : Colors.grey,
                  ),
                  title: const Text('Supabase'),
                  subtitle: Text(
                    AppConfig.isConfigured
                        ? 'Connected'
                        : 'Not configured',
                  ),
                ),
                const Divider(),
                const Text(
                  'ESP32 shelf LEDs',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _espController,
                  decoration: const InputDecoration(
                    labelText: 'ESP32 address',
                    hintText: 'http://192.168.1.45',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.memory),
                  ),
                ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: _save,
                  child: const Text('Save'),
                ),
                const SizedBox(height: 8),
                Text(
                  LedService.instance.isConfigured
                      ? 'LEDs ready · ${LedService.instance.baseUrl}'
                      : 'Enter ESP32 IP from Serial Monitor',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Phone and ESP32 must be on the same Wi‑Fi.',
                  style: TextStyle(fontSize: 13),
                ),
              ],
            ),
    );
  }
}
