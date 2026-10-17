import 'package:flutter/material.dart';
import 'package:media_transcoder/features/fast_transcode/pages/select_file_page.dart';
import 'package:media_transcoder/features/task_list/pages/task_list_page.dart';

/// 导航项
class _NavigationItem {
  final Icon icon; // 图标
  final String name; // 名称
  final String description; // 描述
  final Widget Function(BuildContext context) builder; // 页面构建器

  static Widget _defaultBuilder(BuildContext context) =>
      const SizedBox.shrink();

  const _NavigationItem({
    required this.icon,
    required this.name,
    this.description = '',
    this.builder = _defaultBuilder,
  });
}

/// 主页面
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<_NavigationItem> _navigationItems = [
    _NavigationItem(
      icon: const Icon(Icons.home),
      name: '主页',
      builder: (context) => const SelectFilePage(),
    ),
    _NavigationItem(
      icon: const Icon(Icons.list_alt),
      name: '任务',
      description: '查看正在进行的任务',
      builder: (context) => const TaskListPage(),
    ),
    _NavigationItem(icon: const Icon(Icons.settings), name: '设置'),
  ]; // 导航项

  final PageController _pageController = PageController(); // 页面控制器

  /// 当前页面索引
  int _pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _pageIndex,
        onTap: _animatedToPage,
        items: _navigationItems
            .map(
              (e) => BottomNavigationBarItem(
                icon: e.icon,
                label: e.name,
                tooltip: e.description,
              ),
            )
            .toList(),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: _navigationItems
            .map((item) => item.builder(context))
            .toList(), // 构建页面内容
      ), // 页面浏览器
    ); // 页面骨架
  }

  /// 切换页面
  ///
  /// 用于在点击导航栏时切换页面
  ///
  /// 页面切换时会调用[_onPageChanged]
  void _animatedToPage(int newIndex) {
    _pageController.animateToPage(
      newIndex,
      duration: Duration(milliseconds: 300),
      curve: Curves.fastEaseInToSlowEaseOut,
    );
  }

  /// 页面更改
  ///
  /// 用于在[PageView]滑动更新页面时更新索引和UI
  void _onPageChanged(int newIndex) {
    _pageIndex = newIndex;
    setState(() {});
  }
}
