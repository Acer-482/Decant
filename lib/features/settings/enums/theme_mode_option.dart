import 'package:flutter/material.dart';

/// 主题模式
enum ThemeModeOption { system, light, dark }

/// 主题模式拓展
extension ThemeModeOptionX on ThemeModeOption {
  /// 显示名
  String get displayName => switch (this) {
    .system => '跟随系统',
    .light => '亮色',
    .dark => '暗色',
  };

  /// 转成 [ThemeMode]
  ThemeMode get themeMode => switch (this) {
    .system => .system,
    .light => .light,
    .dark => .dark,
  };
}
