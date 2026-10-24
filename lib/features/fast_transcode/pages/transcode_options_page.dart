import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:decant/domain/media/media_input.dart';
import 'package:decant/domain/source/base_source.dart';
import 'package:decant/features/fast_transcode/providers/media_info_provider.dart';
import 'package:decant/features/fast_transcode/utils/output_path.dart';
import 'package:decant/features/fast_transcode/widgets/transcode_options_card.dart';

/// 转码选项页面
///
/// 输入源已确定，这里只配置每条流的输出
class TranscodeOptionsPage extends ConsumerWidget {
  /// 输入源
  final List<BaseSource> sources;

  const TranscodeOptionsPage({super.key, required this.sources});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final infos = [
      for (final source in sources) ref.watch(mediaInfoProvider(source.input)),
    ];

    if (infos.any((info) => info.isLoading)) {
      return const Center(child: CircularProgressIndicator());
    }

    for (final info in infos) {
      if (info.hasError) {
        return Center(
          child: Column(
            mainAxisAlignment: .center,
            spacing: 16,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              Text('获取媒体信息失败\n${info.error}', textAlign: .center),
              ElevatedButton(
                onPressed: () {
                  for (final source in sources) {
                    ref.invalidate(mediaInfoProvider(source.input));
                  }
                },
                child: const Text('重试'),
              ),
            ],
          ),
        );
      }
    }

    final inputs = [
      for (var i = 0; i < sources.length; i++)
        MediaInput(source: sources[i], info: infos[i].requireValue),
    ];

    return Container(
      padding: .all(10),
      child: SingleChildScrollView(
        child: TranscodeOptionsCard(
          inputs: inputs,
          outputPath: defaultOutputPath(sources),
        ),
      ),
    );
  }
}
