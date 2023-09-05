import 'dart:math';

import 'package:flutter/material.dart';

import 'GameClass.dart';

class Asteroid {
  double x;
  double y;
  Game? game;
  final double size;
  final double angle;
  final double speed;
  final List<Offset> points;

  Asteroid(
      {required this.x,
      required this.y,
      required this.size,
      required this.angle,
      required this.speed,
      this.game})
      : points = _generateRandomPoints(size);

  void draw(Canvas canvas, Paint paint) {
    Path path = Path();
    if (game == null) {
      canvas.drawCircle(Offset(x, y), size, paint);
    } else {
      if (game!.level < 5) {
        canvas.drawCircle(Offset(x, y), size, paint);
      } else {
        path.addPolygon(
            points.map((point) => Offset(x + point.dx, y + point.dy)).toList(),
            true);
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

  static List<Offset> _generateRandomPoints(double size) {
    int numPoints =
        Random().nextInt(4) + 4; // Random number of points between 3 and 6
    List<double> angles =
        List.generate(numPoints, (_) => Random().nextDouble() * pi * 2);
    angles.sort();
    return angles
        .map((angle) => Offset(cos(angle) * size, sin(angle) * size))
        .toList();
  }
}
