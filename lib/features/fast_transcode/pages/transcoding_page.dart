import 'dart:io';

import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_session.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:ffmpeg_kit_flutter_new/statistics.dart';
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
enum TranscodeStatus { running, success, failed, cancelled }

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

  FFmpegSession? _session; // 当前转码会话
  bool _cancelling = false; // 是否已请求取消

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

  @override
  void dispose() {
    // 离开页面时中断仍在跑的转码
    final session = _session;
    if (session != null && _status == TranscodeStatus.running) {
      session.cancel();
    }
    super.dispose();
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
    final state = ref.read(fastTranscodeProvider);
    final configs = state.streamConfigs; // 流配置

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
      outputName: state.outputName,
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

    // 异步执行，拿到会话以便随时中断
    _session = await FFmpegKit.executeAsync(
      command.command,
      _onSessionComplete,
      null,
      _onStatistics,
    );

    // 会话创建前用户已经点了取消
    if (_cancelling) await _session?.cancel();
  }

  /// 进度回调
  void _onStatistics(Statistics stats) {
    if (!mounted || _status != TranscodeStatus.running) return;
    if (_totalDurationMs <= 0) return;

    final progress = (stats.getTime() / _totalDurationMs).clamp(0.0, 1.0);
    if ((progress - _progress).abs() > 0.01) {
      setState(() => _progress = progress);
    }
  }

  /// 转码结束回调
  void _onSessionComplete(FFmpegSession session) async {
    try {
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isCancel(returnCode)) {
        await _discardOutputs(); // 取消后清掉残片
        if (!mounted) return;
        setState(() => _status = TranscodeStatus.cancelled);
        return;
      }

      if (ReturnCode.isSuccess(returnCode)) {
        try {
          await _commitOutputs(); // 临时文件改名为最终文件
          if (!mounted) return;
          setState(() => _status = TranscodeStatus.success);
        } catch (e) {
          await _discardOutputs();
          if (!mounted) return;
          setState(() {
            _status = TranscodeStatus.failed;
            _errorLog = '保存输出文件失败: $e';
          });
        }
        return;
      }

      await _discardOutputs(); // 失败时清掉残片
      final log = await session.getAllLogsAsString();
      if (!mounted) return;
      setState(() {
        _status = TranscodeStatus.failed;
        _errorLog = log ?? '未知错误';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _status = TranscodeStatus.failed;
        _errorLog = '转码中断: $e';
      });
    }
  }

  /// 取消转码
  Future<void> _cancel() async {
    if (_cancelling) return;
    setState(() => _cancelling = true);
    await _session?.cancel();
  }

  /// 返回转码设置
  void _backToOptions() {
    ref.read(fastTranscodeProvider.notifier).backToConfigOptions();
  }

  /// 返回首页
  void _reset() {
    ref.read(fastTranscodeProvider.notifier).reset();
  }

  /// 重新转码
  void _retry() {
    setState(() {
      _status = TranscodeStatus.running;
      _progress = 0.0;
      _cancelling = false;
    });
    _startTranscoding();
  }

  /// 把临时文件改名为最终文件
  Future<void> _commitOutputs() async {
    for (final output in _outputs) {
      final temp = File(output.tempPath);
      if (!await temp.exists()) continue;

      final target = File(output.path);
      if (await target.exists()) await target.delete();
      await temp.rename(output.path);
    }
  }

  /// 删除临时文件
  Future<void> _discardOutputs() async {
    for (final output in _outputs) {
      final temp = File(output.tempPath);
      if (await temp.exists()) await temp.delete();
    }
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
          TranscodeStatus.cancelled => _buildCancelled(),
        },
      ),
    );
  }

  Widget _buildRunning() {
    final percent = (_progress * 100).toStringAsFixed(0);
    return Column(
      key: const ValueKey('running'),
      mainAxisAlignment: .center,
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 24),
        Text(
          _cancelling ? '正在取消...' : '正在转码... $percent%',
          style: const TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: _progress, semanticsLabel: percent),
        const SizedBox(height: 8),
        const Text('喝杯茶，休息一下吧', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 32),
        OutlinedButton.icon(
          onPressed: _cancelling ? null : _cancel,
          icon: const Icon(Icons.stop_circle_outlined),
          label: Text(_cancelling ? '正在取消' : '取消转码'),
        ),
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
              onPressed: _reset, // 重置状态机回到第一步
              icon: const Icon(Icons.home),
              label: const Text('返回首页'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCancelled() {
    final theme = Theme.of(context);
    return Column(
      key: const ValueKey('cancelled'),
      mainAxisAlignment: .center,
      children: [
        Icon(Icons.cancel_outlined, size: 80, color: theme.colorScheme.outline),
        const SizedBox(height: 24),
        const Text(
          '已取消转码',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(
          '未完成的临时文件已清理',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: .center,
          children: [
            OutlinedButton.icon(
              onPressed: _backToOptions,
              icon: const Icon(Icons.tune),
              label: const Text('返回设置'),
            ),
            const SizedBox(width: 16),
            FilledButton.icon(
              onPressed: _retry,
              icon: const Icon(Icons.refresh),
              label: const Text('重新转码'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextButton(onPressed: _reset, child: const Text('返回首页')),
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
            OutlinedButton.icon(
              onPressed: _backToOptions,
              icon: const Icon(Icons.tune),
              label: const Text('返回设置'),
            ),
            const SizedBox(width: 16),
            FilledButton.icon(
              onPressed: _retry,
              icon: const Icon(Icons.refresh),
              label: const Text('重试'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextButton(onPressed: _reset, child: const Text('返回首页')),
      ],
    );
  }
}
