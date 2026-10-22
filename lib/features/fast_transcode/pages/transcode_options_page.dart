import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:decant/features/fast_transcode/providers/media_info_provider.dart';
import 'package:decant/features/fast_transcode/widgets/transcode_options_card.dart';

/// 转码页面
class TranscodeOptionsPage extends ConsumerWidget {
  /// 文件路径
  final String filePath;

  const TranscodeOptionsPage({super.key, required this.filePath});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaAsyncInfo = ref.watch(mediaInfoProvider(filePath));
    return Container(
      padding: .all(10),
      child: mediaAsyncInfo.when(
        data: (mediaInfo) {
          return Column(children: [TranscodeOptionsCard(mediaInfo: mediaInfo)]);
        },
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 16,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              Text('获取媒体信息失败\n$error', textAlign: TextAlign.center),
              ElevatedButton(
                onPressed: () => ref.invalidate(mediaInfoProvider(filePath)),
                child: const Text('重试'),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
