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
| Windows | 已构建、已测试，主要目标平台 |
| Linux | 源码可构建；CI 构建尚未通过 |
| macOS | 源码可构建；CI 构建尚未通过 |
| Android | CI 产出 debug APK，尚未人工验证 |
| iOS | CI 产出未签名包，仅存档、无法安装 |
| Web | 暂不支持 —— FFmpegKit 没有 web 后端 |

## 目前可用的功能

- 拖拽文件，或手动选择本地媒体文件
- **多路输入**：把多个文件的流合并到一个输出里
- 用 `ffprobe` 查看每一条流：编码格式、分辨率、帧率、采样率、声道数、码率。文件和媒体详情在选择页与设置页都能一键查看
- 逐流配置：
  - 启用 / 禁用某条流
  - **复制流**（无损封装）或重新编码
  - 选择编码器 —— H.264 / HEVC / AV1 / VP9 / ProRes / DNxHD / FFV1 / MPEG-4……包含硬件编码器，以及对应的音频编码器
  - 把某条流单独输出到指定路径
- 输出：选择目录、重命名主文件；容器后缀按所选编码自动推导
- 执行转码，实时显示进度，并可在转码过程中**取消**
- 成功 / 失败 / 已取消页：失败时展示完整 FFmpeg 日志，可重试，也可带着已有的逐流配置返回设置页
- 先写 `.part` 临时文件，中断时不会留下一个"看起来正常"的残片
- 设置页：主题模式与主题色、默认输出目录、完成后自动打开输出文件夹、一键重置全部设置

## 尚未支持

- 任务列表只存在内存里，重启即丢失，也还没有接入真实任务
- 界面只有中文
- 还没有预设（"简单模式"）—— 这是下一个里程碑
- 不支持图片转码
- 同一时间只跑一个任务，没有批量队列
- 没有安装包和代码签名 —— 发布产物是压缩包
- 硬件编码器可以逐流选择，但还没有"优先使用硬件"的默认项

## 从源码构建

依赖：

- Flutter SDK（Dart `^3.13.5`）
- Windows：Visual Studio 2022，需要勾选"使用 C++ 的桌面开发"工作负载
- Linux：`clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev libjson-glib-dev`
- macOS / iOS：Xcode，使用 Swift Package Manager（两个工程都已改用 SPM，不再走 CocoaPods）

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # 重新生成 mapper
flutter run -d windows
```

测试：

```bash
flutter test
```

发布构建：

```bash
flutter build windows --release
```

可执行文件位于 `build/windows/x64/runner/Release/`。

打 tag 触发的发布构建由 GitHub Actions 完成，产物与发版流程见 [RELEASING.md](RELEASING.md)。

## 代码结构

```
lib/
  domain/     纯模型：媒体信息、流信息/配置、编码器、任务
  features/   界面与状态，按功能划分（fast_transcode、settings、task_list、welcome、home）
  shared/     小型组件、格式化工具、首选项服务与应用常量
  devtools/   直接摆弄 FFmpeg 的临时页面
```

数据流被刻意设计成单向的：

```
媒体文件 → MediaInfo（ffprobe） → List<StreamConfig> → FfmpegArgsBuilder → FFmpegKit
```

首选项放在数据流之外：转码管线保持纯粹，由页面读取设置来决定默认值（输出目录、主题、是否自动打开目录）。

## 未完待续的功能 & 路线图

- [ ] 添加预设功能（"发微信"、"存档"、"剪辑代理"）
- [ ] 图片转码
- [ ] 完善任务列表功能，支持批量队列
- [ ] i18n 国际化支持
- [ ] "优先使用硬件编码"的默认项
- [ ] 安装包与代码签名

## 许可证

[GPL-3.0](../LICENSE)。
