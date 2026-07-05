import 'dart:ui';
import 'dart:math';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'components/baby_player.dart';
import 'components/obstacle.dart';
import 'components/scrolling_background.dart';
import 'components/hud.dart';
import 'components/boss.dart';
import 'components/bear_boss.dart';
import 'components/trex_boss.dart';
import 'components/mother_boss.dart';
import 'components/old_man_boss.dart';
import 'components/cloud_effect.dart';
import '../managers/game_config.dart';

class BabyDashGame extends FlameGame with TapCallbacks {
  late BabyPlayer player;
  double obstacleTimer = 0.0;
  double currentSpawnInterval = 2.0;
  final Random _random = Random();

  double playTime = 0.0;
  
  // ステージ管理
  int stage = 1;
  double stage2TransitionTimer = 0.0;
  double stage3TransitionTimer = 0.0;
  double stage4TransitionTimer = 0.0;
  double stage5TransitionTimer = 0.0;
  bool isBossBattle = false;
  bool isGameCleared = false;
  bool isGameOver = false;
  
  Boss? boss;
  BearBoss? bearBoss;
  TRexBoss? tRexBoss;
  MotherBoss? motherBoss;
  OldManBoss? oldManBoss;

  @override
  Color backgroundColor() => const Color(0xFFE1F5FE);

  @override
  Future<void> onLoad() async {
    add(ScrollingBackground());
    player = BabyPlayer();
    add(player);
    add(Hud());
    FlameAudio.bgm.initialize();
    FlameAudio.bgm.play('bgm.mp3');
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isGameCleared || isGameOver) return;

    if (stage == 1) {
      if (!isBossBattle) {
        playTime += dt;
        if (playTime >= 30.0) {
          if (GameConfig().enableBrotherBoss) {
            startBossBattle();
          } else {
            onBossDefeated(); // すぐに次のステージへ
          }
        }
        _spawnObstacles(dt);
      }
    } else if (stage == 2) {
      if (!isBossBattle) {
        stage2TransitionTimer += dt;
        if (stage2TransitionTimer >= 10.0) {
          if (GameConfig().enableBearBoss) {
            startBearBossBattle();
          } else {
            onBearBossDefeated(); // すぐに次のステージへ
          }
        }
        _spawnObstacles(dt, speedMultiplier: 1.2);
      }
    } else if (stage == 3) {
      if (!isBossBattle) {
        stage3TransitionTimer += dt;
        if (stage3TransitionTimer >= 10.0) {
          if (GameConfig().enableTRexBoss) {
            startTRexBossBattle();
          } else {
            onTRexBossDefeated(); // すぐに次のステージへ
          }
        }
        _spawnObstacles(dt, speedMultiplier: 1.5);
      }
    } else if (stage == 4) {
      if (!isBossBattle) {
        stage4TransitionTimer += dt;
        if (stage4TransitionTimer >= 10.0) {
          if (GameConfig().enableMotherBoss) {
            startMotherBossBattle();
          } else {
            onMotherBossDefeated(); // すぐに次のステージへ
          }
        }
        _spawnObstacles(dt, speedMultiplier: 1.8);
      }
    } else if (stage == 5) {
      if (!isBossBattle) {
        stage5TransitionTimer += dt;
        if (stage5TransitionTimer >= 5.0) { // すぐ登場する
          if (GameConfig().enableOldManBoss) {
            startOldManBossBattle();
          } else {
            onOldManBossDefeated(); // すぐにクリア処理へ
          }
        }
        _spawnObstacles(dt, speedMultiplier: 2.0); // さらに速い
      }
    }
  }

  void _spawnObstacles(double dt, {double speedMultiplier = 1.0}) {
    obstacleTimer += dt;
    final double currentInterval = player.isInvincible 
        ? currentSpawnInterval / (2 * speedMultiplier) 
        : currentSpawnInterval / speedMultiplier;
    
    if (obstacleTimer >= currentInterval) {
      obstacleTimer = 0;
      currentSpawnInterval = 1.0 + _random.nextDouble() * 2.0;
      add(Obstacle());
    }
  }

  void startBossBattle() {
    isBossBattle = true;
    boss = Boss();
    add(boss!);
  }

  void onBossDefeated() {
    isBossBattle = false;
    stage = 2;
    boss = null;
  }
  
  void startBearBossBattle() {
    isBossBattle = true;
    bearBoss = BearBoss();
    add(bearBoss!);
    
    // BGMをボス戦用（燃え上がるコア）に切り替える
    FlameAudio.bgm.stop();
    FlameAudio.bgm.play('boss_bgm.mp3');
  }

  void onBearBossDefeated() {
    isBossBattle = false;
    stage = 3;
    bearBoss = null;
  }

  void startTRexBossBattle() {
    isBossBattle = true;
    tRexBoss = TRexBoss();
    add(tRexBoss!);
    
    FlameAudio.bgm.stop();
    FlameAudio.bgm.play('trex_boss_bgm.mp3');
  }

  void onTRexBossDefeated() {
    isBossBattle = false;
    stage = 4;
    tRexBoss = null;
  }

  void startMotherBossBattle() {
    isBossBattle = true;
    motherBoss = MotherBoss();
    add(motherBoss!);
    
    FlameAudio.bgm.stop();
    FlameAudio.bgm.play('mother_boss_bgm.mp3');
  }

  void onMotherBossDefeated() {
    isBossBattle = false;
    stage = 5;
    motherBoss = null;
  }

  void startOldManBossBattle() {
    isBossBattle = true;
    oldManBoss = OldManBoss();
    add(oldManBoss!);
    
    FlameAudio.bgm.stop();
    FlameAudio.bgm.play('old_man_boss_bgm.mp3');
  }

  void onOldManBossDefeated() {
    isGameCleared = true;
    FlameAudio.bgm.stop();
  }

  void gameOver() {
    isGameOver = true;
    FlameAudio.bgm.stop();
    player.removeFromParent(); // プレイヤーを画面から消す
    add(CloudEffect(position: player.position.clone(), sizeMultiplier: 5.0, life: 2.0));
  }

  @override
  void onTapDown(TapDownEvent event) {
  }
}
