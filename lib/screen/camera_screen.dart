import 'package:calarm/controller/face_controller.dart';
import 'package:calarm/util/face_painter.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CameraScreen extends StatelessWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final heightScreen = MediaQuery.of(context).size.height * 0.9;
    return Container(
      height: heightScreen,
      child: Stack(
        children: [
          Center(
            child: GetX<FaceController>(
                init: FaceController(),
                builder: (controller) {
                  controller.title.value;
                  return FutureBuilder<void>(
                      future: controller.initializeControllerFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          return Transform.scale(
                            scale: 1.0,
                            child: AspectRatio(
                              aspectRatio:
                                  MediaQuery.of(context).size.aspectRatio,
                              child: OverflowBox(
                                alignment: Alignment.center,
                                child: FittedBox(
                                  fit: BoxFit.fitHeight,
                                  child: Container(
                                    width: width,
                                    height: width *
                                        controller.cameraService
                                            .cameraController.value.aspectRatio,
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: <Widget>[
                                        CameraPreview(controller
                                            .cameraService.cameraController),
                                        GetBuilder<FaceController>(
                                            builder: (_) {
                                          return CustomPaint(
                                            painter: FacePainter(
                                                face: _.faceDetected,
                                                imageSize: _.cameraService
                                                    .getImageSize()),
                                          );
                                        })
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        } else {
                          return CircularProgressIndicator();
                        }
                      });
                }),
          ),
        ],
      ),
    );
  }
}
