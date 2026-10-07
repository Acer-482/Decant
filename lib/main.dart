import 'package:flutter/material.dart';
import 'package:media_transcoder/ffmpeg_test_page.dart';

void main() {
  runApp(const MainApp());
}

/// APP 入口
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: Center(child: FFmpegTestPage()));
  }
}
