import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../baby_dash_game.dart';
import 'cloud_effect.dart';
import 'obstacle.dart';

class BearBoss extends SpriteComponent with HasGameReference<BabyDashGame> {
  int hp = 10;
  double _time = 0.0;
  final Random _random = Random();
  double _throwTimer = 0.0;
  bool isDefeated = false;
  late final double _baseY;

  BearBoss() : super(
    size: Vector2(300, 300), // ボスらしく大きく
  );

  @override
  Future<void> onLoad() async {
    sprite = await game.loadSprite('bear_boss.png');
    _baseY = game.size.y - 350;
    position = Vector2(game.size.x - 300, _baseY);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isDefeated) return;

    _time += dt;
    // 狂気を感じる激しい上下移動
    position.y = _baseY + sin(_time * 5) * 250;

    // おもちゃを激しく投げる
    _throwTimer += dt;
    double interval = 0.7; // 投げる間隔が非常に短い
    
    if (_throwTimer >= interval) {
      _throwTimer = 0;
      throwToy();
    }
  }

  void throwToy() {
    // 40%の確率で2つ同時に投げる（上下）
    if (_random.nextDouble() < 0.4) {
      _createToy(position.y + size.y / 2);
      _createToy(position.y + size.y / 2 - 150);
    } else {
      _createToy(position.y + size.y / 2);
    }
  }

  void _createToy(double yPos) {
    // 熊が投げるアイテムは速い
    final toy = Obstacle(isThrownByBoss: true, velocity: Vector2(-450, 0)); 
    toy.position = Vector2(position.x - 50, yPos);
    game.add(toy);
  }

  void takeDamage() {
    if (isDefeated) return;
    hp -= 1;
    game.add(CloudEffect(position: position.clone(), sizeMultiplier: 3.0, life: 0.5)); 
    
    // 怯みにくい（反動が小さい）
    position.x += 10; 
    
    if (hp <= 0) {
      isDefeated = true;
      game.add(CloudEffect(position: position.clone(), sizeMultiplier: 8.0, life: 1.5));
      removeFromParent();
      game.onBearBossDefeated();
    }
  }
}
