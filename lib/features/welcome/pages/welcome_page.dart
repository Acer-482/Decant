import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// 欢迎页面
class WelcomePage extends StatelessWidget {
  /// 开始转码
  final VoidCallback onStart;

  const WelcomePage({super.key, required this.onStart});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return InkWell(
      onTap: onStart,
      splashColor: primary.withValues(alpha: 0.06), // 点击水波
      hoverColor: primary.withValues(alpha: 0.04), // 悬停底色
      child: Center(
        child: Column(
          spacing: 6,
          mainAxisSize: .min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: .circular(16),
                color: primary.withValues(alpha: 0.12),
                border: Border.all(color: primary.withValues(alpha: 0.28)),
              ),
              child: Icon(Icons.wine_bar_rounded, size: 26, color: primary),
            ),
            const SizedBox(height: 14),
            Text(
              'Decant',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: .w600,
                letterSpacing: 0.8,
              ),
            ),
            Text(
              '把你的媒体，倒进任意容器',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '单击任意位置开始',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}
