import 'package:flutter/material.dart';
import 'package:media_transcoder/features/task_list/pages/task_list_page.dart';

/// 主页面
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: const Center(child: TaskListPage()));
  }
}
