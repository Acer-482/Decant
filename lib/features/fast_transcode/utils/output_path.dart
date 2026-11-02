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

/// 解析输出目录
///
/// 依次使用：本次会话里选的目录 → 设置里的默认目录 → 源文件所在目录
String resolveOutputDir(
  List<BaseSource> sources, {
  String? sessionDir,
  String? configuredDir,
}) {
  if (sessionDir != null && sessionDir.isNotEmpty) return sessionDir;
  if (configuredDir != null && configuredDir.isNotEmpty) return configuredDir;
  return defaultOutputDir(sources);
}