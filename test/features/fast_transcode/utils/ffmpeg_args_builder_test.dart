import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit_config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:decant/domain/encoder/audio_encoder.dart';
import 'package:decant/domain/encoder/video_encoder.dart';
import 'package:decant/domain/media/stream_config/audio_stream_config.dart';
import 'package:decant/domain/media/stream_config/unknown_stream_config.dart';
import 'package:decant/domain/media/stream_config/video_stream_config.dart';
import 'package:decant/domain/source/file_source.dart';
import 'package:decant/features/fast_transcode/utils/ffmpeg_args_builder.dart';

/// 视频流配置
VideoStreamConfig _video(
  int input,
  int stream, {
  bool copy = false,
  bool enabled = true,
  bool separate = false,
  String? path,
  VideoEncoder encoder = VideoEncoder.libx264,
}) => VideoStreamConfig(
  inputIndex: input,
  streamIndex: stream,
  copyMode: copy,
  enabled: enabled,
  separateOutput: separate,
  outputPath: path,
  encoder: encoder,
);

/// 音频流配置
AudioStreamConfig _audio(
  int input,
  int stream, {
  bool copy = false,
  bool enabled = true,
  bool separate = false,
  String? path,
  AudioEncoder encoder = AudioEncoder.aac,
}) => AudioStreamConfig(
  inputIndex: input,
  streamIndex: stream,
  copyMode: copy,
  enabled: enabled,
  separateOutput: separate,
  outputPath: path,
  encoder: encoder,
);

/// 未知流配置
UnknownStreamConfig _unknown(
  int input,
  int stream, {
  bool copy = false,
  bool enabled = true,
  bool separate = false,
  String? path,
}) => UnknownStreamConfig(
  inputIndex: input,
  streamIndex: stream,
  copyMode: copy,
  enabled: enabled,
  separateOutput: separate,
  outputPath: path,
);

/// 按 FFmpegKit 的规则把命令切回参数
///
/// 用真实的切分器，才能验证引号与空格确实被正确处理
List<String> _tokens(FfmpegCommand command) =>
    FFmpegKitConfig.parseArguments(command.command);

/// 参数列表里是否出现某段连续参数
bool _has(List<String> tokens, List<String> expected) {
  for (var i = 0; i + expected.length <= tokens.length; i++) {
    var matched = true;
    for (var j = 0; j < expected.length; j++) {
      if (tokens[i + j] != expected[j]) {
        matched = false;
        break;
      }
    }
    if (matched) return true;
  }
  return false;
}

