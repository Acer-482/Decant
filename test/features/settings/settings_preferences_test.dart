import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:decant/features/settings/enums/theme_mode_option.dart';
import 'package:decant/features/settings/models/theme_config.dart';
import 'package:decant/features/settings/providers/theme_preferences.dart';
import 'package:decant/features/settings/providers/transcode_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('主题默认值', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(await container.read(themePreferencesProvider.future), ThemeConfig.defaults);
    expect(container.read(themeConfigProvider), ThemeConfig.defaults);
  });

  test('主题设置会持久化，重启后仍然有效', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(themePreferencesProvider.future); // 等首选项加载完
    final notifier = container.read(themePreferencesProvider.notifier);
    await notifier.setMode(ThemeModeOption.light);
    await notifier.setSeedColor(Colors.orange);

    expect(container.read(themeConfigProvider).mode, ThemeModeOption.light);
    expect(container.read(themeConfigProvider).seedColor.toARGB32(), Colors.orange.toARGB32());

    // 新容器相当于重启应用
    final restarted = ProviderContainer();
    addTearDown(restarted.dispose);
    final reloaded = await restarted.read(themePreferencesProvider.future);

    expect(reloaded.mode, ThemeModeOption.light);
    expect(reloaded.seedColor.toARGB32(), Colors.orange.toARGB32());
  });

  test('转码默认值：自动打开输出目录默认开启，默认目录为空', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final config = await container.read(transcodePreferencesProvider.future);

    expect(config.autoOpenOutput, isTrue);
    expect(config.defaultOutputDir, isNull);
  });

  test('转码设置会持久化', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(transcodePreferencesProvider.future);
    final notifier = container.read(transcodePreferencesProvider.notifier);
    await notifier.setDefaultOutputDir('/media/out');
    await notifier.setAutoOpenOutput(false);

    final restarted = ProviderContainer();
    addTearDown(restarted.dispose);
    final reloaded = await restarted.read(transcodePreferencesProvider.future);

    expect(reloaded.defaultOutputDir, '/media/out');
    expect(reloaded.autoOpenOutput, isFalse);
  });

  test('默认输出目录可以恢复为跟随源文件', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(transcodePreferencesProvider.future);
    final notifier = container.read(transcodePreferencesProvider.notifier);
    await notifier.setDefaultOutputDir('/media/out');
    await notifier.setDefaultOutputDir(null);

    expect(container.read(transcodeConfigProvider).defaultOutputDir, isNull);

    final restarted = ProviderContainer();
    addTearDown(restarted.dispose);
    final reloaded = await restarted.read(transcodePreferencesProvider.future);

    expect(reloaded.defaultOutputDir, isNull);
  });
}
