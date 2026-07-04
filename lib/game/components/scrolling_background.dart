import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/material.dart';
import '../baby_dash_game.dart';

class ScrollingBackground extends ParallaxComponent<BabyDashGame> {
  @override
  Future<void> onLoad() async {
    // 透過処理済みの背景画像(bg.png)を読み込み、横方向にループスクロールさせます
    parallax = await game.loadParallax(
      [ParallaxImageData('bg.png')],
      baseVelocity: Vector2(100, 0), // スクロール速度
      repeat: ImageRepeat.repeat,
    );
  }
}
