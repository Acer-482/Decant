import 'package:decant/domain/codec/media_codec.dart';

/// 媒体编码格式
enum VideoCodec implements MediaCodec {
  h264('h264', 'H.264'),
  hevc('hevc', 'H.265'),
  av1('av1', 'AV1'),
  vp9('vp9', 'VP9'),
  vp8('vp8', 'VP8'),
  mpeg4('mpeg4', 'MPEG-4'),
  mpeg2('mpeg2video', 'MPEG-2'),
  prores('prores', 'ProRes'),
  dnxhd('dnxhd', 'DNxHD'),
  ffv1('ffv1', 'FFV1');

  @override
  final String ffprobeName;

  @override
  final String displayName;

  const VideoCodec(this.ffprobeName, this.displayName);
}
