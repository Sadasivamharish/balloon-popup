import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TimerGame(),
    );
  }
}

class Balloon {
  Offset position;
  final List<Color> colors;

  Balloon(this.position, this.colors);
}

class TimerGame extends StatefulWidget {
  @override
  _TimerGameState createState() => _TimerGameState();
}

class _TimerGameState extends State<TimerGame> {
  int _seconds = 120; // 2 minutes
  int _score = 0;
  int _missedBalloons = 0; // New variable to track missed balloons
  late Timer _timer;
  List<Balloon> balloons = [];

  final List<Color> balloonColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.orange,
    Colors.purple,
    Colors.pink,
    Colors.teal,
  ];

  bool _gameStarted = false;
  bool _timeOver = false;

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer when the widget is disposed to prevent memory leaks
    super.dispose();
  }

  void startGame() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_seconds > 0) {
        setState(() {
          _seconds--;
          _generateBalloon();
          _moveBalloons();
        });

        // Check for missed balloons
        bool missedBalloon = false;
        for (var balloon in balloons) {
          if (balloon.position.dy <= 0) {
            missedBalloon = true;
            break;
          }
        }

        if (missedBalloon) {
          setState(() {
            _score -= 1; // Penalty for missed balloon
            _missedBalloons++; // Increment missed balloons count
          });
        }
      } else {
        _timer.cancel();
        setState(() {
          _timeOver = true;
        });
      }
    });
    setState(() {
      _gameStarted = true;
    });
  }

  void _generateBalloon() {
    final random = Random();
    double positionX = random.nextDouble() * MediaQuery.of(context).size.width;
    double positionY = MediaQuery.of(context).size.height;
    List<Color> colors = List.generate(3, (_) => balloonColors[random.nextInt(balloonColors.length)]);
    balloons.add(Balloon(Offset(positionX, positionY), colors));
  }

  void _moveBalloons() {
    for (int i = 0; i < balloons.length; i++) {
      balloons[i].position = Offset(balloons[i].position.dx, balloons[i].position.dy - 15); // Increase the value to make balloons move faster
    }
  }

  void _popBalloon(int index) {
    // Play burst animation or effect here
    setState(() {
      _score += 2; // Increase score by 2 for popping any balloon
      balloons.removeAt(index);
    });
  }

  void resetGame() {
    setState(() {
      _seconds = 10; // Reset time to 2 minutes
      _score = 0; // Reset score
      _missedBalloons = 0; // Reset missed balloons count
      _gameStarted = false;
      _timeOver = false;
      balloons.clear(); // Clear balloons
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Balloon Pop Game'),
      ),
      backgroundColor: Colors.black, // Set the background color to black
      body: Stack(
        children: [
          if (_gameStarted && !_timeOver)
            for (var i = 0; i < balloons.length; i++)
              Positioned(
                left: balloons[i].position.dx,
                top: balloons[i].position.dy,
                child: GestureDetector(
                  onTap: () {
                    _popBalloon(i);
                  },
                  child: CustomPaint(
                    size: Size(50, 70),
                    painter: BalloonPainter(balloons[i].colors),
                  ),
                ),
              ),
          if (!_gameStarted)
            Center(
              child: ElevatedButton(
                onPressed: startGame,
                child: Text('Start Game'),
              ),
            ),
          if (_timeOver)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Time\'s Up!',
                    style: TextStyle(fontSize: 24, color: Colors.white),
                  ),
                  Text(
                    'Final Score: $_score',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                  ElevatedButton(
                    onPressed: resetGame,
                    child: Text('Replay'),
                  ),
                ],
              ),
            ),
          Positioned(
            top: 16.0,
            right: 16.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Time: $_seconds', style: TextStyle(color: Colors.white)),
                Text('Score: $_score', style: TextStyle(color: Colors.white)),
                Text('Missed: $_missedBalloons', style: TextStyle(color: Colors.white)), // Display missed balloons count
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BalloonPainter extends CustomPainter {
  final List<Color> colors;

  BalloonPainter(this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint();
    final double balloonRadius = size.width / 2;
    final double threadLength = size.height - balloonRadius;

    // Draw threads
    for (int i = 0; i < 3; i++) {
      paint.color = colors[i];
      final Offset start = Offset(size.width / 2, size.height);
      final Offset end = Offset(size.width / 2, size.height - threadLength * (i + 1) / 4);
      canvas.drawLine(start, end, paint);
    }

    // Draw balloon
    paint.color = colors.last;
    canvas.drawCircle(Offset(size.width / 2, balloonRadius), balloonRadius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}