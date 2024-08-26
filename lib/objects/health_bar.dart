import 'dart:ui';
import 'package:flame/components.dart';
import '../actors/actors.dart';

class HealthBar extends PositionComponent {
  final PositionComponent enemy;
  final double maxWidth;
  late RectangleComponent _bar;

  HealthBar({required this.enemy, required this.maxWidth})
      : super(size: Vector2(64, 8));

  @override
  Future<void> onLoad() async {
    super.onLoad();

    _bar = RectangleComponent(
      size: Vector2(maxWidth, size.y),
      paint: Paint()..color = const Color(0xFFFF0000),
      anchor: Anchor.topLeft,
    );
    add(_bar);

    // Set initial position above the enemy
    position = enemy.position - Vector2(0, enemy.size.y + 10);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Assuming enemy has a health property
    double currentHealth = (enemy as dynamic).health.toDouble();

    if (currentHealth <= 0) {
      // If enemy is dead, remove the health bar
      removeFromParent();  // HealthBarni olib tashlash
    } else {
      // Update health bar size and position
      _bar.size.x = (currentHealth / 5) * maxWidth; // 5 -> dushman uchun maksimal jon
      position = enemy.position - Vector2(0, enemy.size.y + 10);
    }
  }
}
