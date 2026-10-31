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
}
