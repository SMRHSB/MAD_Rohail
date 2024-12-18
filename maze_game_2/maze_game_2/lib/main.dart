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

  // Define solvable mazes for 3 levels (0 = empty space, 1 = wall)
  List<List<List<int>>> mazes = [
    [
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
      [1, 0, 1, 0, 0, 1, 0, 1, 0, 0, 1],
      [1, 0, 1, 0, 1, 1, 0, 1, 0, 0, 1],
      [1, 0, 0, 0, 0, 1, 0, 0, 0, 1, 1],
      [1, 1, 1, 0, 1, 1, 0, 1, 1, 1, 1],
      [1, 0, 1, 0, 0, 0, 0, 1, 0, 0, 1],
      [1, 0, 1, 1, 1, 1, 0, 0, 0, 1, 1],
      [1, 0, 0, 0, 0, 0, 1, 1, 0, 0, 1],
      [1, 1, 1, 0, 1, 0, 0, 0, 0, 0, 1],
      [1, 1, 1, 0, 1, 1, 1, 1, 1, 0, 1],
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
    ],
    [
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
      [1, 0, 0, 1, 1, 1, 0, 0, 1, 0, 1],
      [1, 1, 0, 1, 0, 1, 1, 0, 1, 0, 1],
      [1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 1],
      [1, 1, 1, 0, 1, 0, 1, 1, 0, 0, 1],
      [1, 0, 0, 0, 1, 0, 0, 0, 0, 1, 1],
      [1, 1, 1, 0, 0, 0, 1, 1, 0, 1, 1],
      [1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1],
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
    ],
    [
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
      [1, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1],
      [1, 0, 1, 1, 0, 1, 0, 1, 1, 1, 0, 0, 0, 1],
      [1, 0, 0, 0, 1, 1, 0, 1, 0, 1, 0, 0, 0, 1],
      [1, 1, 1, 0, 0, 0, 0, 1, 1, 0, 1, 0, 1, 1],
      [1, 0, 1, 0, 0, 0, 0, 1, 1, 1, 0, 0, 1, 1],
      [1, 1, 1, 1, 0, 0, 1, 0, 1, 0, 0, 0, 1, 1],
      [1, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 1],
      [1, 0, 1, 0, 1, 0, 0, 0, 0, 1, 0, 0, 1, 1],
      [1, 1, 1, 1, 0, 0, 0, 1, 0, 1, 0, 0, 0, 1],
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
    ]
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Maze Game')),
      body: Center(
        child: GestureDetector(
          onPanUpdate: (details) {
            // Ignore the gesture for now, we will use the keys to move the player
          },
          child: CustomPaint(
            size: Size(600, 600), // Increase size of maze view
            painter:
                MazePainter(mazes[level], playerX, playerY), // Current level
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
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

  // Start the level and start the stopwatch
  void startLevel() {
    playerX = 1;
    playerY = 1;
    stopwatch.reset();
    stopwatch.start();
    updateTime();
  }

  // Update the time displayed
  void updateTime() {
    if (stopwatch.isRunning) {
      setState(() {
        timeElapsed = formatTime(stopwatch.elapsedMilliseconds);
      });
      Future.delayed(Duration(milliseconds: 100), updateTime);
    }
  }

  // Format time in minutes:seconds format
  String formatTime(int milliseconds) {
    int seconds = (milliseconds ~/ 1000) % 60;
    int minutes = (milliseconds ~/ 60000);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // Listen for key presses for WASD movement
  void _listenForKeyPress() {
    RawKeyboard.instance.addListener((event) {
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
    });
  }

  // Move the player based on input
  void movePlayer(String direction) {
    setState(() {
      List<List<int>> maze = mazes[level];
      if (direction == 'W' && maze[playerY - 1][playerX] == 0) playerY--;
      if (direction == 'S' && maze[playerY + 1][playerX] == 0) playerY++;
      if (direction == 'A' && maze[playerY][playerX - 1] == 0) playerX--;
      if (direction == 'D' && maze[playerY][playerX + 1] == 0) playerX++;
    });

    // Check if player has reached the end of the maze (bottom-right corner)
    if (playerX == mazes[level][0].length - 2 &&
        playerY == mazes[level].length - 2) {
      stopwatch.stop();
      showLevelCompleteDialog();
    }
  }

  // Show dialog when a level is completed
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
                    startLevel(); // Start the next level
                  } else {
                    showGameCompleteDialog(); // All levels completed
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

  // Show dialog when the game is completed with Easter egg
  void showGameCompleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Game Complete!'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('You have completed all levels!'),
              SizedBox(height: 20),
              Text(
                'Easter Egg: Ah, the joy of creating this "simple" game. What started as a straightforward maze game became an epic saga of confusion and frustration. The developer, a complete novice, managed to turn every basic task into an impossible challenge. From misaligned layouts to bugs that seemed to have a vendetta, it was a journey filled with despair, caffeine, and countless rewrites. At some point, the maze became less of a puzzle and more of a metaphor for the his state of mind. Who knew a "simple" game could feel like running a marathon in a maze while blindfolded?',
                style:
                    TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  level = 0; // Reset game to level 1
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

    // Draw the maze
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

    // Draw the start position (blue)
    canvas.drawCircle(
      Offset(cellSize / 2, cellSize / 2),
      cellSize / 4,
      startPaint,
    );

    // Draw the end position (green)
    canvas.drawCircle(
      Offset((maze[0].length - 2) * cellSize + cellSize / 2,
          (maze.length - 2) * cellSize + cellSize / 2),
      cellSize / 4,
      endPaint,
    );

    // Draw the player
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
