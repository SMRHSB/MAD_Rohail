import 'dart:async';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/services.dart';

class DinoGame extends StatelessWidget {
 const DinoGame({super.key});

 @override
 Widget build(BuildContext context) {
   return MaterialApp(
     home: Scaffold(
       body: GameWidget(game: DinoRunnerGameLogic()),
     ),
   );
 }
}

class DinoRunnerGameLogic extends FlameGame with HasCollisionDetection, KeyboardEvents {
 late PlayerDino playerDino;
 late TextComponent scoreText;
 late Timer obstacleSpawner;
 int score =0;
 bool isGameOver= false;

 @override
 Future<void> onLoad() async {
   playerDino= PlayerDino();
   add(playerDino);

   scoreText= TextComponent(
     text:'Score :0',
     position :Vector2(20,20),
     textRenderer :TextPaint(style :const TextStyle(color :Colors.black,fontSize :24,fontWeight :FontWeight.bold)),
   );
   add(scoreText);

   obstacleSpawner= Timer(2,onTick :spawnObstacles,repeat :true);
 }

 @override
 void update(double dt) {
   super.update(dt);
   if (!isGameOver) { 
     obstacleSpawner.update(dt); 
     score += (dt *10).toInt(); 
     scoreText.text ='Score :$score'; 
   }
 }

 void spawnObstacles() { 
   if (!isGameOver) { 
     final obstacle= Obstacle(position :Vector2(size.x,size.y -80)); 
     add(obstacle); 
   } 
 }

 void gameOver() { 
   isGameOver= true; 
   pauseEngine(); 
   add(TextComponent( 
     text:'Game Over!\nTap to restart', 
     position :Vector2(size.x /2 -100,size.y /2), 
     textRenderer :TextPaint(style :const TextStyle(color :Colors.red,fontSize :32,fontWeight :FontWeight.bold)), 
   ));
 }

 @override
 KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) { 
   if (event is KeyDownEvent) { 
     if (event.logicalKey == LogicalKeyboardKey.space) { 
       playerDino.jump(); 
       return KeyEventResult.handled; 
     } 
   } 
   return KeyEventResult.ignored; 
 }
}

class PlayerDino extends PositionComponent with HasGameRef<DinoRunnerGameLogic>, CollisionCallbacks { 
  bool isJumping = false; 
  final double gravity = 900; 
  final double jumpForce = -400; 
  double yVelocity = 0; 
  double initialY = 0;
  
  final Paint paint = Paint()..color = Colors.green; // Define a Paint object for the dino
  
  PlayerDino() : super(size: Vector2(60, 60), position: Vector2(100, 300));

  @override
  Future<void> onLoad() async {
    // No need to define paint here, it's already done at the top
  }

  @override
  void update(double dt) {
    super.update(dt);  
    if (isJumping) {  
      yVelocity += gravity * dt;  
      position.y += yVelocity * dt;  
      
      if (position.y >= initialY) {  
        position.y = initialY;  
        isJumping = false;  
        yVelocity = 0;  
      }  
    }  
  }

  void jump() {  
    if (!isJumping) {  
      isJumping = true;  
      yVelocity = jumpForce;  
    }  
  }

  @override
  void render(Canvas canvas) {  
    super.render(canvas);  
    canvas.drawRect(toRect(), paint);  // Use the defined paint object
  }
} 

class Obstacle extends PositionComponent with HasGameRef<DinoRunnerGameLogic>, CollisionCallbacks {   
  final Paint paint = Paint()..color = Colors.red; // Define a Paint object for the obstacle
  
  Obstacle({required Vector2 position}) : super(size: Vector2(40, 40), position: position);   

  @override   
  void update(double dt) {   
    position.x -= 300 * dt;   
    if (position.x < -size.x) removeFromParent();   
  }   

  @override   
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {   
    super.onCollision(intersectionPoints, other);   
    if (other is PlayerDino) {   
      gameRef.gameOver();   
    }   
  }   

  @override   
  void render(Canvas canvas) {   
    super.render(canvas);   
    canvas.drawRect(toRect(), paint);  // Use the defined paint object for obstacle rendering
  }    
}
