import 'package:flutter/material.dart';

/// 路径文本
class PathText extends StatelessWidget {
  /// 路径
  final String path;

  /// 文本样式
  final TextStyle? style;

  const PathText(this.path, {super.key, this.style});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final textStyle = DefaultTextStyle.of(context).style.merge(style);

        return Tooltip(
          message: path,
          waitDuration: const Duration(milliseconds: 400),
          child: Text(
            _fit(path, textStyle, constraints.maxWidth),
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.clip,
            style: style,
          ),
        );
      },
    );
  }

  /// 取能放下的最长后缀，前面加省略号
  String _fit(String text, TextStyle style, double maxWidth) {
    if (!maxWidth.isFinite || maxWidth <= 0) return text;

    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();

    if (painter.width <= maxWidth) {
      painter.dispose();
      return text;
    }

    // 二分查找最长的可放下后缀
    var low = 0;
    var high = text.length;
    while (low < high) {
      final mid = (low + high + 1) ~/ 2;
      painter.text = TextSpan(
        text: '…${text.substring(text.length - mid)}',
        style: style,
      );
      painter.layout();
      if (painter.width <= maxWidth) {
        low = mid;
      } else {
        high = mid - 1;
      }
    }
    painter.dispose();

    return low == 0 ? '…' : '…${text.substring(text.length - low)}';
  }
}
