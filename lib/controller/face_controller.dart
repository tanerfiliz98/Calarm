import 'dart:ui';

import 'package:calarm/controller/user_controller.dart';
import 'package:calarm/service/camera_service.dart';
import 'package:calarm/service/database.dart';
import 'package:calarm/util/alarm_status.dart';
import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class FaceController extends GetxController {
  FaceController() {
    disTss();
  }
  CameraService cameraService = CameraService();
  late Future initializeControllerFuture;
  bool _detectingFaces = false;
  late Size imageSize;
  RxString title = "Camera".obs;
  Face? faceDetected;

  late FaceDetector _faceDetector;
  FaceDetector get faceDetector => this._faceDetector;
  disTss() async {
    initializeControllerFuture = cameraService.startService();
  }

  @override
  onReady() async {
    await initializeControllerFuture;
    this._faceDetector = GoogleMlKit.vision.faceDetector();

    imageSize = cameraService.getImageSize();

    cameraService.cameraController.startImageStream((image) async {
      if (cameraService.cameraController != null) {
        if (_detectingFaces) return;

        _detectingFaces = true;

        try {
          List<Face> faces = await getFacesFromImage(image);
          update();

          if (faces.isNotEmpty) {
            faceDetected = faces[0];
            await Future.delayed(Duration(milliseconds: 500));
            faces.clear();
            Get.back(result: true);
          } else {
            faceDetected = null;
          }

          _detectingFaces = false;
        } catch (e) {
          print(e);
          _detectingFaces = false;
        }
      }
    });
    super.onReady();
  }

  Future<List<Face>> getFacesFromImage(CameraImage image) async {
    InputImageData _firebaseImageMetadata = InputImageData(
      imageRotation: cameraService.cameraRotation,
      inputImageFormat: InputImageFormatMethods.fromRawValue(image.format.raw)!,
      size: Size(image.width.toDouble(), image.height.toDouble()),
      planeData: image.planes.map(
        (Plane plane) {
          return InputImagePlaneMetadata(
            bytesPerRow: plane.bytesPerRow,
            height: plane.height,
            width: plane.width,
          );
        },
      ).toList(),
    );

    InputImage _firebaseVisionImage = InputImage.fromBytes(
      bytes: image.planes[0].bytes,
      inputImageData: _firebaseImageMetadata,
    );

    List<Face> faces =
        await this._faceDetector.processImage(_firebaseVisionImage);
    return faces;
  }

  @override
  Future<void> onClose() async {
    // TODO: implement onClose
    cameraService.dispose();
    super.onClose();
  }
}
