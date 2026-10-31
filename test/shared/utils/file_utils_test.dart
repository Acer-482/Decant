import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:decant/shared/utils/file_utils.dart';

void main() {
  group('fileSize', () {
    test('小于 1KB 用字节', () {
      expect(FileUtils.fileSize(512), '512 B');
    });

    test('按 1024 进制换算', () {
      expect(FileUtils.fileSize(1024), '1.0 KB');
      expect(FileUtils.fileSize(1536), '1.5 KB');
      expect(FileUtils.fileSize(1024 * 1024), '1.0 MB');
      expect(FileUtils.fileSize(1293942784), '1.2 GB');
    });

    test('0 与负数算未知', () {
      expect(FileUtils.fileSize(0), '未知');
      expect(FileUtils.fileSize(-1), '未知');
    });

    test('字符串入口', () {
      expect(FileUtils.fileSizeStr('2048'), '2.0 KB');
      expect(FileUtils.fileSizeStr(null), '未知');
      expect(FileUtils.fileSizeStr('abc'), '未知');
    });
  });

  group('文件名', () {
    final path = p.join('C:', 'Users', 'a', 'video.mp4');

    test('fileName 去掉目录与后缀', () {
      expect(FileUtils.fileName(path), 'video');
      expect(FileUtils.fileName(null), '未知');
      expect(FileUtils.fileName(''), '未知');
    });

    test('fileExtension 只要后缀', () {
      expect(FileUtils.fileExtension('archive.tar.gz'), 'gz');
      expect(FileUtils.fileExtension('no_extension'), '');
      expect(FileUtils.fileExtension(null), '');
    });

    test('baseName 保留后缀', () {
      expect(FileUtils.baseName(path), 'video.mp4');
      expect(FileUtils.baseName(null), '未知');
    });
  });
}
