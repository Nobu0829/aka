import 'dart:math';
import 'package:flame/components.dart';

import '../baby_dash_game.dart';
import 'cloud_effect.dart';
import 'obstacle.dart';

class OldManBoss extends SpriteComponent with HasGameReference<BabyDashGame> {
  double survivalTime = 30.0; // 30秒逃げ切ればクリア
  double _time = 0.0;
  final Random _random = Random();
  double _attackTimer = 0.0;
  bool isDefeated = false;

  OldManBoss() : super(
    size: Vector2(100, 100), // 小さい！
  );

  @override
  Future<void> onLoad() async {
    sprite = await game.loadSprite('small_old_man.png');
    position = Vector2(game.size.x - 150, game.size.y - 150);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isDefeated) return;

    _time += dt;
    survivalTime -= dt;

    if (survivalTime <= 0) {
      isDefeated = true;
      game.add(CloudEffect(position: position.clone(), sizeMultiplier: 5.0, life: 2.0));
      removeFromParent();
      game.onOldManBossDefeated();
      return;
    }

    // 非常に高速で不規則な動き（画面内を飛び回る）
    position.y = (game.size.y / 2) + sin(_time * 10) * (game.size.y / 2 - 50) - 50;
    position.x = (game.size.x / 2) + cos(_time * 7) * (game.size.x / 2 - 50);

    // 攻撃（超高速で小さい障害物を投げる）
    _attackTimer += dt;
    double interval = 0.3; // めちゃくちゃ速い
    
    if (_attackTimer >= interval) {
      _attackTimer = 0;
      attack();
    }
  }

  void attack() {
    // 高速で障害物を飛ばす
    final attackItem = Obstacle(isThrownByBoss: true, velocity: Vector2(-1000, 0)); 
    // スケールを少し大きくして見やすくする
    attackItem.size = Vector2(60, 60);
    attackItem.position = Vector2(position.x - 20, position.y + size.y / 2);
    game.add(attackItem);
  }

  // ビームやCRYが当たってもダメージを受けない（無敵）
  void takeDamage() {
    // 回避エフェクトを出すなどしても良い
    game.add(CloudEffect(position: position.clone(), sizeMultiplier: 1.0, life: 0.2)); 
    // ダメージは受けない
  }
}
