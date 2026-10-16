/// 媒体格式化工具类
class MediaFormatUtils {
  MediaFormatUtils._();

  /// 时长转换
  ///
  /// 例："180.00" → "03:00"
  static String duration(String? seconds) {
    final total = double.tryParse(seconds ?? '') ?? 0;
    if (total <= 0) return '未知';
    final d = Duration(seconds: total.floor());
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return h == '00' ? '$m:$s' : '$h:$m:$s';
  }

  /// 码率转换
  ///
  /// 例："10537321" → "10.5 Mbps"
  static String bitRate(String? bps) {
    final value = int.tryParse(bps ?? '') ?? 0;
    if (value <= 0) return '未知';
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)} Mbps';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(0)} kbps';
    return '$value bps';
  }

  /// 帧率分数
  ///
  /// 例："25/1" → "25 fps"
  static String frameRate(String? raw) {
    if (raw == null || raw == '0/0') return '未知';
    final parts = raw.split('/');
    if (parts.length != 2) return raw;
    final num = double.tryParse(parts[0]) ?? 0;
    final den = double.tryParse(parts[1]) ?? 1;
    if (den == 0) return '未知';
    final fps = num / den;
    return '${fps.toStringAsFixed(fps.truncateToDouble() == fps ? 0 : 2)} fps';
  }

  /// 采样率转换
  ///
  /// 例："44500" → "44.5 kHz"
  static String sampleRate(String? hz) {
    final value = int.tryParse(hz ?? '') ?? 0;
    if (value <= 0) return '未知';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)} kHz';
    return '$value Hz';
  }
}
