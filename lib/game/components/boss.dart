import 'dart:ui';
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../baby_dash_game.dart';
import 'cloud_effect.dart';
import 'obstacle.dart';

class Boss extends SpriteComponent with HasGameReference<BabyDashGame> {
  int hp = 3;
  double _time = 0.0;
  final Random _random = Random();
  double _throwTimer = 0.0;
  bool isDefeated = false;
  late final double _baseY;

  Boss() : super(
    size: Vector2(200, 200),
  );

  @override
  Future<void> onLoad() async {
    sprite = await game.loadSprite('boss.png');
    // 画面右端の少し低め（プレイヤーに近い高さ）に配置
    _baseY = game.size.y - 280;
    position = Vector2(game.size.x - 250, _baseY);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isDefeated) return;

    _time += dt;
    // 上下にフワフワ移動（サイン波）
    position.y = _baseY + sin(_time * 2) * 120;

    // おもちゃを投げる
    _throwTimer += dt;
    // おもちゃを投げる間隔（ダッシュ機能を廃止したため固定化）
    double interval = 2.0;
    
    if (_throwTimer >= interval) {
      _throwTimer = 0;
      throwToy();
    }
  }

  void throwToy() {
    // bossが投げる障害物にも少し速度をつけます
    final toy = Obstacle(isThrownByBoss: true, velocity: Vector2(-350, 0));
    // ボスの手のあたりから発射
    toy.position = Vector2(position.x - 50, position.y + size.y / 2);
    game.add(toy);
  }

  void takeDamage() {
    if (isDefeated) return;
    hp -= 1;
    // ダメージエフェクト
    game.add(CloudEffect(position: position.clone(), sizeMultiplier: 3.0, life: 0.5)); 
    
    // 攻撃を受けた反動で少し後ろに下がる
    position.x += 30; 
    
    if (hp <= 0) {
      isDefeated = true;
      // 巨大な撃破エフェクト
      game.add(CloudEffect(position: position.clone(), sizeMultiplier: 5.0, life: 1.0));
      removeFromParent();
      game.onBossDefeated();
    }
  }
}
