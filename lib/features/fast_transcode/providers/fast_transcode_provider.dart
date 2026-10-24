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

  /// 选择首个源，进入信息页
  void selectSource(BaseSource source) {
    state = state.copyWith(step: .viewInfo, sources: [source]);
  }

  /// 追加一个源（多路输入）
  void addSource(BaseSource source) {
    state = state.copyWith(sources: [...state.sources, source]);
  }

  /// 移除指定下标的源
  void removeSourceAt(int index) {
    if (index < 0 || index >= state.sources.length) return;
    final next = [...state.sources]..removeAt(index);
    state = state.copyWith(sources: next);
  }

  /// 重置
  void reset() {
    state = const FastTranscodeState(); // 回到第一步
  }

  /// 开始配置
  void startConfigOptions() {
    state = state.copyWith(step: .configureTranscodeOptions);
  }

  /// 开始转码
  void startTranscoding(List<StreamConfig> configs) {
    state = state.copyWith(step: .transcoding, streamConfigs: configs);
  }
}
