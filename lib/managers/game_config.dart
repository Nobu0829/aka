class GameConfig {
  static final GameConfig _instance = GameConfig._internal();
  factory GameConfig() => _instance;
  GameConfig._internal();

  bool enableBrotherBoss = true;
  bool enableBearBoss = true;
  bool enableTRexBoss = true;
  bool enableMotherBoss = true;
  bool enableOldManBoss = true;
}
