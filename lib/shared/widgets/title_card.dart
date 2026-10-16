import 'package:flutter/material.dart';

/// 标题卡片
class TitleCard extends StatelessWidget {
  /// 卡片内边距
  final EdgeInsetsGeometry cardPadding;

  /// 内容内边距
  final EdgeInsetsGeometry contentPadding;

  /// 图标
  final Icon icon;

  /// 标题
  final Widget title;

  /// 子组件
  final Widget child;

  const TitleCard({
    super.key,
    required this.icon,
    required this.title,
    this.cardPadding = const .all(14),
    this.contentPadding = const .all(8),
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: cardPadding,
        child: Column(
          mainAxisSize: .min,
          spacing: 6,
          children: [
            Row(spacing: 8, mainAxisAlignment: .start, children: [icon, title]),
            Padding(padding: contentPadding, child: child),
          ],
        ),
      ),
    );
  }
}
