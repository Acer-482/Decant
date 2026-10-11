import 'package:dart_mappable/dart_mappable.dart';

part 'media_source.mapper.dart';

/// 媒体源
@MappableClass(discriminatorKey: 'kind')
abstract class MediaSource with MediaSourceMappable {
  const MediaSource();
}
