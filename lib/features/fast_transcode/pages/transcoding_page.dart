import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit_config.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_transcoder/domain/media/media_info.dart';
import 'package:media_transcoder/features/fast_transcode/providers/fast_transcode_provider.dart';
import 'package:media_transcoder/features/fast_transcode/providers/media_info_provider.dart';
import 'package:media_transcoder/features/fast_transcode/utils/ffmpeg_args_builder.dart';
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher.dart';

enum TranscodeStatus { running, success, failed }

class TranscodingPage extends ConsumerStatefulWidget {
  final String filePath;

  const TranscodingPage({super.key, required this.filePath});

  @override
  ConsumerState<TranscodingPage> createState() => _TranscodingPageState();
}

class _TranscodingPageState extends ConsumerState<TranscodingPage> {
  TranscodeStatus _status = TranscodeStatus.running;
  double _progress = 0.0;
  String? _errorLog;
  late String _outputPath;
  double _totalDurationMs = 0.0;

  MediaInfo? _mediaInfo;

  @override
  void initState() {
    super.initState();

    // 设定输出路径
    final dir = p.dirname(widget.filePath);
    final name = p.basenameWithoutExtension(widget.filePath);
    _outputPath = p.join(dir, '${name}_transcoded.mp4');

    // 延迟一帧执行，先让 UI 渲染出 Loading 状态
    Future.microtask(() => _initAndStart());
  }

  /// 初始化数据并开始转码
  Future<void> _initAndStart() async {
    try {
      _mediaInfo = await ref.read(mediaInfoProvider(widget.filePath).future);
      // 解析总时长用于计算进度
      final seconds = double.tryParse(_mediaInfo!.duration) ?? 0.0;
      _totalDurationMs = seconds * 1000;
      // 开始转码
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

  Future<void> _startTranscoding() async {
    final configs = ref.read(fastTranscodeProvider).streamConfigs; // 流配置
    final streams = _mediaInfo!.streams; // 源媒体流

    final args = FfmpegArgsBuilder.build(configs, streams); // 构建 FFmpeg 参数

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

    // 组装完整命令
    final command =
        '-y -i "${widget.filePath}" ${args.join(' ')} "$_outputPath"';
    debugPrint('FFmpeg Command: $command');

    // 执行命令
    final session = await FFmpegKit.execute(command);
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
      child: switch (_status) {
        TranscodeStatus.running => _buildRunning(),
        TranscodeStatus.success => _buildSuccess(),
        TranscodeStatus.failed => _buildFailed(),
      },
    );
  }

  Widget _buildRunning() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 24),
        Text(
          '正在转码... ${(_progress * 100).toStringAsFixed(0)}%',
          style: const TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 8),
        const Text('请勿关闭应用', style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildSuccess() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.check_circle_outline, color: Colors.green, size: 80),
        const SizedBox(height: 24),
        const Text(
          '转码成功！',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(_outputPath, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton.icon(
              onPressed: () async {
                final uri = Uri.file(p.dirname(_outputPath));
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
      mainAxisAlignment: MainAxisAlignment.center,
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
          mainAxisAlignment: MainAxisAlignment.center,
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
