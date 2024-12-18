import 'dart:async';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'dart:math';
import 'package:flutter/material.dart';

class SpaceInvaderGame extends StatelessWidget {
  const SpaceInvaderGame({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: GameWidget(game: SpaceInvaderGameLogic()),
      ),
    );
  }
}

class SpaceInvaderGameLogic extends FlameGame with HasCollisionDetection {
  late Player player;
  late TextComponent scoreText;
  int score = 0;
  Timer? enemySpawnTimer;

  @override
  Future<void> onLoad() async {
    player = Player();
    add(player);

    scoreText = TextComponent(
      text: 'Score: 0',
      position: Vector2(10, 10),
      textRenderer: TextPaint(style: const TextStyle(color: Colors.white, fontSize: 20)),
    );
    add(scoreText);

    enemySpawnTimer = Timer(1.5, onTick: () => spawnEnemies(), repeat: true);
  }

  @override
  void update(double dt) {
    super.update(dt);
    enemySpawnTimer?.update(dt);
  }

  void spawnEnemies() {
    final random = Random();
    final enemy = Enemy(position: Vector2(random.nextDouble() * (size.x - 50), -50));
    add(enemy);
  }

  void updateScore() {
    score += 10;
    scoreText.text = 'Score: $score';
  }
}

class Player extends PositionComponent with DragCallbacks, HasGameRef<SpaceInvaderGameLogic> {
  Player() : super(size: Vector2(50, 50)) {
    position = Vector2(200, 400);
  }

  double timeSinceLastShot = 0;
  final double shootInterval = 0.5;
  final Paint playerPaint = Paint()..color = Colors.green;

  @override
  void update(double dt) {
    super.update(dt);
    timeSinceLastShot += dt;
    if (timeSinceLastShot >= shootInterval) {
      shoot();
      timeSinceLastShot = 0;
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    position.x += event.localDelta.x;
    position.x = position.x.clamp(0, gameRef.size.x - size.x);
  }

  void shoot() {
    final bullet = Bullet(position: position + Vector2(size.x / 2 - 5, -10));
    gameRef.add(bullet);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRect(toRect(), playerPaint); // Draw the player using the paint
  }
}

class Bullet extends PositionComponent with HasGameRef<SpaceInvaderGameLogic>, CollisionCallbacks {
  Bullet({required Vector2 position}) : super(size: Vector2(10, 20), position: position);

  final Paint bulletPaint = Paint()..color = Colors.red;

  @override
  void update(double dt) {
    position.y -= 300 * dt;
    if (position.y < 0) removeFromParent();
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is Enemy) {
      removeFromParent();
      other.removeFromParent();
      gameRef.updateScore();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRect(toRect(), bulletPaint); // Draw the bullet using the paint
  }
}

class Enemy extends PositionComponent with HasGameRef<SpaceInvaderGameLogic>, CollisionCallbacks {
  Enemy({required Vector2 position}) : super(size: Vector2(50, 50), position: position);

  final Paint enemyPaint = Paint()..color = Colors.blue;

  @override
  void update(double dt) {
    position.y += 100 * dt;
    if (position.y > gameRef.size.y) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRect(toRect(), enemyPaint); // Draw the enemy using the paint
  }
}
