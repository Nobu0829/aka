import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../baby_dash_game.dart';

class Obstacle extends SpriteComponent with HasGameReference<BabyDashGame> {
  final double speed = 300.0;
  
  // 障害物の画像と、それが回復アイテム(キャンディ類)かどうかの情報を持ちます
  static const List<Map<String, String>> _obstacleTypes = [
    {'image': 'candy.png', 'type': 'heal'},
    {'image': 'lolly.png', 'type': 'heal'},
    {'image': 'bear.png', 'type': 'damage'},
    {'image': 'block.png', 'type': 'damage'},
    {'image': 'balloon.png', 'type': 'damage'},
  ];
  
  late String itemType;
  late String imageName;
  final bool isThrownByBoss;
  final Vector2? velocity;

  Obstacle({this.isThrownByBoss = false, this.velocity}) : super(
    size: Vector2(80, 80), // 絵文字より少し大きめに表示
  );

  @override
  Future<void> onLoad() async {
    // ランダムに画像とタイプを選択
    final randomData = _obstacleTypes[Random().nextInt(_obstacleTypes.length)];
    itemType = randomData['type']!;
    imageName = randomData['image']!;
    sprite = await game.loadSprite(imageName);

    // ボスから投げられたものでない場合は、画面右端の地面の上に配置
    if (!isThrownByBoss) {
      position = Vector2(game.size.x, game.size.y - 130);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // 移動処理
    if (isThrownByBoss && velocity != null) {
      position += velocity! * dt;
    } else {
      position.x -= speed * dt;
    }

    // 画面外に出たら消去
    if (position.x < -100 || position.y > game.size.y + 100) {
      removeFromParent();
    }

    // プレイヤーとの当たり判定
    final playerRect = game.player.toRect().deflate(15); // プレイヤーの判定
    
    // アイテム・障害物ごとの判定サイズ調整
    Rect obstacleRect = toRect();
    if (itemType == 'heal') {
      // 飴（回復アイテム）は取りやすくするため、当たり判定を大きくする
      obstacleRect = obstacleRect.inflate(15.0); 
    } else {
      // 障害物（ダメージアイテム）は避けやすくするため、当たり判定を小さくする
      obstacleRect = obstacleRect.deflate(25.0); 
    }

    if (playerRect.overlaps(obstacleRect)) {
      if (itemType == 'heal') {
        // キャンディ（回復アイテム）は無敵時間中でも取れるようにする
        game.player.fillPower();
        removeFromParent();
      } else {
        // おもちゃ（ダメージアイテム）は無敵時間中でない場合のみ判定
        if (!game.player.isInvincible) {
          game.player.takeDamage();
          removeFromParent();
        }
      }
    }
  }
}
