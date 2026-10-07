/// 编码器平台
enum EncoderPlatform { android, linux, apple, intel, amd, nvidia }

extension EncoderPlatformDisplay on EncoderPlatform {
  /// 显示名称
  String get displayName => switch (this) {
    .android => 'Android',
    .linux => 'Linux',
    .apple => 'Apple',
    .intel => 'Intel',
    .amd => 'AMD',
    .nvidia => 'NVIDIA',
  };
}
