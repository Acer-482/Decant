/// 可用编码器
class AvailableEncoder {
  /// 编码器名称
  final String name;

  /// 编码器类型
  final String type;

  /// 编码器描述
  final String description;

  const AvailableEncoder({
    required this.name,
    required this.type,
    required this.description,
  });
}

/// 解析解码器
List<AvailableEncoder> parseEncoders(String output) {
  final encoders = <AvailableEncoder>[]; // 编码器
  final lineRegex = RegExp(r'^\s*([VAS])[.\w]{5}\s+(\S+)\s+(.*)$'); // 正则
  int status = 0; // 状态
  for (final String rawLine in output.split('\n')) {
    final line = rawLine.trim(); // 清理行前后空格
    if (line.startsWith('Encoders:')) {
      // 从编码器后开始
      status = 1;
    } else if (status == 1 && line.startsWith('------')) {
      // 隔离示例
      status = 2;
    } else if (status == 2) {
      final match = lineRegex.firstMatch(rawLine); // 正则匹配
      if (match != null) {
        encoders.add(
          AvailableEncoder(
            type: match.group(1)!, // 类型：V / A / S
            name: match.group(2)!, // 编码器名称：libx264 / aac
            description: match.group(3)!.trim(), // 描述
          ),
        );
      }
    }
  }
  return encoders;
}
