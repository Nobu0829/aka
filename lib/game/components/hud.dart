import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../baby_dash_game.dart';

class Hud extends PositionComponent with HasGameReference<BabyDashGame> {
  // 画面のサイズに依存するためonLoadで設定
  @override
  Future<void> onLoad() async {
    priority = 100; // HUDを最前面に表示する
    
    // パワーゲージ背景
    add(RectangleComponent(
      position: Vector2(20, 20),
      size: Vector2(150, 20),
      paint: Paint()..color = Colors.black26,
    ));
    
    // パワーゲージ本体
    add(PowerBar(position: Vector2(20, 20), size: Vector2(150, 20)));

    // パワーストック数表示を追加
    add(PowerStockText(position: Vector2(180, 18)));

    // プレイヤーHP（ハート）表示を追加
    add(PlayerHpText(position: Vector2(20, 50)));

    // ゲームステータス（ボスHP・クリア表示）を追加
    add(GameStatusText());

    // ジャンプボタン (右下)
    add(VirtualButton(
      text: 'JUMP',
      color: Colors.blueAccent,
      position: Vector2(game.size.x - 100, game.size.y - 100),
      onPressed: () => game.player.jump(),
    ));

    // スーパーギャン泣きボタン (左下)
    add(SuperCryButton(position: Vector2(20, game.size.y - 100)));

    // 必殺技ボタン (中央下)
    add(VirtualButton(
      text: 'SPECIAL',
      color: Colors.pinkAccent,
      position: Vector2(game.size.x / 2 - 40, game.size.y - 100),
      onPressed: () {
        if (game.player.power >= 100) {
          game.player.activateSpecial();
        }
      },
    ));
  }
}

class PowerBar extends RectangleComponent with HasGameReference<BabyDashGame> {
  PowerBar({required Vector2 position, required Vector2 size}) : super(position: position, size: size) {
    paint = Paint()..color = Colors.yellowAccent;
  }

  @override
  void update(double dt) {
    super.update(dt);
    size.x = (game.player.power / 300) * 150;
    
    if (game.player.power >= 300) {
      paint.color = Colors.redAccent;
    } else if (game.player.power >= 100) {
      paint.color = Colors.orangeAccent;
    } else {
      paint.color = Colors.yellowAccent;
    }
  }
}

class PowerStockText extends TextComponent with HasGameReference<BabyDashGame> {
  PowerStockText({required Vector2 position}) : super(
    position: position,
    textRenderer: TextPaint(style: const TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.bold)),
  );

  @override
  void update(double dt) {
    super.update(dt);
    int stocks = game.player.power ~/ 100;
    text = 'STOCK: $stocks/3';
  }
}

class PlayerHpText extends PositionComponent with HasGameReference<BabyDashGame> {
  late final Paint _heartPaint;
  late final Path _heartPath;

  PlayerHpText({required Vector2 position}) : super(position: position) {
    _heartPaint = Paint()..color = Colors.redAccent;
    _heartPath = _createHeartPath(24.0); // サイズ24のハート図形を作成
  }

  Path _createHeartPath(double size) {
    Path path = Path();
    path.moveTo(size / 2, size / 4);
    path.cubicTo(size * 5/8, 0, size, 0, size, size * 3/8);
    path.cubicTo(size, size * 5/8, size / 2, size * 7/8, size / 2, size);
    path.cubicTo(size / 2, size * 7/8, 0, size * 5/8, 0, size * 3/8);
    path.cubicTo(0, 0, size * 3/8, 0, size / 2, size / 4);
    path.close();
    return path;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (game.isGameOver || game.isGameCleared) return;

    // HPの数だけハートを描画
    for (int i = 0; i < game.player.hp; i++) {
      canvas.save();
      canvas.translate(i * 30.0, 0); // 30ピクセル間隔で横に並べる
      canvas.drawPath(_heartPath, _heartPaint);
      canvas.restore();
    }
  }
}

class GameStatusText extends TextComponent with HasGameReference<BabyDashGame> {
  GameStatusText() : super(
    textRenderer: TextPaint(style: const TextStyle(fontSize: 60, color: Colors.redAccent, fontWeight: FontWeight.bold)),
  );

