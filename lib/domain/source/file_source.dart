import 'package:dart_mappable/dart_mappable.dart';
import 'package:decant/domain/source/base_source.dart';

part 'file_source.mapper.dart';

/// 本地文件源
@MappableClass(discriminatorValue: 'file')
class FileSource extends BaseSource with FileSourceMappable {
  /// 文件路径
  final String path;

  const FileSource({required this.path});

  @override
  String get input => path;
}
