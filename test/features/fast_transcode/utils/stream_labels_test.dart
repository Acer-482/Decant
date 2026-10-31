import 'package:flutter_test/flutter_test.dart';
import 'package:decant/domain/media/media_info.dart';
import 'package:decant/domain/media/stream_info/audio_stream_info.dart';
import 'package:decant/domain/media/stream_info/unknown_stream_info.dart';
import 'package:decant/domain/media/stream_info/video_stream_info.dart';
import 'package:decant/features/fast_transcode/utils/stream_labels.dart';

const _video = VideoStreamInfo(
  index: 0,
  codecName: 'h264',
  width: 1920,
  height: 1080,
  pixFmt: 'yuv420p',
  frameRate: '25/1',
);

const _audio = AudioStreamInfo(
  index: 1,
  codecName: 'aac',
  sampleRate: 44100,
  channels: 2,
  channelLayout: 'stereo',
);

void main() {
  test('流标题按类型与序号生成', () {
    expect(streamTitle(_video), '视频流 #0');
    expect(streamTitle(_audio), '音频流 #1');
    expect(
      streamTitle(
        const UnknownStreamInfo(index: 2, codecName: 'pgs', codecType: 'subtitle'),
      ),
      '未知流 #2',
    );
  });

  test('编码信息带分辨率与帧率', () {
    expect(codecInfo(_video), 'H.264 · 1920×1080 · 25 fps');
    expect(codecInfo(_audio), 'AAC · 44.1 kHz');
  });

  test('未知编码显示大写原文', () {
    expect(codecName('h264'), 'H.264');
    expect(codecName('weird'), 'WEIRD');
  });

  test('媒体摘要包含时长、分辨率与流数', () {
    const info = MediaInfo(
      duration: '180',
      size: '100',
      bitrate: '1000',
      streams: [_video, _audio],
    );

    expect(mediaSummary(info), '03:00 · 1920×1080 · 2 条流');
  });

  test('没有视频流时摘要不显示分辨率', () {
    const info = MediaInfo(
      duration: '60',
      size: '100',
      bitrate: '1000',
      streams: [_audio],
    );

    expect(mediaSummary(info), '01:00 · 1 条流');
  });
}
