import 'package:flutter_test/flutter_test.dart';
import 'package:decant/shared/utils/media_format_utils.dart';

void main() {
  group('duration', () {
    test('不足一小时只显示分秒', () {
      expect(MediaFormatUtils.duration('180.00'), '03:00');
    });

    test('超过一小时显示时分秒', () {
      expect(MediaFormatUtils.duration('3661'), '01:01:01');
    });

    test('小数秒向下取整', () {
      expect(MediaFormatUtils.duration('59.9'), '00:59');
    });

    test('空值与非法值都算未知', () {
      expect(MediaFormatUtils.duration(null), '未知');
      expect(MediaFormatUtils.duration('abc'), '未知');
      expect(MediaFormatUtils.duration('0'), '未知');
      expect(MediaFormatUtils.duration('-5'), '未知');
    });
  });

  group('bitRate', () {
    test('百万级以上用 Mbps', () {
      expect(MediaFormatUtils.bitRate('10537321'), '10.5 Mbps');
      expect(MediaFormatUtils.bitRate('1536000'), '1.5 Mbps');
    });

    test('千级用 kbps', () {
      expect(MediaFormatUtils.bitRate('128000'), '128 kbps');
    });

    test('千以下用 bps', () {
      expect(MediaFormatUtils.bitRate('999'), '999 bps');
    });

    test('空值与非法值都算未知', () {
      expect(MediaFormatUtils.bitRate(null), '未知');
      expect(MediaFormatUtils.bitRate(''), '未知');
      expect(MediaFormatUtils.bitRate('0'), '未知');
    });
  });

  group('frameRate', () {
    test('整除时只显示整数', () {
      expect(MediaFormatUtils.frameRate('25/1'), '25 fps');
    });

    test('除不尽时保留两位', () {
      expect(MediaFormatUtils.frameRate('30000/1001'), '29.97 fps');
    });

    test('0/0 算未知', () {
      expect(MediaFormatUtils.frameRate('0/0'), '未知');
    });

    test('缺省值原样返回', () {
      expect(MediaFormatUtils.frameRate('25'), '25');
      expect(MediaFormatUtils.frameRate(null), '未知');
    });
  });

  group('sampleRate', () {
    test('千级以上用 kHz', () {
      expect(MediaFormatUtils.sampleRate('44100'), '44.1 kHz');
      expect(MediaFormatUtils.sampleRate('48000'), '48.0 kHz');
    });

    test('千以下用 Hz', () {
      expect(MediaFormatUtils.sampleRate('800'), '800 Hz');
    });

    test('空值算未知', () {
      expect(MediaFormatUtils.sampleRate(null), '未知');
    });
  });

  group('channelLayout', () {
    test('常见布局翻译成中文', () {
      expect(MediaFormatUtils.channelLayout('mono', 1), '单声道');
      expect(MediaFormatUtils.channelLayout('stereo', 2), '立体声');
      expect(MediaFormatUtils.channelLayout('5.1', 6), '5.1 环绕');
      expect(MediaFormatUtils.channelLayout('7.1', 8), '7.1 环绕');
    });

    test('未知布局退回声道数', () {
      expect(MediaFormatUtils.channelLayout('quad', 4), '4 声道');
    });

    test('布局与声道数都没有时算未知', () {
      expect(MediaFormatUtils.channelLayout(null, null), '未知');
    });
  });
}
