import 'package:flutter/material.dart';

class AlarmContainer extends StatelessWidget {
  final Widget child;

  AlarmContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(
          bottom: 15,
          left: 15,
          right: 15,
          top: 50,
        ),
        child: child,
      ),
      appBar: null,
    );
  }
}
