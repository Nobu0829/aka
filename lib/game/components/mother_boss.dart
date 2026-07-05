import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../baby_dash_game.dart';
import 'cloud_effect.dart';
import 'obstacle.dart';
import 'popup_text.dart';

class MotherBoss extends SpriteComponent with HasGameReference<BabyDashGame> {
  int hp = 20;
  double _time = 0.0;
  final Random _random = Random();
  double _attackTimer = 0.0;
  double _scoldTimer = 0.0;
  double _healTimer = 0.0;
  double _nextScoldTime = 15.0; // 最初は約15秒後にお説教
  bool isDefeated = false;
  late final double _baseY;

  MotherBoss() : super(
    size: Vector2(300, 300),
  );

  @override
  Future<void> onLoad() async {
    sprite = await game.loadSprite('mother_boss.png');
    _baseY = game.size.y - 350;
    position = Vector2(game.size.x - 300, _baseY);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isDefeated) return;

    _time += dt;
    // お母さんは怒って高速で上下する
    position.y = _baseY + sin(_time * 6) * 150;
    position.x = game.size.x - 300 + sin(_time * 4) * 80;

    // 攻撃
    _attackTimer += dt;
    double interval = 0.4; // ティラノサウルスよりさらに速い
    
    if (_attackTimer >= interval) {
      _attackTimer = 0;
      attack();
    }

    // お説教（赤ちゃんのエネルギーをゼロにする）
    _scoldTimer += dt;
    if (_scoldTimer >= _nextScoldTime) {
      _scoldTimer = 0.0;
      _nextScoldTime = 20.0 + _random.nextDouble() * 10.0; // 20〜30秒間隔
      scold();
    }

    // 体力自動回復（1分＝60秒に1回復）
    _healTimer += dt;
    if (_healTimer >= 60.0) {
      _healTimer = 0.0;
      if (hp < 20) { // 最大HPは20
        hp += 1;
        // 回復したことがわかるように緑色の雲エフェクトを出す
        game.add(CloudEffect(position: position.clone(), sizeMultiplier: 2.0, life: 0.5)); 
        // 画面上に大きくメッセージを表示
        game.add(PopupText(
          text: 'HEAL! お母さんの体力が1回復した！',
          color: Colors.greenAccent,
          position: Vector2(game.size.x / 2, 100),
          life: 3.0,
        ));
      }
    }
  }

  void attack() {
    // ランダムな高さから高速で障害物を飛ばす
    double yPos = position.y + _random.nextDouble() * size.y;
    final attackItem = Obstacle(isThrownByBoss: true, velocity: Vector2(-800, 0)); // より速い 
    attackItem.position = Vector2(position.x - 50, yPos);
    game.add(attackItem);
  }

  void scold() {
    // 怒りエフェクト
    game.add(CloudEffect(position: position.clone(), sizeMultiplier: 6.0, life: 1.0));
    
    // 赤ちゃんのビームのエネルギー（パワー）を0にする
    game.player.power = 0.0;
    
    // プレイヤー側にも衝撃を受けたようなエフェクトを出す
    game.add(CloudEffect(position: game.player.position.clone(), sizeMultiplier: 2.0, life: 0.5));

    // 画面上に大きくメッセージを表示
    game.add(PopupText(
      text: 'SCOLD! お母さんに怒られてエネルギーが0になった！',
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
      game.add(CloudEffect(position: position.clone(), sizeMultiplier: 10.0, life: 3.0));
      removeFromParent();
      game.onMotherBossDefeated(); // ステージ5移行処理へ
    }
  }
}
