import 'package:decant/domain/encoder/audio_encoder.dart';
import 'package:decant/domain/encoder/video_encoder.dart';
import 'package:decant/domain/media/stream_config/audio_stream_config.dart';
import 'package:decant/domain/media/stream_config/stream_config.dart';
import 'package:decant/domain/media/stream_config/unknown_stream_config.dart';
import 'package:decant/domain/media/stream_config/video_stream_config.dart';
import 'package:decant/domain/media/stream_info/audio_stream_info.dart';
import 'package:decant/domain/media/stream_info/base_stream_info.dart';
import 'package:decant/domain/media/stream_info/video_stream_info.dart';

/// 为一条流生成默认配置
StreamConfig defaultStreamConfig(BaseStreamInfo stream, int inputIndex) {
  if (stream is VideoStreamInfo) {
    return VideoStreamConfig(
      inputIndex: inputIndex,
      streamIndex: stream.index,
      encoder: VideoEncoder.values.firstWhere(
        (encoder) =>
            encoder.codec.ffprobeName == stream.codecName && // 默认编码器
            encoder.type == .software, // 软件
        orElse: () => .libx264, // 兜底使用软件编码
      ),
    );
  }

  if (stream is AudioStreamInfo) {
    return AudioStreamConfig(
      inputIndex: inputIndex,
      streamIndex: stream.index,
      encoder: AudioEncoder.values.firstWhere(
        (encoder) => encoder.codec.ffprobeName == stream.codecName,
        orElse: () => .aac, // 兜底使用通用格式
      ),
    );
  }

  return UnknownStreamConfig(
    inputIndex: inputIndex,
    streamIndex: stream.index,
  );
}
