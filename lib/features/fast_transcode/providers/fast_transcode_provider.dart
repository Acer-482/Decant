import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:decant/domain/media/stream_config/stream_config.dart';
import 'package:decant/domain/source/base_source.dart';
import 'package:decant/features/fast_transcode/models/fast_transcode_state.dart';

/// 快速转码状态提供器
final fastTranscodeProvider =
    NotifierProvider<FastTranscodeNotifier, FastTranscodeState>(
      FastTranscodeNotifier.new,
    );

/// 快速转码监听器
class FastTranscodeNotifier extends Notifier<FastTranscodeState> {
  @override
  FastTranscodeState build() => const FastTranscodeState();

  /// 追加输入源
  ///
  /// 按 input 去重
  void addSources(List<BaseSource> sources) {
    final next = [...state.sources];
    for (final source in sources) {
      if (next.any((existing) => existing.input == source.input)) continue;
      next.add(source);
    }
    if (next.length == state.sources.length) return;
    state = state.copyWith(sources: next);
  }

  /// 移除输入源
  ///
  /// 按 input 定位，避免删除动画期间下标错位
  void removeSource(String input) {
    final next = state.sources.where((source) => source.input != input).toList();
    if (next.length == state.sources.length) return;
    state = state.copyWith(sources: next);
  }

  /// 设置输出目录
  void setOutputDir(String? dir) {
    state = state.copyWith(outputDir: dir);
  }

  /// 设置主输出文件名
  void setOutputName(String? name) {
    state = state.copyWith(outputName: name);
  }

  /// 重置
  void reset() {
    state = const FastTranscodeState(); // 回到第一步
  }

  /// 进入配置步骤
  void startConfigOptions() {
    state = state.copyWith(step: .configureTranscodeOptions);
  }

  /// 开始转码
  void startTranscoding(List<StreamConfig> configs) {
    state = state.copyWith(step: .transcoding, streamConfigs: configs);
  }
}
