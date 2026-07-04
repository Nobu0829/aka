import 'package:flame_audio/flame_audio.dart';

class AudioManager {
  static Future<void> init() async {
    // 音楽ファイルとSEをキャッシュする
    // await FlameAudio.audioCache.loadAll(['pop_song.mp3', 'jump.wav', 'dash.wav']);
  }

  static void playBgm() {
    // プレースホルダー: 実際には音楽ファイルを再生する
    // FlameAudio.bgm.play('pop_song.mp3');
  }

  static void stopBgm() {
    // FlameAudio.bgm.stop();
  }

  static void playJumpSound() {
    // プレースホルダー: ジャンプ音
    // FlameAudio.play('jump.wav');
  }

  static void playDashSound() {
    // プレースホルダー: ダッシュ音
    // FlameAudio.play('dash.wav');
  }
}
