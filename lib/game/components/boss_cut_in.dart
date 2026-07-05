import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

class BossCutIn extends PositionComponent {
  final String imagePath;
  final String title;
  final VoidCallback onComplete;

  late SpriteComponent bossSprite;
  late TextComponent titleText;

  BossCutIn({
    required this.imagePath,
    required this.title,
    required this.onComplete,
  });

  @override
  Future<void> onLoad() async {
    size = Vector2(800, 600); // 画面全体より大きめにして中央に配置
    position = Vector2.zero();
    
    // 背景の半透明の黒帯（オプション）
    final bg = RectangleComponent(
      size: Vector2(10000, 200),
      paint: Paint()..color = Colors.black.withValues(alpha: 0.5),
      position: Vector2(-1000, 200),
    );
    add(bg);

    // ボスの画像
    final sprite = await Sprite.load(imagePath);
    bossSprite = SpriteComponent(
      sprite: sprite,
      size: Vector2(300, 300), // 大きく
      anchor: Anchor.center,
    );
    
    // 親コンポーネント（game）のサイズから中央を計算したいが、とりあえず仮で
    // BabyDashGameにaddされるので、画面の中央付近に置く
    bossSprite.position = Vector2(400, 300);
    
    // 登場アニメーション（スケールアップ＆移動）
    bossSprite.scale = Vector2.all(0.1);
    bossSprite.add(
      ScaleEffect.to(
        Vector2.all(1.0),
        EffectController(duration: 0.5, curve: Curves.easeOutBack),
      )
    );

    add(bossSprite);

    // ボス名のテキスト
    titleText = TextComponent(
      text: title,
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 60,
          color: Colors.red,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(color: Colors.white, blurRadius: 10, offset: Offset(2, 2)),
          ]
        )
      ),
      anchor: Anchor.center,
      position: Vector2(400, 500),
    );
    
    titleText.scale = Vector2.all(0.1);
    titleText.add(
      ScaleEffect.to(
        Vector2.all(1.0),
        EffectController(duration: 0.5, curve: Curves.easeOutBack),
      )
    );
    add(titleText);

    // 2.5秒後に消えてコールバック実行
    add(
      TimerComponent(
        period: 2.5,
        onTick: () {
          // フェードアウト
          bossSprite.add(ScaleEffect.to(Vector2.zero(), EffectController(duration: 0.3)));
          titleText.add(ScaleEffect.to(Vector2.zero(), EffectController(duration: 0.3)));
          
          add(TimerComponent(
            period: 0.3, 
            onTick: () {
              removeFromParent();
              onComplete();
            },
            removeOnFinish: true,
          ));
        },
        removeOnFinish: true,
      )
    );
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    // 画面中央になるように調整
    bossSprite.position = Vector2(size.x / 2, size.y / 2 - 50);
    titleText.position = Vector2(size.x / 2, size.y / 2 + 150);
  }
}
