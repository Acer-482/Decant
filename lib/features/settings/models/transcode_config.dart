/// 转码首选项
class TranscodeConfig {
  /// 默认输出目录
  ///
  /// 为空时跟随源文件所在目录
  final String? defaultOutputDir;

  /// 完成后自动打开输出文件夹
  final bool autoOpenOutput;

  const TranscodeConfig({this.defaultOutputDir, this.autoOpenOutput = true});

  /// 默认值
  static const TranscodeConfig defaults = TranscodeConfig();

  /// 复制
  TranscodeConfig copyWith({
    String? defaultOutputDir,
    bool? autoOpenOutput,
    bool clearDefaultOutputDir = false,
  }) {
    return TranscodeConfig(
      defaultOutputDir: clearDefaultOutputDir
          ? null
          : (defaultOutputDir ?? this.defaultOutputDir),
      autoOpenOutput: autoOpenOutput ?? this.autoOpenOutput,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is TranscodeConfig &&
      other.defaultOutputDir == defaultOutputDir &&
      other.autoOpenOutput == autoOpenOutput;

  @override
  int get hashCode => Object.hash(defaultOutputDir, autoOpenOutput);
}
