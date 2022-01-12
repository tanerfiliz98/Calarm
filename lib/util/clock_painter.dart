import 'dart:math';

import 'package:calarm/controller/clock_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HandPainter extends CustomPainter {
  ClockController c = Get.find<ClockController>();
  @override
  void paint(Canvas canvas, Size size) {
    var centerY = size.height / 2;
    var centerX = size.width / 2;
    var center = Offset(centerX, centerY);
    var secHandBrush = Paint()
      ..color = Colors.lightBlueAccent
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5;
    var hourHandBrush = Paint()
      ..color = Colors.cyanAccent
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 15;
    var minHandBrush = Paint()
      ..color = Colors.blueAccent
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 10;
    var centerDotBrush = Paint()..color = Color(0xffeaecff);

    var secHandX =
        centerX + ((90 * centerY) / 150) * cos(c.time.second * 6 * pi / 180);
    var secHandY =
        centerY + ((90 * centerY) / 150) * sin(c.time.second * 6 * pi / 180);
    var minHandX =
        centerX + ((80 * centerY) / 150) * cos(c.time.minute * 6 * pi / 180);
    var minHandY =
        centerY + ((80 * centerY) / 150) * sin(c.time.minute * 6 * pi / 180);
    var hourHandX = centerX +
        ((60 * centerY) / 150) *
            cos((c.time.hour * 30 + c.time.minute * 0.5) * pi / 180);
    var hourHandY = centerY +
        ((60 * centerY) / 150) *
            sin((c.time.hour * 30 + c.time.minute * 0.5) * pi / 180);

    canvas.drawLine(center, Offset(hourHandX, hourHandY), hourHandBrush);
    canvas.drawLine(center, Offset(minHandX, minHandY), minHandBrush);
    canvas.drawLine(center, Offset(secHandX, secHandY), secHandBrush);

    canvas.drawCircle(center, 10, centerDotBrush);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class ClockPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var centerY = size.height / 2;
    var centerX = size.width / 2;
    var center = Offset(centerX, centerY);
    var radius = min(centerY, centerY);
    var outBrush = Paint()
      ..color = Color(0xffeaecff)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15;
    var fillBrush = Paint()..color = Color(0xff444974);
    var minTickBrush = Paint()
      ..color = Colors.deepOrangeAccent
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 8;
    var secTickBrush = Paint()
      ..color = Colors.orangeAccent
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4;
    canvas.drawCircle(center, radius, fillBrush);

    canvas.drawCircle(center, radius, outBrush);
    var outerCircleRadius = radius - 14;
    var innerCircleRadius = radius - 18;
    for (double i = 0; i < 360; i += 6) {
      var x1 = centerX + outerCircleRadius * cos(i * pi / 180);
      var y1 = centerY + outerCircleRadius * sin(i * pi / 180);

      var x2 = centerX + innerCircleRadius * cos(i * pi / 180);
      var y2 = centerY + innerCircleRadius * sin(i * pi / 180);
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), secTickBrush);
    }
    for (double i = 0; i < 360; i += 30) {
      var x1 = centerX + (outerCircleRadius - 5) * cos(i * pi / 180);
      var y1 = centerY + (outerCircleRadius - 5) * sin(i * pi / 180);

      var x2 = centerX + (innerCircleRadius + 5) * cos(i * pi / 180);
      var y2 = centerY + (innerCircleRadius + 5) * sin(i * pi / 180);
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), minTickBrush);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
