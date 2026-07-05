import 'package:flutter/material.dart';
import '../managers/game_config.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  final config = GameConfig();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      appBar: AppBar(
        title: const Text('Boss Configuration'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select which bosses will appear in the game.',
                style: TextStyle(fontSize: 18, color: Colors.black87),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: [
                    _buildSwitchTile('Stage 1: Brother', config.enableBrotherBoss, (val) {
                      setState(() => config.enableBrotherBoss = val);
                    }),
                    _buildSwitchTile('Stage 2: Bear Boss', config.enableBearBoss, (val) {
                      setState(() => config.enableBearBoss = val);
                    }),
                    _buildSwitchTile('Stage 3: T-Rex Boss', config.enableTRexBoss, (val) {
                      setState(() => config.enableTRexBoss = val);
                    }),
                    _buildSwitchTile('Stage 4: Mother Boss', config.enableMotherBoss, (val) {
                      setState(() => config.enableMotherBoss = val);
                    }),
                    _buildSwitchTile('Stage 5: Small Old Man', config.enableOldManBoss, (val) {
                      setState(() => config.enableOldManBoss = val);
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String title, bool value, ValueChanged<bool> onChanged) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SwitchListTile(
        title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        value: value,
        onChanged: onChanged,
        activeThumbColor: Colors.pinkAccent,
      ),
    );
  }
}
