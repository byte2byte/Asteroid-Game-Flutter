import 'package:asteroid_game/Controllers/GameClass.dart';
import 'package:flutter/material.dart';
import 'Controllers/Spaceship.dart';
import 'View/GameScreen.dart';

void main() {
  Game game = Game(spaceship: Spaceship(x: 100, y: 100, angle: 0, speed: 0));

  runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Asteroids',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GameScreen(
        game: game,
      )));
}
