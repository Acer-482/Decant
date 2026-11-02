import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:decant/domain/source/file_source.dart';
import 'package:decant/features/fast_transcode/utils/output_path.dart';

void main() {
  final sources = [
    FileSource(path: p.join('media', 'a.mkv')),
    FileSource(path: p.join('other', 'b.mp4')),
  ];

  test('默认输出目录取第一个源所在目录', () {
    expect(defaultOutputDir(sources), 'media');
  });

  test('默认基础名取第一个源的文件名', () {
    expect(defaultBaseName(sources), 'a');
  });

  test('只有一个源时同样取该源', () {
    final single = [FileSource(path: p.join('media', 'movie.mkv'))];

    expect(defaultOutputDir(single), 'media');
    expect(defaultBaseName(single), 'movie');
  });

  group('resolveOutputDir', () {
    test('本次会话选的目录优先级最高', () {
      expect(
        resolveOutputDir(
          sources,
          sessionDir: p.join('session'),
          configuredDir: p.join('configured'),
        ),
        p.join('session'),
      );
    });

    test('没有会话目录时用设置里的默认目录', () {
      expect(
        resolveOutputDir(sources, configuredDir: p.join('configured')),
        p.join('configured'),
      );
    });

    test('两者都为空时跟随源文件目录', () {
      expect(resolveOutputDir(sources), 'media');
    });

    test('空字符串视为未设置', () {
      expect(
        resolveOutputDir(sources, sessionDir: '', configuredDir: ''),
        'media',
      );
    });
  });
}
