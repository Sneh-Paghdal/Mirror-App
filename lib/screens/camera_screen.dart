import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _cameraController;
  double _zoomLevel = 1.0;
  double _brightnessLevel = 0.5;
  bool isInitialized = false;

  @override
  void initState() {
    super.initState();
    initializeCamera();
    Future.delayed(Duration(seconds: 3));
    setState(() {
      isInitialized = true;
    });
  }

  Future<void> initializeCamera() async {
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _cameraController = CameraController(frontCamera, ResolutionPreset.high);
    await _cameraController.initialize();

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  void _updateZoom(double value) async {
    setState(() {
      _zoomLevel = value;
    });

    final maxZoom = await _cameraController.getMaxZoomLevel();
    final newZoom = value * maxZoom;
    _cameraController.setZoomLevel(newZoom);
  }

  void _updateBrightness(double value) {
    setState(() {
      _brightnessLevel = value;
    });

    final exposureOffset = value * 2.0; // Map the brightness level to exposure offset range (-2.0 to 2.0)
    _cameraController.setExposureOffset(exposureOffset);
  }

  @override
  Widget build(BuildContext context) {
    return (!isInitialized) ? Scaffold() : Scaffold(
      appBar: AppBar(
        title: Text('Camera Screen'),
      ),
      body: Stack(
        children: [
          CameraPreview(_cameraController),
          Positioned(
            left: 16,
            top: 100,
            bottom: 100,
            child: RotatedBox(
              quarterTurns: -1,
              child: Slider(
                value: _zoomLevel,
                min: 0.0,
                max: 1.0,
                onChanged: _updateZoom,
              ),
            ),
          ),
          Positioned(
            left: 50,
            right: 50,
            bottom: 16,
            child: Slider(
              value: _brightnessLevel,
              min: 0.0,
              max: 1.0,
              onChanged: _updateBrightness,
            ),
          ),
        ],
      ),
    );
  }
}
