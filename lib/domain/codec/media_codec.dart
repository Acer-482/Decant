/// 媒体编码接口
abstract interface class MediaCodec {
  /// FFprobe 名称
  ///
  /// 传入获取到的 codec_name 参数
  String get ffprobeName;

  /// 通用名
  ///
  /// 仅包含标准的名称
  String get displayName;
}
