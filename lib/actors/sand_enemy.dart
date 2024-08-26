import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';

import '../ember_quest.dart';
import '../objects/objects.dart';

class SandEnemy extends SpriteAnimationComponent
    with CollisionCallbacks, HasGameReference<EmberQuestGame> {
  final Vector2 gridPosition;
  double xOffset;
  int health = 15;

  final Vector2 velocity = Vector2.zero();

  SandEnemy({
    required this.gridPosition,
    required this.xOffset,
  }) : super(size: Vector2(64, 71), anchor: Anchor.bottomLeft);

  @override
  @override
  void onLoad() {
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('sand.png'),
      SpriteAnimationData.sequenced(
        amount: 4,
        textureSize: Vector2(64, 71),
        stepTime: 0.70,
      ),
    );

    // SandEnemy'ni chapga siljitish va yerga tushirish
    position = Vector2(
        (gridPosition.x * size.x) +
            xOffset +
            20, // x koordinatani biroz kamaytirib chapga siljitish
        game.size.y - size.y / 2 // SandEnemy ni yerga tushirish
        );

    add(RectangleHitbox(collisionType: CollisionType.active));
    add(CircleHitbox());

    add(
      MoveEffect.by(
        Vector2(-2 * size.x, 0), // Faqat gorizontal harakat
        EffectController(
          duration: 3,
          alternate: true,
          infinite: true,
        ),
      ),
    );
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is FireWeapon) {
      // Decrease health on collision
      health -= 1;

      // Check if the health has reached 0
      if (health <= 0) {
        // Increase player's stars by 5 when SandEnemy is defeated
        game.starsCollected += 5;

        // Remove the SandEnemy when health is 0
        removeFromParent();
      }

      // Remove the FireWeapon after collision
      other.removeFromParent();
    }

    super.onCollision(intersectionPoints, other);
  }

  @override
  void update(double dt) {
    velocity.x = game.objectSpeed;
    position.x +=
        velocity.x * dt; // Only change the x position for horizontal movement
    if (position.x < -size.x || game.health <= 0) {
      removeFromParent();
    }
    super.update(dt);
  }
}
