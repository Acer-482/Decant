import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:decant/features/settings/enums/theme_mode_option.dart';
import 'package:decant/features/settings/models/theme_config.dart';
import 'package:decant/shared/models/base_preferences_notifier.dart';
import 'package:decant/shared/services/preferences_service.dart';

/// 主题首选项
final themePreferencesProvider =
    AsyncNotifierProvider<ThemePreferencesNotifier, ThemeConfig>(
      ThemePreferencesNotifier.new,
    );

/// 同步读取的主题配置
///
/// 首选项还没读出来时先给默认值，避免启动瞬间闪一下或抛错
final themeConfigProvider = Provider<ThemeConfig>(
  (ref) => ref.watch(themePreferencesProvider).value ?? ThemeConfig.defaults,
);

/// 主题首选项通知器
class ThemePreferencesNotifier extends BasePreferencesNotifier<ThemeConfig> {
  static const String _keySeedColor = 'seedColor'; // 种子色
  static const String _keyMode = 'mode'; // 亮暗模式

  @override
  String get mainKey => 'Theme';

  @override
  FutureOr<ThemeConfig> build() async {
    final service = ref.read(preferencesServiceProvider);
    return ThemeConfig(
      seedColor: await service.getColor(
        getKey(_keySeedColor),
        ThemeConfig.defaults.seedColor,
      ),
      mode: await service.getEnum(
        getKey(_keyMode),
        ThemeModeOption.values,
        ThemeConfig.defaults.mode,
      ),
    );
  }

  /// 设置主题色
  Future<void> setSeedColor(Color value) async {
    await config.setColor(getKey(_keySeedColor), value);
    if (!ref.mounted) return;
    updateState((config) => config.copyWith(seedColor: value));
  }

  /// 设置亮暗模式
  Future<void> setMode(ThemeModeOption value) async {
    await config.setEnum(getKey(_keyMode), value);
    if (!ref.mounted) return;
    updateState((config) => config.copyWith(mode: value));
  }
}
