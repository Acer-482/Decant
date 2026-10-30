import 'package:path/path.dart' as p;
import 'package:decant/domain/source/base_source.dart';

/// 默认输出目录
///
/// 第一个源所在目录
String defaultOutputDir(List<BaseSource> sources) {
  return p.dirname(sources.first.input);
}

/// 默认输出基础名
///
/// 第一个源的文件名，不含后缀
String defaultBaseName(List<BaseSource> sources) {
  return p.basenameWithoutExtension(sources.first.input);
}
