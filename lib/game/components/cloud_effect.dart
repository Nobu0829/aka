import 'dart:ui';
import 'package:flame/components.dart';

class CloudEffect extends PositionComponent {
  double _lifeTime;
  final double _maxLife;
  late final Paint _paint;

  CloudEffect({required Vector2 position, double sizeMultiplier = 1.0, double life = 0.5}) 
      : _lifeTime = life,
        _maxLife = life,
        super(position: position, size: Vector2(30 * sizeMultiplier, 30 * sizeMultiplier)) {
    _paint = Paint()..color = const Color(0xFFFFFFFF);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _lifeTime -= dt;
    if (_lifeTime <= 0) {
      removeFromParent();
    } else {
      _paint.color = const Color(0xFFFFFFFF).withOpacity((_lifeTime / _maxLife).clamp(0.0, 1.0));
      position.y -= 20 * dt; // 少し上に上がる
      position.x -= 200 * dt; // スクロールに合わせて左に流れる
      size.x += 20 * dt;
      size.y += 20 * dt;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawCircle(Offset(size.x/2, size.y/2), size.x/2, _paint);
  }
}
