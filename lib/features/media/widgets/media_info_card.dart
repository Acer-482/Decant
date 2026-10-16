import 'package:ffmpeg_kit_flutter_new/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter_new/media_information.dart';
import 'package:flutter/material.dart';
import 'package:media_transcoder/domain/media/media_source/local_media_file_source.dart';
import 'package:media_transcoder/domain/media/media_source/media_source.dart';
import 'package:media_transcoder/shared/utils/file_utils.dart';
import 'package:media_transcoder/shared/utils/media_format_utils.dart';

/// 媒体信息卡
class MediaInfoCard extends StatefulWidget {
  /// 媒体源
  final MediaSource source;

  const MediaInfoCard(this.source, {super.key});

  @override
  State<StatefulWidget> createState() => _MediaInfoCardState();
}

class _MediaInfoCardState extends State<MediaInfoCard> {
  /// 媒体信息 Future
  late Future<MediaInformation?> _future;

  /// 媒体信息
  MediaInformation? mediaInfo;

  @override
  void initState() {
    super.initState();
    _future = _getMediaInfo();
  }

  /// 解析来源
  String? _parseSource() {
    final source = widget.source; // 媒体源
    final String path; // 路径
    if (source is LocalMediaFileSource) {
      path = source.path;
    } else {
      return null;
    }
    return path;
  }

  /// 获取媒体信息
  Future<MediaInformation?> _getMediaInfo() async {
    final path = _parseSource();
    if (path == null) {
      throw Exception('不支持的媒体源');
    }

    // 获取媒体源
    final session = await FFprobeKit.getMediaInformation(path);
    final returnCode = await session.getReturnCode();

    // 无返回值
    if (returnCode == null) {
      throw Exception('无返回值');
    }

    // 值是否有效
    if (returnCode.isValueSuccess()) {
      final info = session.getMediaInformation();
      if (info == null) throw Exception('解析失败'); // 确认方法是否正确返回值
      return info;
    }
    return null;
  }

  /// 构建媒体信息
  Widget _buildMediaInfoContent(MediaInformation mediaInfo) {
    return Column(
      crossAxisAlignment: .center,
      mainAxisSize: .min,
      children: [
        ListTile(
          dense: true,
          title: Text('时长'),
          subtitle: SelectableText(
            MediaFormatUtils.duration(mediaInfo.getDuration()),
          ),
        ),
        ListTile(
          dense: true,
          title: Text('大小'),
          subtitle: SelectableText(FileUtils.fileSizeStr(mediaInfo.getSize())),
        ),
        ListTile(
          dense: true,
          title: Text('码率'),
          subtitle: SelectableText(
            MediaFormatUtils.bitRate(mediaInfo.getBitrate()),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: .all(4),
        child: Column(
          children: [
            FutureBuilder(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == .waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      '加载失败\n${snapshot.error}',
                      textAlign: .center,
                      style: TextStyle(fontSize: 40),
                    ),
                  );
                }

                if (!snapshot.hasData || mediaInfo == null) {
                  return const Center(
                    child: Text('无数据', style: TextStyle(fontSize: 40)),
                  );
                }

                return _buildMediaInfoContent(mediaInfo!);
              },
            ),
          ],
        ),
      ),
    );
  }
}
