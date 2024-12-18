import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';

void main() => runApp(MazeGame());

class MazeGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Maze Game',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MazeScreen(),
    );
  }
}

class MazeScreen extends StatefulWidget {
  @override
  _MazeScreenState createState() => _MazeScreenState();
}

class _MazeScreenState extends State<MazeScreen> {
  int playerX = 1;
  int playerY = 1;
  int level = 0;
  Stopwatch stopwatch = Stopwatch();
  String timeElapsed = '0:00';
  int remainingTime = 5; // Timer starts with 5 seconds
  Timer? countdownTimer;

  List<List<List<int>>> mazes = [
    [
      [1, 1, 1, 1, 1],
      [1, 0, 0, 0, 1],
      [1, 1, 1, 0, 1],
      [1, 0, 0, 0, 1],
      [1, 1, 1, 1, 1],
    ],
    [
      [1, 1, 1, 1, 1],
      [1, 0, 1, 0, 1],
      [1, 0, 1, 0, 1],
      [1, 0, 0, 0, 1],
      [1, 1, 1, 1, 1],
    ],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Maze Game')),
      body: Center(
        child: GestureDetector(
          onPanUpdate: (details) {
            if (details.delta.dy < 0) movePlayer('W');
            if (details.delta.dy > 0) movePlayer('S');
            if (details.delta.dx < 0) movePlayer('A');
            if (details.delta.dx > 0) movePlayer('D');
          },
          child: CustomPaint(
            size: Size(600, 600),
            painter: MazePainter(mazes[level], playerX, playerY),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Level: ${level + 1}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                'Time: $timeElapsed',
                style: TextStyle(fontSize: 18),
              ),
              Text(
                'Remaining Time: $remainingTime seconds',
                style: TextStyle(fontSize: 18, color: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    startLevel();
    _listenForKeyPress();
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    RawKeyboard.instance.removeListener(_keyListener);
    super.dispose();
  }

  void startLevel() {
    playerX = 1;
    playerY = 1;
    stopwatch.reset();
    stopwatch.start();
    remainingTime = 5;
    startCountdown();
    updateTime();
  }

  void startCountdown() {
    countdownTimer?.cancel();
    countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        remainingTime--;
        if (remainingTime <= 0) {
          countdownTimer?.cancel();
          stopwatch.stop();
          showTimeOutDialog();
        }
      });
    });
  }

  void updateTime() {
    if (stopwatch.isRunning) {
      setState(() {
        timeElapsed = formatTime(stopwatch.elapsedMilliseconds);
      });
      Future.delayed(Duration(milliseconds: 100), updateTime);
    }
  }

  String formatTime(int milliseconds) {
    int seconds = (milliseconds ~/ 1000) % 60;
    int minutes = (milliseconds ~/ 60000);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _listenForKeyPress() {
    RawKeyboard.instance.addListener(_keyListener);
  }

  void _keyListener(RawKeyEvent event) {
    if (event.runtimeType == RawKeyDownEvent) {
      switch (event.logicalKey.keyLabel) {
        case 'W':
          movePlayer('W');
          break;
        case 'A':
          movePlayer('A');
          break;
        case 'S':
          movePlayer('S');
          break;
        case 'D':
          movePlayer('D');
          break;
      }
    }
  }

  void movePlayer(String direction) {
    setState(() {
      List<List<int>> maze = mazes[level];
      if (direction == 'W' && playerY > 0 && maze[playerY - 1][playerX] == 0) playerY--;
      if (direction == 'S' && playerY < maze.length - 1 && maze[playerY + 1][playerX] == 0) playerY++;
      if (direction == 'A' && playerX > 0 && maze[playerY][playerX - 1] == 0) playerX--;
      if (direction == 'D' && playerX < maze[0].length - 1 && maze[playerY][playerX + 1] == 0) playerX++;
    });

    if (playerX == mazes[level][0].length - 2 &&
        playerY == mazes[level].length - 2) {
      countdownTimer?.cancel();
      stopwatch.stop();
      showLevelCompleteDialog();
    }
  }

  void showLevelCompleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Level ${level + 1} Complete!'),
          content: Text('Time taken: $timeElapsed'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  level++;
                  if (level < mazes.length) {
                    startLevel();
                  } else {
                    showGameCompleteDialog();
                  }
                });
              },
              child: Text('Next Level'),
            ),
          ],
        );
      },
    );
  }

  void showTimeOutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Time's Up!"),
          content: Text('You ran out of time. Try again.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  startLevel();
                });
              },
              child: Text('Retry'),
            ),
          ],
        );
      },
    );
  }

  void showGameCompleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Game Complete!'),
          content: Text('Congratulations! You completed all levels.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  level = 0;
                  startLevel();
                });
              },
              child: Text('Restart'),
            ),
          ],
        );
      },
    );
  }
}

class MazePainter extends CustomPainter {
  final List<List<int>> maze;
  final int playerX;
  final int playerY;

  MazePainter(this.maze, this.playerX, this.playerY);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = Colors.black;
    Paint playerPaint = Paint()..color = Colors.red;
    Paint startPaint = Paint()..color = Colors.blue;
    Paint endPaint = Paint()..color = Colors.green;

    double cellSize = size.width / maze[0].length;

    for (int y = 0; y < maze.length; y++) {
      for (int x = 0; x < maze[y].length; x++) {
        if (maze[y][x] == 1) {
          canvas.drawRect(
            Rect.fromLTWH(x * cellSize, y * cellSize, cellSize, cellSize),
            paint,
          );
        }
      }
    }

    canvas.drawCircle(
      Offset(cellSize / 2, cellSize / 2),
      cellSize / 4,
      startPaint,
    );

    canvas.drawCircle(
      Offset((maze[0].length - 2) * cellSize + cellSize / 2,
          (maze.length - 2) * cellSize + cellSize / 2),
      cellSize / 4,
      endPaint,
    );

    canvas.drawCircle(
      Offset(
          playerX * cellSize + cellSize / 2, playerY * cellSize + cellSize / 2),
      cellSize / 4,
      playerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
