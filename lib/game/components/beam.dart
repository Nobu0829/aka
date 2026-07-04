import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../baby_dash_game.dart';
import 'obstacle.dart';
import 'cloud_effect.dart';

class Beam extends PositionComponent with HasGameReference<BabyDashGame> {
  final double speed = 800.0;
  late final Paint _paint;

  Beam({required Vector2 position}) : super(
    position: position,
    size: Vector2(80, 30),
  ) {
    // 光る黄色いビームの色
    _paint = Paint()..color = const Color(0xFFFFFF00);
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // 右へ高速移動
    position.x += speed * dt;

    // 障害物との当たり判定
    // 当たり判定を緩く（当たりやすく）するため、判定エリアを上下左右に大幅に（150ピクセル）広げます
    final beamRect = toRect().inflate(150.0);
    
    // ボスとの当たり判定（地上から撃っても当たるように、X座標の到達だけで判定します）
    if (game.stage == 1 && game.isBossBattle && game.boss != null && !game.boss!.isDefeated) {
      final bossRect = game.boss!.toRect().deflate(30.0);
      if (beamRect.right >= bossRect.left && beamRect.left <= bossRect.right) {
        game.boss!.takeDamage();
        removeFromParent();
        return;
      }
    } else if (game.stage == 2 && game.isBossBattle && game.bearBoss != null && !game.bearBoss!.isDefeated) {
      final bossRect = game.bearBoss!.toRect().deflate(30.0);
      if (beamRect.right >= bossRect.left && beamRect.left <= bossRect.right) {
        game.bearBoss!.takeDamage();
        removeFromParent();
        return;
      }
    }

    final obstacles = game.children.query<Obstacle>();
    for (var obstacle in obstacles) {
      if (obstacle.toRect().overlaps(beamRect)) {
        // 障害物に当たったら、爆発（雲）エフェクトを出して両方消滅
        game.add(CloudEffect(position: obstacle.position.clone(), sizeMultiplier: 1.5, life: 0.3));
        obstacle.removeFromParent();
        removeFromParent();
        return;
      }
    }

    // 画面右端に出たら消滅
    if (position.x > game.size.x) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // 丸みを帯びたビームを描画
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.x, size.y), const Radius.circular(15)),
      _paint
    );
  }
}
