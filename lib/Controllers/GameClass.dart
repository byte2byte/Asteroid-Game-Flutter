import 'dart:math';
import 'Asteroid.dart';
import 'Bullets.dart';
import 'Spaceship.dart';

class Game {
  final List<Asteroid> asteroids = [];
  final List<Bullet> bullets = [];
  Spaceship spaceship;
  int score = 0;
  bool isGameOver = false;
  double minAsteroidSize = 50;
  double minAsteroidDistance = 100;
  int minNumAsteroids = 2;
  int level = 1;

  Game({required this.spaceship});

  void spawnAsteroid(double screenWidth, double screenHeight, Game game) {
    double x, y;
    do {
      x = Random().nextDouble() * screenWidth;
      y = Random().nextDouble() * screenHeight;
    } while ((x - spaceship.x) * (x - spaceship.x) +
            (y - spaceship.y) * (y - spaceship.y) <
        minAsteroidDistance * minAsteroidDistance);
    double size =
        max(Random().nextDouble() * 30 + minAsteroidSize, minAsteroidSize);
    double angle = Random().nextDouble() * pi * 2;
    double speed = Random().nextDouble() * 2 + 1;
    asteroids.add(Asteroid(
        x: x, y: y, size: size, angle: angle, speed: speed, game: game));
  }

  void redrawSpaceShip(double screenWidth, double screenHeight, Game game) {
    double x = spaceship.x;
    double y = spaceship.y;
    spaceship = Spaceship(x: x, y: y, angle: 0, speed: 0, game: game);
  }

  void shoot() {
    bullets.add(Bullet(x: spaceship.x, y: spaceship.y, angle: spaceship.angle));
  }

  void update(double screenWidth, double screenHeight, Game game) {
    // Update asteroids
    for (Asteroid asteroid in asteroids) {
      asteroid.update(screenWidth, screenHeight);
    }

    // Update spaceship
    spaceship.update(screenWidth, screenHeight);

    // Update bullets
    for (int i = bullets.length - 1; i >= 0; i--) {
      Bullet bullet = bullets[i];
      bool isAlive = bullet.update(screenWidth, screenHeight);
      if (!isAlive) {
        bullets.removeAt(i);
      }
    }

    // Check collisions
    for (int i = asteroids.length - 1; i >= 0; i--) {
      Asteroid asteroid = asteroids[i];
      bool isHit = false;

      // Check collision with spaceship
      double dx = asteroid.x - spaceship.x;
      double dy = asteroid.y - spaceship.y;
      double distance = sqrt(dx * dx + dy * dy);
      if (distance < asteroid.size) {
        isHit = true;
        isGameOver = true;
        break;
      }

      // Check collision with bullets
      for (int j = bullets.length - 1; j >= 0; j--) {
        Bullet bullet = bullets[j];
        dx = asteroid.x - bullet.x;
        dy = asteroid.y - bullet.y;
        distance = sqrt(dx * dx + dy * dy);
        if (distance < asteroid.size) {
          isHit = true;
          bullets.removeAt(j);
          score++;
          break;
        }
      }

      if (isHit) {
        asteroids.removeAt(i);
      }
    }

    // Ensure minimum number of asteroids
    while (asteroids.length < minNumAsteroids) {
      spawnAsteroid(screenWidth, screenHeight, game);
    }
  }
}
