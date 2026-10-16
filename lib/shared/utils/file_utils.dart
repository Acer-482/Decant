import 'package:path/path.dart' as p;

/// 文件格式化工具类
class FileUtils {
  FileUtils._();

  /// 大小转换
  ///
  /// 例："1293942784" → "1234.0 MB"
  static String fileSizeStr(String? bytes) {
    return fileSize(int.tryParse(bytes ?? '') ?? 0);
  }

  /// 大小转换
  ///
  /// 例："1293942784" → "1234.0 MB"
  static String fileSize(int bytes) {
    if (bytes <= 0) return '未知';
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    var size = bytes.toDouble();
    var i = 0;
    while (size >= 1024 && i < units.length - 1) {
      size /= 1024;
      i++;
    }
    return '${size.toStringAsFixed(i == 0 ? 0 : 1)} ${units[i]}';
  }

  /// 获取纯文件名
  ///
  /// 不含路径、不含后缀
  ///
  /// 例：
  /// - "C:\Users\a\video.mp4"      → "video"
  /// - "/home/user/archive.tar.gz" → "archive.tar"
  /// - "no_extension"              → "no_extension"
  static String fileName(String? path) {
    if (path == null || path.isEmpty) return '未知';
    return p.basenameWithoutExtension(path);
  }

  /// 获取文件后缀
  ///
  /// 后缀不含点
  ///
  /// 例：
  /// - "video.mp4"          → "mp4"
  /// - "archive.tar.gz"     → "gz"
  /// - "no_extension"       → ""  （无后缀）
  static String fileExtension(String? path) {
    if (path == null || path.isEmpty) return '';
    return p.extension(path).replaceFirst('.', '');
  }

  /// 获取完整文件名
  ///
  /// 例："C:\Users\a\video.mp4" → "video.mp4"
  static String baseName(String? path) {
    if (path == null || path.isEmpty) return '未知';
    return p.basename(path);
  }
}
