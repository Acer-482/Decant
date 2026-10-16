import 'package:flutter/material.dart';

/// 选项组
class OptionGroup extends StatelessWidget {
  /// 内边距
  final EdgeInsetsGeometry padding;

  /// 列表间隔
  final double spacing;

  /// 标题
  final String title;

  /// 表单项
  final List<Widget> children;

  const OptionGroup({
    super.key,
    this.padding = const .all(14),
    this.spacing = 10,
    required this.title,
    this.children = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: padding,
        child: Column(
          spacing: spacing,
          children: [
            Text(
              title,
              textAlign: .center,
              style: TextStyle(fontSize: 18, fontWeight: .bold),
            ),
            ...children,
          ],
        ),
      ),
    );
  }
}
