import 'dart:math';
import 'package:flame/components.dart';

import '../baby_dash_game.dart';
import 'cloud_effect.dart';
import 'obstacle.dart';
import 'popup_text.dart';
import 'package:flutter/material.dart';

class TRexBoss extends SpriteComponent with HasGameReference<BabyDashGame> {
  int hp = 15;
  double _time = 0.0;
  final Random _random = Random();
  double _attackTimer = 0.0;
  double _healTimer = 0.0;
  double _roarTimer = 0.0;
  double _nextRoarTime = 30.0; // 最初は約30秒後に咆哮
  bool isDefeated = false;
  late final double _baseY;

  TRexBoss() : super(
    size: Vector2(350, 350), // Tレックスらしくさらに大きく
  );

  @override
  Future<void> onLoad() async {
    sprite = await game.loadSprite('trex_boss.png');
    _baseY = game.size.y - 400;
    position = Vector2(game.size.x - 350, _baseY);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isDefeated) return;

    _time += dt;
    // 恐竜は前後に揺れながら少し上下する
    position.y = _baseY + sin(_time * 3) * 100;
    position.x = game.size.x - 350 + sin(_time * 2) * 50;

    // 攻撃
    _attackTimer += dt;
    double interval = 0.6; // かなり速い
    
    if (_attackTimer >= interval) {
      _attackTimer = 0;
      attack();
    }

    // 体力自動回復（1分＝60秒に1回復）
    _healTimer += dt;
    if (_healTimer >= 60.0) {
      _healTimer = 0.0;
      if (hp < 15) { // 最大HPは15
        hp += 1;
        // 回復したことがわかるように緑色の雲エフェクトを出す
        game.add(CloudEffect(position: position.clone(), sizeMultiplier: 2.0, life: 0.5)); 
        // 画面上に大きくメッセージを表示
        game.add(PopupText(
          text: 'HEAL! 恐竜の体力が1回復した！',
          color: Colors.greenAccent,
          position: Vector2(game.size.x / 2, 100),
          life: 3.0,
        ));
      }
    }

    // 咆哮（ランダムに赤ちゃんのエネルギーをゼロにする）
    _roarTimer += dt;
    if (_roarTimer >= _nextRoarTime) {
      _roarTimer = 0.0;
      _nextRoarTime = 25.0 + _random.nextDouble() * 10.0; // 25〜35秒後（約30秒に1回）
      roar();
    }
  }

  void attack() {
    // ランダムな高さから高速で障害物を飛ばす
    double yPos = position.y + _random.nextDouble() * size.y;
    final attackItem = Obstacle(isThrownByBoss: true, velocity: Vector2(-600, 0)); 
    attackItem.position = Vector2(position.x - 50, yPos);
    game.add(attackItem);
  }

  void roar() {
    // 咆哮エフェクト
    game.add(CloudEffect(position: position.clone(), sizeMultiplier: 6.0, life: 1.0));
    
    // 赤ちゃんのビームのエネルギー（パワー）を0にする
    game.player.power = 0.0;
    
    // プレイヤー側にも衝撃を受けたようなエフェクトを出す
    game.add(CloudEffect(position: game.player.position.clone(), sizeMultiplier: 2.0, life: 0.5));

    // 画面上に大きくメッセージを表示
    game.add(PopupText(
      text: 'ROAR! 赤ちゃんのエネルギーが0になった！',
      color: Colors.redAccent,
      position: Vector2(game.size.x / 2, 100),
      life: 3.0,
    ));
  }

  void takeDamage() {
    if (isDefeated) return;
    hp -= 1;
    game.add(CloudEffect(position: position.clone(), sizeMultiplier: 3.0, life: 0.5)); 
    
    position.x += 10; 
    
    if (hp <= 0) {
      isDefeated = true;
      game.add(CloudEffect(position: position.clone(), sizeMultiplier: 10.0, life: 2.0));
      removeFromParent();
      game.onTRexBossDefeated();
    }
  }
}
