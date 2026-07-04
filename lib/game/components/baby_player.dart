import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../baby_dash_game.dart';
import 'cloud_effect.dart';
import 'beam.dart';
import 'obstacle.dart';

class BabyPlayer extends SpriteComponent with HasGameReference<BabyDashGame> {
  static const double gravity = 1500.0;
  static const double jumpSpeed = -600.0;
  static const double dashSpeedMultiplier = 2.0;

  double verticalVelocity = 0;
  bool isJumping = false;
  double superCryTimer = 15.0; // スーパーギャン泣き砲のタイマー（初期状態で使用可能にするため15.0）
  final double superCryCooldown = 15.0;

  // 必殺技・パワー・ライフ関連
  double power = 0.0;
  int hp = 3;
  static const int maxHp = 3;
  bool isInvincible = false;
  double invincibleTimer = 0.0;
  final double invincibleDuration = 3.0; // 無敵時間3秒

  double _effectTimer = 0.0;

  BabyPlayer() : super(
    size: Vector2(150, 150),
  );

  @override
  Future<void> onLoad() async {
    sprite = await game.loadSprite('player.png');
    position = Vector2(100, game.size.y - size.y - 50);
    flipHorizontally(); // 画像が左向きだったため、進行方向(右)に反転
  }

  @override
  void update(double dt) {
    super.update(dt);

    // パワーの自動回復（1秒に35回復、約8.5秒で最大300(3ストック)になります）
    if (!isInvincible && power < 300) {
      power += 35 * dt;
      if (power > 300) power = 300;
    }

    // 無敵状態（スーパー突進）の処理
    if (isInvincible) {
      invincibleTimer -= dt;
      if (invincibleTimer <= 0) {
        isInvincible = false;
      }
    }

    // スーパーギャン泣き砲のクールダウン処理
    if (superCryTimer < superCryCooldown) {
      superCryTimer += dt;
    }

    // 重力の処理
    verticalVelocity += gravity * dt;
    position.y += verticalVelocity * dt;

    // 地面の判定
    final groundY = game.size.y - 50 - size.y;
    if (position.y >= groundY) {
      position.y = groundY;
      verticalVelocity = 0;
      if (isJumping) {
        isJumping = false;
        // 着地時に小さな雲エフェクト
        game.add(CloudEffect(position: Vector2(position.x + size.x/4, position.y + size.y - 20), sizeMultiplier: 0.5));
      }
    }
  }

  void jump() {
    if (!isJumping) {
      verticalVelocity = jumpSpeed;
      isJumping = true;
      // ジャンプ時に雲エフェクト
      game.add(CloudEffect(position: Vector2(position.x + size.x/4, position.y + size.y - 20)));
    }
  }

  void activateSuperCry() {
    if (superCryTimer >= superCryCooldown) {
      superCryTimer = 0.0;
      
      // 巨大なエフェクトを画面中央に表示
      game.add(CloudEffect(
        position: Vector2(game.size.x / 2 - 150, game.size.y / 2 - 150),
        sizeMultiplier: 10.0,
        life: 1.0,
      ));

      // 画面内のすべての障害物（敵）にダメージ（消去）
      final obstacles = game.children.query<Obstacle>();
      for (var obstacle in obstacles) {
        if (obstacle.itemType == 'damage') {
          // ダメージアイテム（敵・障害物）のみ消去
          game.add(CloudEffect(position: obstacle.position.clone(), sizeMultiplier: 2.0));
          obstacle.removeFromParent();
        }
      }

      // ボスがいればダメージを与える
      if (game.boss != null && !game.boss!.isDefeated) {
        game.boss!.takeDamage();
      }
      if (game.bearBoss != null && !game.bearBoss!.isDefeated) {
        game.bearBoss!.takeDamage();
      }
    }
  }

  void activateSpecial() {
    if (power >= 100) {
      power -= 100; // パワーを1ストック(100)消費する
      // スーパーおしゃぶりビーム（キラキラ）を発射！
      game.add(Beam(position: Vector2(position.x + size.x - 20, position.y + size.y / 2 - 30)));
    }
  }

  void fillPower() {
    power = 300.0;
    if (hp < maxHp) {
      hp += 1;
    }
  }

  void takeDamage() {
    if (isInvincible) return;
    // power = 0.0; // ペナルティとしてパワーがリセットされる仕様を無効化
    hp -= 1;
    isInvincible = true;
    invincibleTimer = invincibleDuration; // 被弾後の無敵時間
    // ダメージエフェクト
    game.add(CloudEffect(position: position.clone(), sizeMultiplier: 1.5, life: 0.5));

    if (hp <= 0) {
      game.gameOver();
    }
  }
}
