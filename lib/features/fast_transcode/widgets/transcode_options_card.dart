import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:decant/domain/encoder/audio_encoder.dart';
import 'package:decant/domain/encoder/video_encoder.dart';
import 'package:decant/domain/media/media_info.dart';
import 'package:decant/domain/media/stream_config/audio_stream_config.dart';
import 'package:decant/domain/media/stream_config/stream_config.dart';
import 'package:decant/domain/media/stream_config/unknown_stream_config.dart';
import 'package:decant/domain/media/stream_config/video_stream_config.dart';
import 'package:decant/domain/media/stream_info/audio_stream_info.dart';
import 'package:decant/domain/media/stream_info/base_stream_info.dart';
import 'package:decant/domain/media/stream_info/video_stream_info.dart';
import 'package:decant/features/fast_transcode/providers/fast_transcode_provider.dart';
import 'package:decant/shared/widgets/title_card.dart';

/// 转码选项卡片
class TranscodeOptionsCard extends ConsumerStatefulWidget {
  /// 媒体信息
  final MediaInfo mediaInfo;

  const TranscodeOptionsCard({super.key, required this.mediaInfo});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TranscodeOptionsCardState();
}

class _TranscodeOptionsCardState extends ConsumerState<TranscodeOptionsCard> {
  /// 流选项
  late final List<StreamConfig> _streamConfigs;

  @override
  void initState() {
    super.initState();
    _streamConfigs = widget.mediaInfo.streams.map((stream) {
      if (stream is VideoStreamInfo) {
        return VideoStreamConfig(
          encoder: VideoEncoder.values.firstWhere(
            (encoder) =>
                encoder.codec.ffprobeName == stream.codecName && // 默认编码器
                encoder.type == .software, // 软件
            orElse: () => .libx264, // 兜底使用软件编码
          ),
        );
      } // 视频流
      else if (stream is AudioStreamInfo) {
        return AudioStreamConfig(
          encoder: AudioEncoder.values.firstWhere(
            (encoder) => encoder.codec.ffprobeName == stream.codecName, // 默认编码器
            orElse: () => .aac, // 兜底使用通用格式
          ),
        );
      } // 音频流

      return const UnknownStreamConfig(); // 未知流
    }).toList();
  }

  /// 更新特定流的配置
  void _updateConfig(int index, StreamConfig newConfig) {
    setState(() => _streamConfigs[index] = newConfig);
  }

  @override
  Widget build(BuildContext context) {
    return TitleCard(
      icon: const Icon(Icons.movie),
      title: const Text('转码设置'),
      child: Column(
        children: [
          for (var i = 0; i < widget.mediaInfo.streams.length; i++)
            _buildStreamTile(widget.mediaInfo.streams[i], i),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                ref
                    .read(fastTranscodeProvider.notifier)
                    .startTranscoding(_streamConfigs); // 存入配置 开始转码
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('开始转码'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 为单个流构建设置面板
  Widget _buildStreamTile(BaseStreamInfo stream, int index) {
    final config = _streamConfigs[index];

    // 获取流显示名称
    String title = '未知流 #${stream.index}';
    if (stream is VideoStreamInfo) {
      title = '视频流 #${stream.index}';
    } else if (stream is AudioStreamInfo) {
      title = '音频流 #${stream.index}';
    } else {
      return SwitchListTile(
        title: Text(title),
        subtitle: const Text('当前不支持的流类型'),
        value: config.enabled,
        onChanged: (val) => _updateConfig(index, config.copyWith(enabled: val)),
      );
    }

    return ExpansionTile(
      title: Text(title),
      subtitle: Text(config.copyMode ? '复制原流' : '重新编码'),
      childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      children: [
        // 是否启用
        SwitchListTile(
          title: const Text('启用该流'),
          value: config.enabled,
          onChanged: (val) =>
              _updateConfig(index, config.copyWith(enabled: val)),
        ),
        // 是否复制流
        if (config.enabled) ...[
          SwitchListTile(
            title: const Text('复制流'),
            subtitle: const Text('速度最快且完全无损'),
            value: config.copyMode,
            onChanged: (val) =>
                _updateConfig(index, config.copyWith(copyMode: val)),
          ),
          if (!config.copyMode) _buildEncoderSelector(stream, config, index),
        ],
      ],
    );
  }

  /// 构建编码器下拉框
  Widget _buildEncoderSelector(
    BaseStreamInfo stream,
    StreamConfig config,
    int index,
  ) {
    if (stream is VideoStreamInfo && config is VideoStreamConfig) {
      return DropdownButtonFormField<VideoEncoder>(
        initialValue: config.encoder,
        decoration: const InputDecoration(labelText: '视频编码器'),
        items: VideoEncoder.values.map((e) {
          return DropdownMenuItem(
            value: e,
            child: Text('${e.codec.displayName} (${e.ffmpegName})'),
          );
        }).toList(),
        onChanged: (val) {
          if (val != null) _updateConfig(index, config.copyWith(encoder: val));
        },
      );
    }

    if (stream is AudioStreamInfo && config is AudioStreamConfig) {
      return DropdownButtonFormField<AudioEncoder>(
        initialValue: config.encoder,
        decoration: const InputDecoration(labelText: '音频编码器'),
        items: AudioEncoder.values.map((e) {
          return DropdownMenuItem(
            value: e,
            child: Text('${e.codec.displayName} (${e.ffmpegName})'),
          );
        }).toList(),
        onChanged: (val) {
          if (val != null) {
            _updateConfig(
              index,
              AudioStreamConfig(copyMode: config.copyMode, encoder: val),
            );
          }
        },
      );
    }

    return const SizedBox.shrink();
  }
}
