import 'package:flutter/material.dart';
import 'package:decant/domain/encoder/audio_encoder.dart';
import 'package:decant/domain/encoder/video_encoder.dart';
import 'package:decant/domain/media/stream_config/audio_stream_config.dart';
import 'package:decant/domain/media/stream_config/stream_config.dart';
import 'package:decant/domain/media/stream_config/video_stream_config.dart';
import 'package:decant/domain/media/stream_info/audio_stream_info.dart';
import 'package:decant/domain/media/stream_info/base_stream_info.dart';
import 'package:decant/domain/media/stream_info/video_stream_info.dart';
import 'package:decant/features/fast_transcode/utils/stream_labels.dart';
import 'package:decant/features/fast_transcode/widgets/switch_row.dart';
import 'package:decant/shared/widgets/path_text.dart';

/// 单条流的设置面板
class StreamTile extends StatelessWidget {
  /// 流信息
  final BaseStreamInfo stream;

  /// 流配置
  final StreamConfig config;

  /// 配置变化
  final ValueChanged<StreamConfig> onChanged;

  /// 单独输出的最终路径
  final String outputPath;

  /// 是否使用自定义路径
  final bool customPath;

  /// 选择路径
  final VoidCallback onPickPath;

  /// 恢复默认路径
  final VoidCallback onResetPath;

  const StreamTile({
    super.key,
    required this.stream,
    required this.config,
    required this.onChanged,
    required this.outputPath,
    required this.customPath,
    required this.onPickPath,
    required this.onResetPath,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 未知流不支持配置
    if (stream is! VideoStreamInfo && stream is! AudioStreamInfo) {
      return Container(
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: .circular(12),
        ),
        child: ListTile(
          dense: true,
          leading: const Icon(Icons.help_outline, size: 18),
          title: Text(streamTitle(stream)),
          subtitle: const Text('当前不支持的流类型'),
          enabled: false,
        ),
      );
    }

    return AnimatedSize(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      alignment: .topCenter,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: .circular(12),
        ),
        clipBehavior: .antiAlias,
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 12),
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
          shape: const Border(),
          collapsedShape: const Border(),
          leading: Icon(
            stream is VideoStreamInfo ? Icons.movie_outlined : Icons.music_note,
            size: 20,
            color: config.enabled
                ? theme.colorScheme.primary
                : theme.colorScheme.outline,
          ),
          title: Text(streamTitle(stream), style: theme.textTheme.titleSmall),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                _Chip(text: codecInfo(stream)), // 编码信息
                _Chip(
                  text: !config.enabled
                      ? '已禁用'
                      : (config.copyMode ? '复制' : '重编码'),
                  accent: config.enabled,
                ),
                if (config.separateOutput)
                  const _Chip(text: '单独输出', accent: true),
              ],
            ),
          ),
          children: [
            SwitchRow(
              title: '启用该流',
              value: config.enabled,
              onChanged: (val) => onChanged(config.copyWith(enabled: val)),
            ),
            if (config.enabled) ...[
              SwitchRow(
                title: '复制流',
                subtitle: '速度最快且完全无损',
                value: config.copyMode,
                onChanged: (val) => onChanged(config.copyWith(copyMode: val)),
              ),
              if (!config.copyMode) _buildEncoderSelector(theme),
              SwitchRow(
                title: '单独输出',
                subtitle: '这条流写入独立文件',
                value: config.separateOutput,
                onChanged: (val) =>
                    onChanged(config.copyWith(separateOutput: val)),
              ),
              if (config.separateOutput) _buildOutputPathRow(theme),
            ],
          ],
        ),
      ),
    );
  }

  /// 单独输出的路径行
  Widget _buildOutputPathRow(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: InkWell(
        onTap: onPickPath,
        borderRadius: .circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: .circular(8),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Row(
            children: [
              Icon(
                Icons.description_outlined,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: PathText(
                  outputPath,
                  style: theme.textTheme.bodySmall,
                ),
              ),
              if (customPath)
                InkWell(
                  onTap: onResetPath,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(
                      Icons.restart_alt,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              const SizedBox(width: 4),
              Text(
                '更改',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 编码器选择
  Widget _buildEncoderSelector(ThemeData theme) {
    switch (config) {
      case final VideoStreamConfig video:
        return _dropdown<VideoEncoder>(
          initialValue: video.encoder,
          label: '视频编码器',
          values: VideoEncoder.values,
          name: (e) => '${e.codec.displayName} (${e.ffmpegName})',
          onChanged: (val) => onChanged(video.copyWith(encoder: val)),
        );
      case final AudioStreamConfig audio:
        return _dropdown<AudioEncoder>(
          initialValue: audio.encoder,
          label: '音频编码器',
          values: AudioEncoder.values,
          name: (e) => '${e.codec.displayName} (${e.ffmpegName})',
          onChanged: (val) => onChanged(audio.copyWith(encoder: val)),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  /// 编码器下拉框
  Widget _dropdown<T>({
    required T initialValue,
    required String label,
    required List<T> values,
    required String Function(T) name,
    required void Function(T) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, right: 4, bottom: 6),
      child: DropdownButtonFormField<T>(
        initialValue: initialValue,
        isDense: true,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
        ),
        items: values
            .map((e) => DropdownMenuItem(value: e, child: Text(name(e))))
            .toList(),
        onChanged: (val) {
          if (val != null) onChanged(val);
        },
      ),
    );
  }
}

/// 小标签
class _Chip extends StatelessWidget {
  final String text;
  final bool accent;

  const _Chip({required this.text, this.accent = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: accent
            ? theme.colorScheme.primary.withValues(alpha: 0.12)
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: .circular(4),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          color: accent
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
