import 'package:dars_4/objects/health_bar.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';

import 'actors/actors.dart';
import 'managers/segment_manager.dart';
import 'objects/objects.dart';
import 'overlays/overlays.dart';

class EmberQuestGame extends FlameGame
    with HasCollisionDetection, HasKeyboardHandlerComponents {
  late double lastBlockXPosition = 0.0;
  late UniqueKey lastBlockKey;
  late List<List<ObjectBlock>> randomSegments;
  double objectSpeed = 0.0;
  late EmberPlayer _ember;
  int starsCollected = 0;
  int health = 3;
  final audioPlayer = AudioPlayer();

  // Timer-related variables
  late TimerComponent gameTimer;
  int remainingTime = 60; // Start with 60 seconds for the first level
  int requiredStars = 5; // Start with 5 stars for the first level
  int currentLevel = 1;

  @override
  Future<void> onLoad() async {
    await images.loadAll([
      'block.png',
      'ember.png',
      'ground.png',
      'heart_half.png',
      'heart.png',
      'star.png',
      'water_enemy.png',
      'sand.png',
      'fire.png',
    ]);
    await FlameAudio.audioCache.loadAll([
      'gun.mp3',
      'game_over.mp3',
      'jump.mp3',
    ]);

    camera.viewfinder.anchor = Anchor.topLeft;
    camera.viewport.add(Hud());
  }

  void start() {
    initializeGame(true);
    startTimer();
  }

  void initializeGame(bool loadHud) {
    randomSegments = generateRandomSegments(10);

    // Assume that size.x < 3200
    final segmentsToLoad = (size.x / 320).ceil();
    segmentsToLoad.clamp(0, randomSegments.length);

    for (var i = 0; i <= segmentsToLoad; i++) {
      loadGameSegments(i, (320 * i).toDouble());
    }

    _ember = EmberPlayer(
      position: Vector2(64, canvasSize.y - 128),
    );
    add(_ember);

    if (loadHud) {
      add(Hud());
    }
  }

  void loadGameSegments(int segmentIndex, double xPositionOffset) {
    int lastGroundBlockX = -4;

    for (final block in randomSegments[segmentIndex]) {
      if (block.blockType is GroundBlock) {
        final gridX = block.gridPosition.x.toInt();
        if (gridX - lastGroundBlockX > 3) {
          for (int i = lastGroundBlockX + 1; i < gridX; i++) {
            world.add(
              GroundBlock(
                gridPosition: Vector2(i.toDouble(), block.gridPosition.y),
                xOffset: xPositionOffset,
              ),
            );
          }
        }
        lastGroundBlockX = gridX;
      }

      switch (block.blockType) {
        case const (GroundBlock):
          world.add(GroundBlock(
              gridPosition: block.gridPosition, xOffset: xPositionOffset));
          break;
        case const (PlatformBlock):
          world.add(PlatformBlock(
              gridPosition: block.gridPosition, xOffset: xPositionOffset));
          break;
        case const (Star):
          world.add(
              Star(gridPosition: block.gridPosition, xOffset: xPositionOffset));
          break;
        case const (WaterEnemy):
          final waterEnemy = WaterEnemy(
            gridPosition: block.gridPosition,
            xOffset: xPositionOffset,
            health: 5,
          );
          final healthBar =
              HealthBar(enemy: waterEnemy, maxWidth: waterEnemy.size.x);
          world.add(waterEnemy);
          world.add(healthBar);
          break;
        case const (SandEnemy):
          final sandEnemy = SandEnemy(
            gridPosition: block.gridPosition,
            xOffset: xPositionOffset,
          );
          final healthBar =
              HealthBar(enemy: sandEnemy, maxWidth: sandEnemy.size.x);
          world.add(sandEnemy);
          world.add(healthBar);
          break;
      }
    }
  }

  void reset() {
    // Clear existing game objects
    world.removeAll(world.children.query<PositionComponent>());
    starsCollected = 0;
    health = 3;
    remainingTime = 60;
    requiredStars = 5;
    currentLevel = 1;
    _ember.removeFromParent();

    // Generate new random segments
    randomSegments = generateRandomSegments(10);
    initializeGame(false);
    startTimer();
  }

  void movePlayer(Direction direction) {
    switch (direction) {
      case Direction.left:
        _ember.horizontalDirection = -1;
        break;
      case Direction.right:
        _ember.horizontalDirection = 1;
        break;
      case Direction.none:
        break;
    }
  }

  void jumpPlayer() {
    _ember.hasJumped = true;
    FlameAudio.play('jump.mp3');
  }

  void stopPlayer() {
    _ember.horizontalDirection = 0;
  }

  void fireWeapon() {
    final fireWeapon = FireWeapon(
      initialPosition: _ember.position +
          Vector2(16, 0), // Position the fireball relative to the player
      direction: _ember.direction == Direction.left
          ? Vector2(-0.5, 0)
          : Vector2(0.5, 0), // Move to the right
    );
    add(fireWeapon);
    FlameAudio.play('gun.mp3');
  }

  @override
  Color backgroundColor() {
    return const Color.fromARGB(255, 173, 223, 247);
  }

  @override
  void update(double dt) {
    if ((health <= 0 || remainingTime <= 0) &&
        starsCollected != requiredStars) {
      playSound('audio/game_over.mp3');
      overlays.add('GameOver');
      gameTimer.timer.stop();
    }
    super.update(dt);
  }

  void playSound(String path) async {
    await audioPlayer.play(AssetSource(path));
  }

  void startTimer() {
    gameTimer = TimerComponent(
      period: 1,
      repeat: true,
      onTick: () {
        remainingTime--;
        if (remainingTime <= 0) {
          gameTimer.timer.stop();
        }
        checkGameEnd();
      },
    );
    add(gameTimer);
  }

  void checkGameEnd() {
    if (starsCollected >= requiredStars) {
      // Move to next level
      overlays.add('NextLevel');
      gameTimer.timer.stop();
    }
  }

  void startNextLevel() {
    world.removeAll(world.children.query<PositionComponent>());
    currentLevel++;
    starsCollected = 0;
    health = 3;
    remainingTime = 60 * (currentLevel / 2).round();
    requiredStars = requiredStars * currentLevel;
    _ember.removeFromParent();
    initializeGame(false);
    startTimer();
  }
}
