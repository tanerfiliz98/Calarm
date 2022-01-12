import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class CameraService {
  static final CameraService _cameraServiceService = CameraService._internal();

  factory CameraService() {
    return _cameraServiceService;
  }
  CameraService._internal();

  late CameraController cameraController;

  late CameraDescription cameraDescription;

  late InputImageRotation cameraRotation;

  Future startService() async {
    this.cameraController = CameraController(
      this.cameraDescription,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    this.cameraRotation = rotationIntToImageRotation(
      this.cameraDescription.sensorOrientation,
    );

    return this.cameraController.initialize();
  }

  InputImageRotation rotationIntToImageRotation(int rotation) {
    switch (rotation) {
      case 90:
        return InputImageRotation.Rotation_90deg;
      case 180:
        return InputImageRotation.Rotation_180deg;
      case 270:
        return InputImageRotation.Rotation_270deg;
      default:
        return InputImageRotation.Rotation_0deg;
    }
  }

  Size getImageSize() {
    return Size(
      cameraController.value.previewSize!.height,
      cameraController.value.previewSize!.width,
    );
  }

  dispose() {
    this.cameraController.dispose();
  }
}
