import 'package:flutter/material.dart';
import 'package:babydash/screens/game_screen.dart';

class InstructionScreen extends StatelessWidget {
  const InstructionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                '遊び方',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blueAccent),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text('★ アイテムと障害物', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                                SizedBox(height: 12),
                                Text('🍬 飴・キャンディ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                Text('取るとパワーゲージが全回復します！無敵時間中でも拾えます。', style: TextStyle(fontSize: 14)),
                                SizedBox(height: 12),
                                Text('🧸 障害物（おもちゃ・風船など）', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                Text('ぶつかるとダメージを受けます。避けるかスキルで壊しましょう。', style: TextStyle(fontSize: 14)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text('★ 操作・スキル', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue)),
                                SizedBox(height: 12),
                                Text('🔵 JUMP（右下）', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                Text('ジャンプして障害物を飛び越えます。', style: TextStyle(fontSize: 14)),
                                SizedBox(height: 8),
                                Text('🔴 SPECIAL（中央下）', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                Text('パワーを1消費してビーム発射！ボスにダメージを与えます。', style: TextStyle(fontSize: 14)),
                                SizedBox(height: 8),
                                Text('🟠 CRY（左下）', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                Text('15秒に1回使える必殺技。画面内の敵・障害物を一掃します！', style: TextStyle(fontSize: 14)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 5,
                ),
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const GameScreen()),
                  );
                },
                child: const Text('ゲームスタート！', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
