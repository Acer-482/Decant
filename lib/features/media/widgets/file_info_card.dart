import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:media_transcoder/shared/widgets/info_row.dart';
import 'package:media_transcoder/shared/widgets/title_card.dart';
import 'package:media_transcoder/shared/utils/file_utils.dart';

/// 文件信息组件
class FileInfoCard extends StatelessWidget {
  final String path;

  const FileInfoCard({super.key, required this.path});

  @override
  Widget build(BuildContext context) {
    final file = File(path);
    final infoList = [
      _FileInfoItem('名称', FileUtils.baseName(path)),
      _FileInfoItem('类型', FileUtils.fileExtension(path)),
      _FileInfoItem('大小', FileUtils.fileSize(file.lengthSync())),
      _FileInfoItem(
        '修改时间',
        DateFormat('yyyy-MM-dd HH:mm').format(file.lastModifiedSync()),
      ),
      _FileInfoItem('源路径', path),
    ];
    return TitleCard(
      icon: const Icon(Icons.book),
      title: Text('文件信息'),
      child: Column(
        spacing: 8,
        children: infoList
            .map((i) => InfoRow(title: i.name, info: i.info))
            .toList(),
      ),
    );
  }
}

class _FileInfoItem {
  /// 名称
  final String name;

  /// 信息
  final String info;

  const _FileInfoItem(this.name, this.info);
}