  @override
  void update(double dt) {
    super.update(dt);
    if (game.isGameOver) {
      text = 'GAME OVER';
      textRenderer = TextPaint(style: const TextStyle(fontSize: 80, color: Colors.black, fontWeight: FontWeight.bold));
      position = Vector2(game.size.x / 2 - 250, game.size.y / 2 - 50);
    } else if (game.isGameCleared) {
      text = 'GAME CLEAR!';
      textRenderer = TextPaint(style: const TextStyle(fontSize: 80, color: Colors.amber, fontWeight: FontWeight.bold));
      position = Vector2(game.size.x / 2 - 250, game.size.y / 2 - 50);
    } else if (game.stage == 1 && game.isBossBattle && game.boss != null && !game.boss!.isDefeated) {
      text = 'BROTHER HP: ${game.boss!.hp}/3';
      textRenderer = TextPaint(style: const TextStyle(fontSize: 40, color: Colors.red, fontWeight: FontWeight.bold));
      position = Vector2(game.size.x / 2 - 150, 20);
    } else if (game.stage == 2 && game.isBossBattle && game.bearBoss != null && !game.bearBoss!.isDefeated) {
      text = 'BEAR BOSS HP: ${game.bearBoss!.hp}/10';
      textRenderer = TextPaint(style: const TextStyle(fontSize: 40, color: Colors.purpleAccent, fontWeight: FontWeight.bold));
      position = Vector2(game.size.x / 2 - 200, 20);
    } else if (game.stage == 2 && !game.isBossBattle && game.stage2TransitionTimer < 3.0) {
      text = 'STAGE 2 START!';
      textRenderer = TextPaint(style: const TextStyle(fontSize: 60, color: Colors.orangeAccent, fontWeight: FontWeight.bold));
      position = Vector2(game.size.x / 2 - 250, game.size.y / 2 - 50);
    } else {
      text = '';
    }
  }
}

class VirtualButton extends PositionComponent with TapCallbacks {
  final String text;
  final Color color;
  final VoidCallback onPressed;
  late final Paint _paint;
  late final TextPaint _textPaint;

  VirtualButton({
    required this.text,
    required this.color,
    required Vector2 position,
    required this.onPressed,
  }) : super(position: position, size: Vector2(80, 80)) {
    _paint = Paint()..color = color.withOpacity(0.8);
    _textPaint = TextPaint(style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold));
  }

  @override
  void render(Canvas canvas) {
    canvas.drawCircle(Offset(size.x/2, size.y/2), size.x/2, _paint);
    _textPaint.render(canvas, text, Vector2(size.x/2, size.y/2), anchor: Anchor.center);
  }

  @override
  void onTapDown(TapDownEvent event) {
    _paint.color = color.withOpacity(0.5);
    onPressed();
  }

  @override
  void onTapUp(TapUpEvent event) {
    _paint.color = color.withOpacity(0.8);
  }
  
  @override
  void onTapCancel(TapCancelEvent event) {
    _paint.color = color.withOpacity(0.8);
  }
}

class SuperCryButton extends PositionComponent with TapCallbacks, HasGameReference<BabyDashGame> {
  late final Paint _paint;
  late final TextPaint _textPaint;
  final Color color = Colors.orangeAccent;

  SuperCryButton({required Vector2 position}) : super(position: position, size: Vector2(80, 80)) {
    _paint = Paint()..color = color.withOpacity(0.8);
    _textPaint = TextPaint(style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold));
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (game.player.superCryTimer < game.player.superCryCooldown) {
      _paint.color = Colors.grey.withOpacity(0.8);
    } else {
      _paint.color = color.withOpacity(0.8);
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.drawCircle(Offset(size.x/2, size.y/2), size.x/2, _paint);
    String displayText = 'CRY';
    if (game.player.superCryTimer < game.player.superCryCooldown) {
      int remaining = (game.player.superCryCooldown - game.player.superCryTimer).ceil();
      displayText = '$remaining'; // クールダウン中は残り秒数を表示
    }
    _textPaint.render(canvas, displayText, Vector2(size.x/2, size.y/2), anchor: Anchor.center);
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (game.player.superCryTimer >= game.player.superCryCooldown) {
      _paint.color = color.withOpacity(0.5);
      game.player.activateSuperCry();
    }
  }

  @override
  void onTapUp(TapUpEvent event) {
    if (game.player.superCryTimer >= game.player.superCryCooldown) {
      _paint.color = color.withOpacity(0.8);
    }
  }
  
  @override
  void onTapCancel(TapCancelEvent event) {
    if (game.player.superCryTimer >= game.player.superCryCooldown) {
      _paint.color = color.withOpacity(0.8);
    }
  }
}
