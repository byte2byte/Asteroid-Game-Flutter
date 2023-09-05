import 'dart:math';

import 'package:flutter/material.dart';

import 'GameClass.dart';

class Spaceship {
  double x;
  double y;
  double angle;
  Game? game;
  final double speed;

  Spaceship(
      {required this.x,
      required this.y,
      this.game,
      required this.angle,
      required this.speed});

  void draw(Canvas canvas, Paint paint) {
    Path path = Path();
    if (game == null) {
      canvas.drawCircle(Offset(x, y), 25, paint);
    } else {
      if (game!.level <= 3) {
        canvas.drawCircle(Offset(x, y), 25, paint);
      } else {
        path.moveTo(x + cos(angle) * 20, y + sin(angle) * 20);
        path.lineTo(
            x + cos(angle + pi * 3 / 4) * 20, y + sin(angle + pi * 3 / 4) * 20);
        path.lineTo(
            x + cos(angle - pi * 3 / 4) * 20, y + sin(angle - pi * 3 / 4) * 20);
        path.close();
        canvas.drawPath(path, paint);
      }
    }
  }

  void update(double screenWidth, double screenHeight) {
    x += cos(angle) * speed;
    y += sin(angle) * speed;

    if (x < 0) x = screenWidth;
    if (x > screenWidth) x = 0;
    if (y < 0) y = screenHeight;
    if (y > screenHeight) y = 0;
  }
}
