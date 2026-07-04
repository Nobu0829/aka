import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import '../game/baby_dash_game.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GameWidget(
          game: BabyDashGame(),
          // ロード中の画面やエラー画面を定義することも可能
        ),
      ),
    );
  }
}
