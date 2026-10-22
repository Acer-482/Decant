import 'package:dart_mappable/dart_mappable.dart';
import 'package:decant/domain/media/media_source/media_source.dart';

part 'local_media_file_source.mapper.dart';

/// 本地媒体文件源
@MappableClass(discriminatorValue: 'file')
class LocalMediaFileSource extends MediaSource
    with LocalMediaFileSourceMappable {
  /// 文件路径
  final String path;

  const LocalMediaFileSource({required this.path});
}
