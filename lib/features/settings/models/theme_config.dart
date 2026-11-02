import 'package:flutter/material.dart';
import 'package:decant/features/settings/enums/theme_mode_option.dart';

/// 主题配置
class ThemeConfig {
  /// 种子色
  final Color seedColor;

  /// 亮暗模式
  final ThemeModeOption mode;

  const ThemeConfig({required this.seedColor, required this.mode});

  /// 默认值
  static const ThemeConfig defaults = ThemeConfig(
    seedColor: Colors.cyan,
    mode: ThemeModeOption.dark,
  );

  /// 可选的主题色
  static const List<Color> seedColors = [
    Colors.cyan,
    Colors.blue,
    Colors.teal,
    Colors.green,
    Colors.amber,
    Colors.orange,
    Colors.pink,
    Colors.purple,
  ];

  /// 复制
  ThemeConfig copyWith({Color? seedColor, ThemeModeOption? mode}) {
    return ThemeConfig(
      seedColor: seedColor ?? this.seedColor,
      mode: mode ?? this.mode,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ThemeConfig &&
      other.seedColor.toARGB32() == seedColor.toARGB32() &&
      other.mode == mode;

  @override
  int get hashCode => Object.hash(seedColor, mode);
}
