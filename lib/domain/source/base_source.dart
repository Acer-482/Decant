import 'package:dart_mappable/dart_mappable.dart';

part 'base_source.mapper.dart';

/// 基本源
///
/// 作为输入数据源的基类
@MappableClass(discriminatorKey: 'kind')
abstract class BaseSource with BaseSourceMappable {
  const BaseSource();
}
