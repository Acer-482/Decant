import 'package:flutter/material.dart';

/// 表单组
class FormGroup extends StatelessWidget {
  /// 内边距
  final EdgeInsetsGeometry padding;

  /// 列表间隔
  final double spacing;

  /// 标题
  final String title;

  /// 表单项
  final List<Widget> formItems;

  const FormGroup({
    super.key,
    this.padding = const .all(8),
    this.spacing = 4,
    required this.title,
    this.formItems = const [],
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
              style: TextStyle(fontSize: 30, fontWeight: .bold),
            ),
            ...formItems,
          ],
        ),
      ),
    );
  }
}
