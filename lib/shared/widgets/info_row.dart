import 'package:flutter/material.dart';

/// 信息行
class InfoRow extends StatelessWidget {
  /// 标题与信息之间的间隔
  final double columnSpacing;

  /// 图标与标题之间的间隔
  final double iconSpacing;

  /// 图标
  final Widget? icon;

  /// 标题
  final String title;

  /// 信息
  final String info;

  const InfoRow({
    super.key,
    this.columnSpacing = 30,
    this.iconSpacing = 8,
    this.icon,
    required this.title,
    required this.info,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: .min,
      spacing: columnSpacing,
      mainAxisAlignment: .spaceEvenly,
      children: [
        Row(spacing: 8, mainAxisSize: .min, children: [?icon, Text(title)]),
        Expanded(child: SelectableText(info, textAlign: .end)),
      ],
    );
  }
}
