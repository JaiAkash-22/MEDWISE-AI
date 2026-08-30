import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../services/ocr_service.dart';
import '../services/ai_service.dart';
import '../services/database_service.dart';
import '../models/medicine.dart';
import 'result_screen.dart';

class ScanScreen extends StatefulWidget {
  final String profileId;
  const ScanScreen({super.key, this.profileId = 'default'});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  CameraController? _controller;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;
    _controller = CameraController(cameras.first, ResolutionPreset.high);
    await _controller!.initialize();
    if (mounted) setState(() {});
  }

  Future<void> _captureAndProcess() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    setState(() => _isProcessing = true);

    try {
      final file = await _controller!.takePicture();
      final ocrService = OcrService();
      final rawText = await ocrService.extractText(File(file.path));
      ocrService.dispose();

      final aiService = AiService();
      final result = await aiService.explain(rawText);

      final medicine = Medicine(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: result.medicineName,
        rawOcrText: rawText,
        explanation: result.explanation,
        scannedAt: DateTime.now(),
        profileId: widget.profileId,
      );

      await DatabaseService().saveMedicine(medicine);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => ResultScreen(medicine: medicine)),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Medicine')),
      body: _controller == null || !_controller!.value.isInitialized
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Positioned.fill(child: CameraPreview(_controller!)),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: FloatingActionButton.large(
                      onPressed: _isProcessing ? null : _captureAndProcess,
                      child: _isProcessing
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Icon(Icons.camera_alt),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}