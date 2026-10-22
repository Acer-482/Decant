import 'package:dart_mappable/dart_mappable.dart';
import 'package:decant/domain/encoder/media_encoder.dart';
import 'package:decant/domain/encoder/encoder_platform.dart';
import 'package:decant/domain/encoder/encoder_type.dart';
import 'package:decant/domain/codec/video_codec.dart';

part 'video_encoder.mapper.dart';

/// 媒体解码器
@MappableEnum()
enum VideoEncoder implements MediaEncoder {
  // H.264 //
  libx264(VideoCodec.h264, 'libx264', type: .software),
  h264Nvenc(
    VideoCodec.h264,
    'h264_nvenc',
    type: .hardware,
    platforms: [.nvidia],
  ),
  h264Qsv(VideoCodec.h264, 'h264_qsv', type: .hardware, platforms: [.intel]),
  h264Amf(VideoCodec.h264, 'h264_amf', type: .hardware, platforms: [.amd]),
  h264Videotoolbox(
    VideoCodec.h264,
    'h264_videotoolbox',
    type: .hardware,
    platforms: [.apple],
  ),
  h264Vaapi(
    VideoCodec.h264,
    'h264_vaapi',
    type: .hardware,
    platforms: [.linux],
  ),
  h264Mediacodec(
    VideoCodec.h264,
    'h264_mediacodec',
    type: .hardware,
    platforms: [.android],
  ),

  // H.265 / HEVC //
  libx265(VideoCodec.hevc, 'libx265', type: .software),
  hevcNvenc(
    VideoCodec.hevc,
    'hevc_nvenc',
    type: .hardware,
    platforms: [.nvidia],
  ),
  hevcQsv(VideoCodec.hevc, 'hevc_qsv', type: .hardware, platforms: [.intel]),
  hevcAmf(VideoCodec.hevc, 'hevc_amf', type: .hardware, platforms: [.amd]),
  hevcVideotoolbox(
    VideoCodec.hevc,
    'hevc_videotoolbox',
    type: .hardware,
    platforms: [.apple],
  ),
  hevcVaapi(
    VideoCodec.hevc,
    'hevc_vaapi',
    type: .hardware,
    platforms: [.linux],
  ),

  // AV1 //
  libsvtav1(VideoCodec.av1, 'libsvtav1', type: .software),
  libaomAv1(VideoCodec.av1, 'libaom-av1', type: .software),
  av1Nvenc(VideoCodec.av1, 'av1_nvenc', type: .hardware, platforms: [.nvidia]),

  // VP9 / VP8 //
  libvpxVp9(VideoCodec.vp9, 'libvpx-vp9', type: .software),
  libvpx(VideoCodec.vp8, 'libvpx', type: .software),

  // 其他 //
  mpeg4(VideoCodec.mpeg4, 'mpeg4', type: .software),
  mpeg2video(VideoCodec.mpeg2, 'mpeg2video', type: .software),
  proresKs(VideoCodec.prores, 'prores_ks', type: .software),
  dnxhd(VideoCodec.dnxhd, 'dnxhd', type: .software),
  ffv1(VideoCodec.ffv1, 'ffv1', type: .software);

  /// 编码格式
  final VideoCodec codec;

  /// FFmpeg内编码器名称
  @override
  final String ffmpegName;

  /// 类型 (软件/硬件)
  final EncoderType type;

  /// 平台
  final List<EncoderPlatform> platforms;

  const VideoEncoder(
    this.codec,
    this.ffmpegName, {
    required this.type,
    this.platforms = const [],
  });
}
