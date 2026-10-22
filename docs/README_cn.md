<div align="center">

**语言** · [**English**](../README.md) / [**简体中文**](README_cn.md)

</div>

# Decant

> 把你的文件，优雅地“倒”进任何容器

**Decant** 是一个基于 FFmpeg 的跨平台文件转码工具

只需将文件拖进来，像 FFmpeg 那样控制每一条流，然后逐条决定它怎么处理 —— 无损封装，或者用你指定的编码器重新编码

名字取自"醒酒"（decant）：把酒从一个容器倒进另一个容器，并决定留下什么、滤掉什么

## 状态

目前是项目早期阶段，正在努力开发中。在这过程中遇到任何问题，欢迎与我联系！

| 平台 | 状态 |
| --- | --- |
| Windows | 已构建、已测试 |
| Linux / macOS | 工程骨架已生成，尚未验证 |
| iOS / Android | 工程骨架已生成，尚未验证 |
| Web | 暂不支持 |

## 目前可用的功能

- 拖拽文件，或手动选择本地媒体文件
- 查看文件信息详细信息 (媒体) ：时长、码率、容器，以及每一条流（编码格式、分辨率、帧率、采样率、声道数）
- 逐流配置：
  - 启用 / 禁用某条流
  - **复制流**（无损封装）或重新编码
  - 选择编码器 —— H.264 / HEVC / AV1 / VP9 / ProRes……以及对应的音频编码器
- 执行转码，并根据 FFmpeg 的统计回调显示实时进度
- 成功 / 失败页：失败时展示完整 FFmpeg 日志，支持重试和"打开输出目录"

## 尚未支持

- 输出容器目前固定为 `.mp4`
- 转码过程中无法取消
- 任务列表只存在内存里，重启即丢失，也还没有接入真实任务
- 界面只有中文
- 还没有测试
- 还没有预设（"简单模式"）—— 这是下一个里程碑

## 从源码构建

依赖：

- Flutter SDK（Dart `^3.13.5`）
- Windows：Visual Studio 2022，需要勾选"使用 C++ 的桌面开发"工作负载
- Linux：`clang cmake ninja-build pkg-config libgtk-3-dev`

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # 重新生成 mapper
flutter run -d windows
```

发布构建：

```bash
flutter build windows --release
```

可执行文件位于 `build/windows/x64/runner/Release/`。

## 代码结构

```
lib/
  domain/     纯模型：媒体信息、流信息/配置、编码器、任务
  features/   界面与状态，按功能划分（fast_transcode、task_list……）
  shared/     小型组件与格式化工具
  devtools/   直接摆弄 FFmpeg 的临时页面
```

数据流被刻意设计成单向的：

```
媒体文件 → MediaInfo（ffprobe） → List<StreamConfig> → FfmpegArgsBuilder → FFmpegKit
```

## 未完待续的功能 & 路线图

- [ ] 取消 / 暂停正在运行的任务
- [ ] 添加预设功能（"发微信"、"存档"、"剪辑代理"）
- [ ] 图片转码
- [ ] 支持多文件流处理
- [ ] 完善任务列表功能，支持批量队列
- [ ] i18国际化支持

## 许可证

[GPL-3.0](../LICENSE)。
