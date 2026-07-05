import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class PopupText extends PositionComponent {
  final String text;
  final Color color;
  double life;
  late final TextComponent _textComponent;

  PopupText({
    required this.text,
    required this.color,
    required Vector2 position,
    this.life = 3.0,
  }) : super(position: position);

  @override
  Future<void> onLoad() async {
    priority = 200; // HUDよりも前面に出るように
    _textComponent = TextComponent(
      text: text,
      textRenderer: TextPaint(
        style: TextStyle(
          fontSize: 40,
          color: color,
          fontWeight: FontWeight.bold,
          shadows: const [Shadow(color: Colors.black, blurRadius: 4, offset: Offset(2, 2))]
        ),
      ),
    );
    _textComponent.anchor = Anchor.center;
    add(_textComponent);
  }

  @override
  void update(double dt) {
    super.update(dt);
    life -= dt;
    position.y -= 50 * dt; // 少しずつ上にフワッと上がる
    if (life <= 0) {
      removeFromParent();
    }
  }
}
