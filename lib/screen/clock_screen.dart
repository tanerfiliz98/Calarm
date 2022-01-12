import 'dart:math';

import 'package:calarm/controller/clock_controller.dart';
import 'package:calarm/util/clock_painter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ClockScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final formatHMS = DateFormat('Hms');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        GetBuilder<ClockController>(
            init: ClockController(),
            builder: (controller) => Text(formatHMS.format(controller.time),
                style: TextStyle(
                  fontSize: 45,
                  fontWeight: FontWeight.w900,
                ))),
        Padding(
          padding: const EdgeInsets.only(
            bottom: 15,
            left: 15,
            right: 15,
            top: 50,
          ),
        ),
        Expanded(
          child: Center(
              child: Container(
            width: 300,
            height: 300,
            child: Transform.rotate(
                angle: -pi / 2,
                child: CustomPaint(
                  painter: ClockPainter(),
                  child: GetBuilder<ClockController>(
                      builder: (controller) => CustomPaint(
                            painter: HandPainter(),
                          )),
                )),
          )),
        ),
      ],
    );
  }
}
