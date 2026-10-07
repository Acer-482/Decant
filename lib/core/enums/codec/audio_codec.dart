/// 音频编码格式
enum AudioCodec {
  aac('aac', 'AAC'),
  mp3('mp3', 'MP3'),
  opus('opus', 'Opus'),
  vorbis('vorbis', 'Vorbis'),
  flac('flac', 'FLAC'),
  alac('alac', 'ALAC'),
  ac3('ac3', 'AC-3'),
  eac3('eac3', 'E-AC-3'),
  dts('dts', 'DTS'),
  pcmS16le('pcm_s16le', 'PCM 16bit'),
  pcmS24le('pcm_s24le', 'PCM 24bit');

  /// FFprobe名称
  final String ffprobeName;

  /// 显示名称
  final String displayName;

  const AudioCodec(this.ffprobeName, this.displayName);
}
