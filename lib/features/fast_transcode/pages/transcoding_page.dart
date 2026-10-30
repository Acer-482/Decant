import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit_config.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher.dart';
import 'package:decant/domain/source/base_source.dart';
import 'package:decant/features/fast_transcode/providers/fast_transcode_provider.dart';
import 'package:decant/features/fast_transcode/providers/media_info_provider.dart';
import 'package:decant/features/fast_transcode/utils/ffmpeg_args_builder.dart';
import 'package:decant/features/fast_transcode/utils/output_path.dart';

/// 转码状态
enum TranscodeStatus { running, success, failed }

/// 转码页面
class TranscodingPage extends ConsumerStatefulWidget {
  /// 输入源
  final List<BaseSource> sources;

  const TranscodingPage({super.key, required this.sources});

  @override
  ConsumerState<TranscodingPage> createState() => _TranscodingPageState();
}

class _TranscodingPageState extends ConsumerState<TranscodingPage> {
  TranscodeStatus _status = TranscodeStatus.running;
  double _progress = 0.0;
  String? _errorLog;
  double _totalDurationMs = 0.0;

  late final String _outputDir; // 输出目录
  late final String _baseName; // 输出基础名
  List<FfmpegOutput> _outputs = const []; // 产物列表

  @override
  void initState() {
    super.initState();

    // 与配置页保持一致
    final state = ref.read(fastTranscodeProvider);
    _outputDir = state.outputDir ?? defaultOutputDir(widget.sources);
    _baseName = defaultBaseName(widget.sources);

    // 延迟一帧执行，先让 UI 渲染出 Loading 状态
    Future.microtask(() => _initAndStart());
  }

  /// 初始化数据并开始转码
  Future<void> _initAndStart() async {
    try {
      final infos = await Future.wait(
        widget.sources.map(
          (source) => ref.read(mediaInfoProvider(source.input).future),
        ),
      );

      // 多路输入时以最长的那一路作为进度基准
      _totalDurationMs = infos
          .map((info) => (double.tryParse(info.duration) ?? 0.0) * 1000)
          .fold<double>(0.0, (a, b) => a > b ? a : b);

      await _startTranscoding();
    } catch (e) {
      if (mounted) {
        setState(() {
          _status = TranscodeStatus.failed;
          _errorLog = '加载媒体信息失败: $e';
        });
      }
    }
  }

  /// 执行转码
  Future<void> _startTranscoding() async {
    final configs = ref.read(fastTranscodeProvider).streamConfigs; // 流配置

    if (!configs.any((config) => config.enabled)) {
      setState(() {
        _status = TranscodeStatus.failed;
        _errorLog = '没有启用任何流，请至少保留一路视频或音频。';
      });
      return;
    }

    final command = FfmpegArgsBuilder.buildCommand(
      sources: widget.sources,
      configs: configs,
      outputDir: _outputDir,
      baseName: _baseName,
    );

    if (command.outputs.isEmpty) {
      setState(() {
        _status = TranscodeStatus.failed;
        _errorLog = '没有需要输出的文件。';
      });
      return;
    }

    _outputs = command.outputs;
    debugPrint('FFmpeg Command: ${command.command}');

    // 监听进度
    FFmpegKitConfig.enableStatisticsCallback((stats) {
      final timeMs = stats.getTime();
      if (_totalDurationMs > 0) {
        final progress = (timeMs / _totalDurationMs).clamp(0.0, 1.0);
        if ((progress - _progress).abs() > 0.01) {
          setState(() => _progress = progress);
        }
      }
    });

    // 执行命令
    final session = await FFmpegKit.execute(command.command);
    final returnCode = await session.getReturnCode();

    // 处理结果
    if (ReturnCode.isSuccess(returnCode)) {
      setState(() => _status = TranscodeStatus.success);
    } else {
      final log = await session.getAllLogsAsString();
      setState(() {
        _status = TranscodeStatus.failed;
        _errorLog = log ?? '未知错误';
      });
    }

    FFmpegKitConfig.enableStatisticsCallback(null);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedSwitcher(
        duration: 400.ms,
        child: switch (_status) {
          TranscodeStatus.running => _buildRunning(),
          TranscodeStatus.success => _buildSuccess(),
          TranscodeStatus.failed => _buildFailed(),
        },
      ),
    );
  }

  Widget _buildRunning() {
    return Column(
      key: const ValueKey('running'),
      mainAxisAlignment: .center,
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 24),
        Text(
          '正在转码... ${(_progress * 100).toStringAsFixed(0)}%',
          style: const TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: _progress,
          semanticsLabel: (_progress * 100).toStringAsFixed(0),
        ),
        const SizedBox(height: 8),
        const Text('请勿关闭应用', style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildSuccess() {
    final theme = Theme.of(context);
    return Column(
      key: const ValueKey('success'),
      mainAxisAlignment: .center,
      children: [
        const Icon(Icons.check_circle_outline, color: Colors.green, size: 80),
        const SizedBox(height: 24),
        const Text(
          '转码成功！',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        // 产物列表
        for (final output in _outputs)
          Text(
            p.basename(output.path),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: .center,
          children: [
            OutlinedButton.icon(
              onPressed: () async {
                final uri = Uri.file(_outputDir);
                if (await canLaunchUrl(uri)) await launchUrl(uri);
              },
              icon: const Icon(Icons.folder_open),
              label: const Text('打开文件夹'),
            ),
            const SizedBox(width: 16),
            FilledButton.icon(
              onPressed: () {
                // 重置状态机回到第一步
                ref.read(fastTranscodeProvider.notifier).reset();
              },
              icon: const Icon(Icons.home),
              label: const Text('返回首页'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFailed() {
    return Column(
      key: const ValueKey('failed'),
      mainAxisAlignment: .center,
      children: [
        const Icon(Icons.error_outline, color: Colors.red, size: 80),
        const SizedBox(height: 24),
        const Text(
          '转码失败',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          height: 150,
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: SingleChildScrollView(
            child: SelectableText(
              _errorLog ?? '未知错误',
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: .center,
          children: [
            OutlinedButton(
              onPressed: () => ref.read(fastTranscodeProvider.notifier).reset(),
              child: const Text('返回首页'),
            ),
            const SizedBox(width: 16),
            FilledButton(
              onPressed: () {
                setState(() {
                  _status = TranscodeStatus.running;
                  _progress = 0.0;
                });
                _startTranscoding(); // 重试
              },
              child: const Text('重试'),
            ),
          ],
        ),
      ],
    );
  }
}
