import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_transcoder/features/home/pages/home_pages.dart';

void main() {
  runApp(const ProviderScope(child: MainApp()));
}

/// APP 入口
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.cyan, // 主题色
          brightness: Brightness.dark, // 深色模式
        ),
      ),
      home: const HomePage(),
    );
  }
}
