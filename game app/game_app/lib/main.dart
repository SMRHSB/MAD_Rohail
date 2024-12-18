import 'package:flutter/material.dart';
import 'space_invader_game.dart';
import 'dino_runner_game.dart';

void main() {
  runApp(const MyGameApp());
}

class MyGameApp extends StatelessWidget {
  const MyGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Game Selector',
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select a Game'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SpaceInvaderGame()),
                );
              },
              child: const Text('Play Space Invader'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DinoGame()),
                );
              },
              child: const Text('Play Dino Runner'),
            ),
          ],
        ),
      ),
    );
  }
}
