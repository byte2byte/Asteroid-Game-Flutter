import 'dart:async';
import 'dart:math';
import 'package:asteroid_game/Controllers/GameClass.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';

import '../Controllers/Asteroid.dart';
import '../Controllers/Bullets.dart';

class GameScreen extends StatefulWidget {
  final Game game;

  GameScreen({required this.game});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final Paint asteroidPaint = Paint()..color = Colors.orange;
  final Paint spaceshipPaint = Paint()..color = Colors.white;
  final Paint bulletPaint = Paint()..color = Colors.white;
  final Paint textPaint = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;

  //
  //
  //
  //
  //

  late DateTime gameStartTime;
  late Duration timeElapsed;
  String currentTime = '00:00';
  late Timer timer;
  bool gameStarted = false;
  int currentLevel = 1;
  late DateTime leveUpdated;

  void startGame() {
    // Set the game start time to the current time
    gameStartTime = DateTime.now();
    leveUpdated = DateTime.now();
    gameStarted = true;
    widget.game.isGameOver = false;
    widget.game.score = 0;
    currentLevel = 1;
    widget.game.level = 1;
    widget.game.asteroids.clear();
    widget.game.bullets.clear();

    // Start the timer to update the current time every second
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // Calculate the time elapsed since the game started
      timeElapsed = DateTime.now().difference(gameStartTime);
      Duration levelElapsedTime = DateTime.now().difference(leveUpdated);
      if (timeElapsed.inSeconds == 55 && timeElapsed.inMinutes == 0) {
        // endGame();
      }
      if (levelElapsedTime.inSeconds == 5 && widget.game.level != 5) {
        leveUpdated = DateTime.now();
        currentLevel++;
        widget.game.level++;
        setState(() {});
      }

      if (widget.game.isGameOver) {
        endGame();
      }

      // Update the current time
      int minutes = timeElapsed.inMinutes;
      int seconds = timeElapsed.inSeconds % 60;
      currentTime =
          '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
      setState(() {});
    });
  }

  // Stop the timer when the game ends
  void endGame() {
    // Cancel the timer
    timer.cancel();
    gameStarted = false;
    setState(() {});
  }

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      final RenderBox box = context.findRenderObject() as RenderBox;
      double screenWidth = box.size.width;
      double screenHeight = box.size.height;

      // Start game loop
      Duration lastFrameTime = Duration.zero;
      void gameLoop(Duration timestamp) {
        if (lastFrameTime == Duration.zero) {
          lastFrameTime = timestamp;
        }
        lastFrameTime = timestamp;

        // Update game state
        if (gameStarted && !widget.game.isGameOver) {
          widget.game.update(screenWidth, screenHeight, widget.game);
          if (widget.game.level == 3) {
            widget.game.redrawSpaceShip(screenWidth, screenHeight, widget.game);
          }
        }

        setState(() {});

        // Schedule next frame
        WidgetsBinding.instance.scheduleFrameCallback(gameLoop);
      }

      WidgetsBinding.instance.scheduleFrameCallback(gameLoop);

      // Spawn new asteroids at regular intervals
      Timer.periodic(const Duration(seconds: 5), (timer) {
        if (gameStarted && !widget.game.isGameOver) {
          widget.game.spawnAsteroid(screenWidth, screenHeight, widget.game);
        }
      });
    });
    super.initState();
  }

//
//
//
//
//

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: gameStarted
          ? Stack(
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    double screenWidth = constraints.maxWidth;
                    double screenHeight = constraints.maxHeight;
                    return RawKeyboardListener(
                      focusNode: FocusNode(),
                      autofocus: true,
                      onKey: (event) {
                        if (event is RawKeyDownEvent) {
                          if (event.logicalKey ==
                              LogicalKeyboardKey.arrowLeft) {
                            widget.game.spaceship.angle -= pi / 10;
                          } else if (event.logicalKey ==
                              LogicalKeyboardKey.arrowRight) {
                            widget.game.spaceship.angle += pi / 10;
                          }
                        }
                      },
                      child: MouseRegion(
                        onHover: (event) {
                          if (!widget.game.isGameOver) {
                            widget.game.spaceship.x = event.position.dx;
                            widget.game.spaceship.y = event.position.dy;
                          }
                        },
                        child: GestureDetector(
                          onTap: () {
                            if (!widget.game.isGameOver &&
                                widget.game.level >= 3) {
                              widget.game.shoot();
                            }
                          },
                          child: Stack(
                            children: [
                              CustomPaint(
                                size: Size(screenWidth, screenHeight),
                                painter: GamePainter(
                                  game: widget.game,
                                  asteroidPaint: asteroidPaint,
                                  spaceshipPaint: spaceshipPaint,
                                  bulletPaint: bulletPaint,
                                  textPaint: textPaint,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(
                      horizontal: screenSize.width * 0.02,
                      vertical: screenSize.height * 0.03),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Timer: $currentTime",
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Level: $currentLevel",
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                )
              ],
            )
          : widget.game.isGameOver
              ? getGameOverContainer(screenSize)
              : getStartMethod(screenSize),
    );
  }

  SizedBox getGameCanvas(Size screenSize) {
    return SizedBox(
      height: screenSize.height,
      width: screenSize.width,
      child: Stack(
        children: [
          SizedBox(
            child: GameScreen(game: widget.game),
          ),
          Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(
                horizontal: screenSize.width * 0.02,
                vertical: screenSize.height * 0.03),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Timer: $currentTime",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  "Level: $currentLevel",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  SizedBox getGameOverContainer(Size screenSize) {
    return SizedBox(
        height: screenSize.height,
        width: screenSize.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            const Text(
              "GAME OVER",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 50,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              "You have lasted ${timeElapsed.inMinutes} minutes and ${timeElapsed.inSeconds} seconds",
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    padding: const EdgeInsets.all(18)),
                onPressed: () {
                  startGame();
                },
                child: const Text(
                  "Try Again!",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ))
          ],
        ));
  }

  SizedBox getStartMethod(Size screenSize) {
    return SizedBox(
      height: screenSize.height,
      width: screenSize.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          const Text(
            "Let's Start The Space Travel!!!",
            style: TextStyle(
                color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  padding: const EdgeInsets.all(18)),
              onPressed: () {
                startGame();
              },
              child: const Text(
                "START!",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ))
        ],
      ),
    );
  }
}

class GamePainter extends CustomPainter {
  final Game game;
  final Paint asteroidPaint;
  final Paint spaceshipPaint;
  final Paint bulletPaint;
  final Paint textPaint;

  GamePainter({
    required this.game,
    required this.asteroidPaint,
    required this.spaceshipPaint,
    required this.bulletPaint,
    required this.textPaint,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw asteroids
    for (Asteroid asteroid in game.asteroids) {
      asteroid.draw(canvas, asteroidPaint);
    }

    // Draw spaceship
    game.spaceship.draw(canvas, spaceshipPaint);

    // Draw bullets
    for (Bullet bullet in game.bullets) {
      bullet.draw(canvas, bulletPaint);
    }

    // Draw score
    ui.ParagraphBuilder builder = ui.ParagraphBuilder(ui.ParagraphStyle(
        fontSize: 30,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr))
      ..pushStyle(ui.TextStyle(color: textPaint.color))
      ..addText('Score: ${game.score}');
    ui.Paragraph paragraph = builder.build()
      ..layout(ui.ParagraphConstraints(width: size.width));
    canvas.drawParagraph(paragraph, Offset(0, size.height - paragraph.height));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