void main() {
  group('build', () {
    test('复制视频流时输出 copy', () {
      expect(FfmpegArgsBuilder.build([_video(0, 0, copy: true)]), [
        '-map',
        '0:0',
        '-c:v:0',
        'copy',
      ]);
    });

    test('转码视频流时输出编码器名', () {
      expect(FfmpegArgsBuilder.build([_video(0, 0)]), [
        '-map',
        '0:0',
        '-c:v:0',
        'libx264',
      ]);
    });

    test('同一个输出里的多条视频流按顺序编号，不互相覆盖', () {
      final args = FfmpegArgsBuilder.build([_video(0, 0), _video(0, 1)]);

      expect(args, [
        '-map',
        '0:0',
        '-c:v:0',
        'libx264',
        '-map',
        '0:1',
        '-c:v:1',
        'libx264',
      ]);
    });

    test('视频与音频分开编号', () {
      final args = FfmpegArgsBuilder.build([
        _video(0, 0, copy: true),
        _audio(0, 1, encoder: AudioEncoder.aac),
      ]);

      expect(args, [
        '-map',
        '0:0',
        '-c:v:0',
        'copy',
        '-map',
        '0:1',
        '-c:a:0',
        'aac',
      ]);
    });

    test('禁用的流不产生任何参数', () {
      expect(FfmpegArgsBuilder.build([_video(0, 0, enabled: false)]), isEmpty);
    });

    test('未知流复制时按输出内的流序号整体 copy', () {
      // 流序号是 1：前面已经有一条视频流，不能用 -c copy 把视频的参数也覆盖掉
      final args = FfmpegArgsBuilder.build([
        _video(0, 0),
        _unknown(0, 1, copy: true),
      ]);

      expect(_has(args, ['-map', '0:1', '-c:1', 'copy']), isTrue);
    });

    test('未知流不复制时只做映射', () {
      final args = FfmpegArgsBuilder.build([_unknown(0, 0)]);

      expect(args, ['-map', '0:0']);
    });
  });

  group('outputPathFor', () {
    test('有自定义路径时直接用', () {
      final custom = p.join('custom', 'out.mp4');
      final path = FfmpegArgsBuilder.outputPathFor(
        _video(0, 0, path: custom),
        outputDir: 'out',
        baseName: 'movie',
      );

      expect(path, custom);
    });

    test('视频流默认命名为 基础名_video', () {
      final path = FfmpegArgsBuilder.outputPathFor(
        _video(0, 0, encoder: VideoEncoder.libvpx),
        outputDir: 'out',
        baseName: 'movie',
      );

      expect(path, p.join('out', 'movie_video.webm'));
    });

    test('音频流默认命名为 基础名_audio', () {
      final path = FfmpegArgsBuilder.outputPathFor(
        _audio(0, 1),
        outputDir: 'out',
        baseName: 'movie',
      );

      expect(path, p.join('out', 'movie_audio.m4a'));
    });

    test('未知流用流序号命名', () {
      final path = FfmpegArgsBuilder.outputPathFor(
        _unknown(0, 3),
        outputDir: 'out',
        baseName: 'movie',
      );

      expect(path, p.join('out', 'movie_stream3.mkv'));
    });
  });

  group('mainPath', () {
    test('默认按基础名与编码推导的后缀命名', () {
      final path = FfmpegArgsBuilder.mainPath(
        configs: [_video(0, 0)],
        outputDir: 'out',
        baseName: 'movie',
      );

      expect(path, p.join('out', 'movie.mp4'));
    });

    test('自定义名没有后缀时补上后缀', () {
      final path = FfmpegArgsBuilder.mainPath(
        configs: [_video(0, 0)],
        outputDir: 'out',
        baseName: 'movie',
        outputName: '结局',
      );

      expect(path, p.join('out', '结局.mp4'));
    });

    test('自定义名已有后缀时保持原样', () {
      final path = FfmpegArgsBuilder.mainPath(
        configs: [_video(0, 0)],
        outputDir: 'out',
        baseName: 'movie',
        outputName: '结局.mkv',
      );

      expect(path, p.join('out', '结局.mkv'));
    });
  });

  test('tempPathFor 把后缀前插入 .part', () {
    final temp = FfmpegArgsBuilder.tempPathFor(p.join('out', 'movie.mp4'));

    expect(temp, p.join('out', 'movie.part.mp4'));
  });

  group('buildCommand', () {
    test('单个输入单个输出', () {
      final source = FileSource(path: p.join('in', 'movie.mkv'));
      final command = FfmpegArgsBuilder.buildCommand(
        sources: [source],
        configs: [_video(0, 0, copy: true)],
        outputDir: 'out',
        baseName: 'movie',
      );

      final tokens = _tokens(command);
      expect(tokens.first, '-y');
      expect(_has(tokens, ['-i', source.input]), isTrue);
      expect(_has(tokens, ['-map', '0:0', '-c:v:0', 'copy']), isTrue);

      final output = command.outputs.single;
      expect(output.path, p.join('out', 'movie.mp4'));
      expect(output.tempPath, p.join('out', 'movie.part.mp4'));
      expect(output.main, isTrue);
      expect(tokens.last, output.tempPath);
    });

    test('多个输入各自带一个 -i', () {
      final a = FileSource(path: p.join('in', 'a.mkv'));
      final b = FileSource(path: p.join('in', 'b.mkv'));
      final command = FfmpegArgsBuilder.buildCommand(
        sources: [a, b],
        configs: [_video(0, 0), _audio(1, 1)],
        outputDir: 'out',
        baseName: 'a',
      );

      final tokens = _tokens(command);
      expect(_has(tokens, ['-i', a.input]), isTrue);
      expect(_has(tokens, ['-i', b.input]), isTrue);
      expect(tokens.indexOf('-i'), lessThan(tokens.lastIndexOf('-i')));
    });

    test('独立输出的流单独成文件，主输出带标记', () {
      final command = FfmpegArgsBuilder.buildCommand(
        sources: [FileSource(path: p.join('in', 'movie.mkv'))],
        configs: [_video(0, 0), _audio(0, 1, separate: true)],
        outputDir: 'out',
        baseName: 'movie',
      );

      expect(command.outputs.length, 2);
      expect(command.outputs[0].main, isTrue);
      expect(command.outputs[0].path, p.join('out', 'movie.mp4'));
      expect(command.outputs[1].main, isFalse);
      expect(command.outputs[1].path, p.join('out', 'movie_audio.m4a'));
      expect(_tokens(command).last, command.outputs[1].tempPath);
    });

    test('指向同一路径的独立输出合并为一个文件', () {
      final shared = p.join('out', 'shared.mkv');
      final command = FfmpegArgsBuilder.buildCommand(
        sources: [FileSource(path: p.join('in', 'movie.mkv'))],
        configs: [
          _video(0, 0, separate: true, path: shared),
          _audio(0, 1, separate: true, path: shared),
        ],
        outputDir: 'out',
        baseName: 'movie',
      );

      expect(command.outputs.length, 1);
      expect(command.outputs.single.path, shared);

      final tokens = _tokens(command);
      expect(_has(tokens, ['-map', '0:0']), isTrue);
      expect(_has(tokens, ['-map', '0:1']), isTrue);
    });

    test('路径里的空格与中文不会被拆开', () {
      final source = FileSource(path: p.join('in', '我的 视频.mkv'));
      final command = FfmpegArgsBuilder.buildCommand(
        sources: [source],
        configs: [_video(0, 0, copy: true)],
        outputDir: p.join('out', '我的 输出'),
        baseName: '我的 视频',
      );

      final tokens = _tokens(command);
      expect(_has(tokens, ['-i', source.input]), isTrue);
      expect(
        _has(tokens, ['-map', '0:0', '-c:v:0', 'copy']),
        isTrue,
        reason: '命令: ${command.command}',
      );
      expect(command.outputs.single.path, p.join('out', '我的 输出', '我的 视频.mp4'));
    });

    test('自定义输出名生效', () {
      final command = FfmpegArgsBuilder.buildCommand(
        sources: [FileSource(path: p.join('in', 'movie.mkv'))],
        configs: [_video(0, 0)],
        outputDir: 'out',
        baseName: 'movie',
        outputName: '结局',
      );

      expect(command.outputs.single.path, p.join('out', '结局.mp4'));
      expect(command.outputs.single.tempPath, p.join('out', '结局.part.mp4'));
    });

    test('全部禁用时没有任何输出', () {
      final command = FfmpegArgsBuilder.buildCommand(
        sources: [FileSource(path: p.join('in', 'movie.mkv'))],
        configs: [_video(0, 0, enabled: false)],
        outputDir: 'out',
        baseName: 'movie',
      );

      expect(command.outputs, isEmpty);
    });
  });
}
