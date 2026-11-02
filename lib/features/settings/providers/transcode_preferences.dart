import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:decant/features/settings/models/transcode_config.dart';
import 'package:decant/shared/models/base_preferences_notifier.dart';
import 'package:decant/shared/services/preferences_service.dart';

/// 转码首选项
final transcodePreferencesProvider =
    AsyncNotifierProvider<TranscodePreferencesNotifier, TranscodeConfig>(
      TranscodePreferencesNotifier.new,
    );

/// 同步读取的转码配置
///
/// 首选项还没读出来时先给默认值
final transcodeConfigProvider = Provider<TranscodeConfig>(
  (ref) =>
      ref.watch(transcodePreferencesProvider).value ?? TranscodeConfig.defaults,
);

/// 转码首选项通知器
class TranscodePreferencesNotifier extends BasePreferencesNotifier<
    TranscodeConfig
> {
  static const String _keyDefaultOutputDir = 'defaultOutputDir'; // 默认输出目录
  static const String _keyAutoOpenOutput = 'autoOpenOutput'; // 自动打开输出目录

  @override
  String get mainKey => 'Transcode';

  @override
  FutureOr<TranscodeConfig> build() async {
    final service = ref.read(preferencesServiceProvider);
    final dir = await service.getString(getKey(_keyDefaultOutputDir), '');

    return TranscodeConfig(
      defaultOutputDir: dir.isEmpty ? null : dir,
      autoOpenOutput: await service.getBool(
        getKey(_keyAutoOpenOutput),
        TranscodeConfig.defaults.autoOpenOutput,
      ),
    );
  }

  /// 设置默认输出目录，传 null 表示跟随源文件
  Future<void> setDefaultOutputDir(String? value) async {
    if (value == null || value.isEmpty) {
      await config.remove(getKey(_keyDefaultOutputDir));
      if (!ref.mounted) return;
      updateState((config) => config.copyWith(clearDefaultOutputDir: true));
      return;
    }

    await config.setString(getKey(_keyDefaultOutputDir), value);
    if (!ref.mounted) return;
    updateState((config) => config.copyWith(defaultOutputDir: value));
  }

  /// 设置完成后是否自动打开输出目录
  Future<void> setAutoOpenOutput(bool value) async {
    await config.setBool(getKey(_keyAutoOpenOutput), value);
    if (!ref.mounted) return;
    updateState((config) => config.copyWith(autoOpenOutput: value));
  }
}
