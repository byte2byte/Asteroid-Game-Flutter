import 'dart:math';

import 'package:flutter/material.dart';

class Bullet {
  double x;
  double y;
  final double angle;

  Bullet({required this.x, required this.y, required this.angle});

  void draw(Canvas canvas, Paint paint) {
    canvas.drawCircle(Offset(x, y), 2, paint);
  }

  bool update(double screenWidth, double screenHeight) {
    x += cos(angle) * 10;
    y += sin(angle) * 10;

    if (x < 0 || x > screenWidth || y < 0 || y > screenHeight) {
      return false;
    }
    return true;
  }
}
