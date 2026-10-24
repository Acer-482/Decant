import 'package:dart_mappable/dart_mappable.dart';

part 'base_source.mapper.dart';

/// 基础源
///
/// 一路输入就是一个源：本地文件、网络地址、设备……
/// 具体形态由子类决定，转码流程只依赖这个抽象。
@MappableClass(discriminatorKey: 'kind')
abstract class BaseSource with BaseSourceMappable {
  const BaseSource();

  /// 输入标识
  ///
  /// 本地文件为路径;
  /// 网络源为 URL;
  /// 设备源为设备名
  String get input;
}
