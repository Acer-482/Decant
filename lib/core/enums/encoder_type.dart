/// 编码器类型
enum EncoderType { software, hardware }

extension EncoderTypeDisplay on EncoderType {
  /// 显示名称
  String get displayName => switch (this) {
    .software => '软件',
    .hardware => '硬件',
  };
}
