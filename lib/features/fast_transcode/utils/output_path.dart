import 'package:path/path.dart' as p;
import 'package:decant/domain/source/base_source.dart';

/// 默认输出路径
///
/// 与第一个输入同目录，文件名加 `_transcoded` 后缀。
String defaultOutputPath(List<BaseSource> sources) {
  final first = sources.first.input;
  final dir = p.dirname(first);
  final name = p.basenameWithoutExtension(first);
  return p.join(dir, '${name}_transcoded.mp4');
}
