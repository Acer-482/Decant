import 'package:media_transcoder/core/enums/codec/audio_codec.dart';
import 'package:media_transcoder/core/enums/encoder_flavor.dart';

/// 音频编码器
enum AudioEncoder {
  aac(AudioCodec.aac, 'aac', flavor: .native),
  libfdkAac(AudioCodec.aac, 'libfdk_aac', flavor: .fdk),
  libmp3lame(AudioCodec.mp3, 'libmp3lame', flavor: .lame),
  libopus(AudioCodec.opus, 'libopus', flavor: .native),
  flac(AudioCodec.flac, 'flac', flavor: .native),
  libvorbis(AudioCodec.vorbis, 'libvorbis', flavor: .native),
  alac(AudioCodec.alac, 'alac', flavor: .native),
  ac3(AudioCodec.ac3, 'ac3', flavor: .native),
  eac3(AudioCodec.eac3, 'eac3', flavor: .native),
  pcmS16le(AudioCodec.pcmS16le, 'pcm_s16le', flavor: .native),
  pcmS24le(AudioCodec.pcmS24le, 'pcm_s24le', flavor: .native);

  /// 编码格式
  final AudioCodec codec;

  /// ffmpeg内名称
  final String ffmpegName;

  /// 音频变体
  final EncoderFlavor flavor;

  const AudioEncoder(this.codec, this.ffmpegName, {required this.flavor});
}
