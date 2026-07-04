import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:babydash/screens/main_menu_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // スマホでプレイする際に横画面に固定する
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(const BabyDashApp());
}

class BabyDashApp extends StatelessWidget {
  const BabyDashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BABYRUSH',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pinkAccent),
        useMaterial3: true,
      ),
      home: const MainMenuScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
