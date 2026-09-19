import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:permission_handler/permission_handler.dart';
import 'package:zxing_lib/common.dart';
import 'package:zxing_lib/zxing.dart';

/// Camera preview + still-photo barcode decode (pure Dart ZXing, no NDK).
class BarcodeScanPage extends StatefulWidget {
  const BarcodeScanPage({super.key, this.title = 'Scan barcode'});

  final String title;

  static Future<String?> open(
    BuildContext context, {
    String title = 'Scan barcode',
  }) {
    return Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => BarcodeScanPage(title: title)),
    );
  }

  @override
  State<BarcodeScanPage> createState() => _BarcodeScanPageState();
}

class _BarcodeScanPageState extends State<BarcodeScanPage> {
  CameraController? _camera;
  Timer? _timer;

  String? _error;
  String _hint = 'Put barcode in the box, then tap Scan';
  bool _loading = true;
  bool _busy = false;
  bool _done = false;

  static final _hints = DecodeHint(
    tryHarder: true,
    alsoInverted: true,
    possibleFormats: [
      BarcodeFormat.ean13,
      BarcodeFormat.ean8,
      BarcodeFormat.upcA,
      BarcodeFormat.upcE,
      BarcodeFormat.code128,
      BarcodeFormat.code39,
      BarcodeFormat.code93,
      BarcodeFormat.qrCode,
      BarcodeFormat.dataMatrix,
    ],
  );

  @override
  void initState() {
    super.initState();
    _startCamera();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _camera?.dispose();
    super.dispose();
  }

  Future<void> _startCamera() async {
    _timer?.cancel();
    setState(() {
      _loading = true;
      _error = null;
      _done = false;
      _busy = false;
      _hint = 'Put barcode in the box, then tap Scan';
    });

    try {
      await _camera?.dispose();
      _camera = null;

      final status = await Permission.camera.request();
      if (!mounted) return;
      if (!status.isGranted) {
        setState(() {
          _loading = false;
          _error = status.isPermanentlyDenied
              ? 'Camera blocked. Enable it in App Settings.'
              : 'Camera permission is required.';
        });
        return;
      }

      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() {
          _loading = false;
          _error = 'No camera found on this phone.';
        });
        return;
      }

      final back = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        back,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }

      _camera = controller;
      setState(() => _loading = false);

      _timer = Timer.periodic(const Duration(seconds: 2), (_) {
        _captureAndDecode();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not open camera.\n$e';
      });
    }
  }

  Future<void> _captureAndDecode() async {
    final camera = _camera;
    if (_done || _busy || camera == null || !camera.value.isInitialized) {
      return;
    }
    if (camera.value.isTakingPicture) return;

    _busy = true;
    if (mounted) setState(() => _hint = 'Reading barcode…');

    try {
      final shot = await camera.takePicture();
      final bytes = await File(shot.path).readAsBytes();
      // Clean temp file so storage does not fill up
      try {
        await File(shot.path).delete();
      } catch (_) {}

      final decoded = _decodeBarcode(bytes);

      if (!mounted) return;

      if (decoded != null && decoded.isNotEmpty) {
        _done = true;
        _timer?.cancel();
        Navigator.pop(context, decoded);
        return;
      }

      setState(
        () => _hint = 'Not detected — hold steady, more light, tap Scan',
      );
    } catch (_) {
      if (mounted) {
        setState(() => _hint = 'Scan failed, try again');
      }
    } finally {
      _busy = false;
    }
  }

  String? _decodeBarcode(Uint8List bytes) {
    final image = img.decodeImage(bytes);
    if (image == null) return null;

    // Focus on center band (matches the on-screen box) for 1D barcodes
    final cropW = (image.width * 0.85).round().clamp(80, image.width);
    final cropH = (image.height * 0.35).round().clamp(40, image.height);
    final cropped = img.copyCrop(
      image,
      x: (image.width - cropW) ~/ 2,
      y: (image.height - cropH) ~/ 2,
      width: cropW,
      height: cropH,
    );

    final resized = img.copyResize(
      cropped,
      width: cropped.width > 1200 ? 1200 : cropped.width,
    );

    final pixels = _toArgbPixels(resized);
    final source = RGBLuminanceSource(resized.width, resized.height, pixels);
    final reader = MultiFormatReader()..setHints(_hints);

    for (final binarizer in [
      HybridBinarizer(source),
      GlobalHistogramBinarizer(source),
    ]) {
      try {
        return reader.decode(BinaryBitmap(binarizer)).text.trim();
      } catch (_) {}
    }
    return null;
  }

  /// Build 0xAARRGGBB ints that RGBLuminanceSource expects.
  List<int> _toArgbPixels(img.Image image) {
    final out = List<int>.filled(image.width * image.height, 0);
    var i = 0;
    for (final p in image) {
      out[i++] =
          (0xFF << 24) | (p.r.toInt() << 16) | (p.g.toInt() << 8) | p.b.toInt();
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text(widget.title)),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return ColoredBox(
        color: Colors.white,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_error!, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _startCamera,
                  child: const Text('Try again'),
                ),
                TextButton(
                  onPressed: openAppSettings,
                  child: const Text('Open app settings'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final camera = _camera;
    if (camera == null || !camera.value.isInitialized) {
      return const Center(child: Text('Camera not ready'));
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        Center(child: CameraPreview(camera)),
        IgnorePointer(
          child: Center(
            child: Container(
              width: 280,
              height: 160,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.limeAccent, width: 3),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 24,
          child: Column(
            children: [
              Text(
                _hint,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  shadows: [Shadow(blurRadius: 8, color: Colors.black)],
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _busy ? null : _captureAndDecode,
                icon: const Icon(Icons.qr_code_scanner),
                label: Text(_busy ? 'Reading…' : 'Scan now'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
