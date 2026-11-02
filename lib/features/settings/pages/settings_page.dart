import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:decant/features/settings/enums/theme_mode_option.dart';
import 'package:decant/features/settings/models/theme_config.dart';
import 'package:decant/features/settings/providers/theme_preferences.dart';
import 'package:decant/features/settings/providers/transcode_preferences.dart';
import 'package:decant/shared/constants/app_info.dart';
import 'package:decant/shared/services/preferences_service.dart';
import 'package:decant/shared/widgets/path_text.dart';
import 'package:decant/shared/widgets/title_card.dart';

/// 设置页面
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720), // 宽屏下保持可读宽度
          child: const Column(
            spacing: 10,
            children: [
              _AppearanceSection(),
              _TranscodeSection(),
              _AboutSection(),
            ],
          ),
        ),
      ),
    );
  }
}

/// 外观
class _AppearanceSection extends ConsumerWidget {
  const _AppearanceSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final config = ref.watch(themeConfigProvider);
    final notifier = ref.read(themePreferencesProvider.notifier);

    return TitleCard(
      icon: const Icon(Icons.palette_outlined),
      title: const Text('外观'),
      child: Column(
        crossAxisAlignment: .stretch,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.brightness_6_outlined),
            title: const Text('主题模式'),
            trailing: DropdownButton<ThemeModeOption>(
              value: config.mode,
              underline: const SizedBox.shrink(),
              borderRadius: .circular(10),
              items: [
                for (final mode in ThemeModeOption.values)
                  DropdownMenuItem(value: mode, child: Text(mode.displayName)),
              ],
              onChanged: (mode) {
                if (mode == null) return;
                notifier.setMode(mode);
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Row(
              children: [
                Icon(
                  Icons.color_lens_outlined,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 16),
                const Text('主题色'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 40, bottom: 4),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final color in ThemeConfig.seedColors)
                  _SeedColorDot(
                    key: ValueKey(color.toARGB32()),
                    color: color,
                    selected: color.toARGB32() == config.seedColor.toARGB32(),
                    onTap: () => notifier.setSeedColor(color),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 主题色圆点
class _SeedColorDot extends StatelessWidget {
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _SeedColorDot({
    super.key,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dark = ThemeData.estimateBrightnessForColor(color) == .dark;

    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          shape: .circle,
          color: color,
          border: Border.all(
            color: selected ? scheme.onSurface : scheme.outlineVariant,
            width: selected ? 2 : 1,
          ),
        ),
        child: selected
            ? Icon(
                Icons.check,
                size: 16,
                color: dark ? Colors.white : Colors.black,
              )
            : null,
      ),
    );
  }
}

/// 转码
class _TranscodeSection extends ConsumerWidget {
  const _TranscodeSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final config = ref.watch(transcodeConfigProvider);
    final notifier = ref.read(transcodePreferencesProvider.notifier);
    final dir = config.defaultOutputDir;

    return TitleCard(
      icon: const Icon(Icons.tune),
      title: const Text('转码'),
      child: Column(
        crossAxisAlignment: .stretch,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.folder_outlined),
            title: const Text('默认输出目录'),
            subtitle: dir == null
                ? const Text('跟随源文件所在目录')
                : PathText(dir, style: theme.textTheme.bodySmall),
            trailing: Row(
              mainAxisSize: .min,
              children: [
                if (dir != null)
                  IconButton(
                    tooltip: '恢复跟随源文件',
                    onPressed: () => notifier.setDefaultOutputDir(null),
                    icon: const Icon(Icons.restart_alt),
                  ),
                TextButton(
                  onPressed: () => _pickDirectory(notifier),
                  child: const Text('更改'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(Icons.open_in_new),
            title: const Text('完成后自动打开输出文件夹'),
            subtitle: const Text('转码结束时直接打开文件所在目录'),
            value: config.autoOpenOutput,
            onChanged: notifier.setAutoOpenOutput,
          ),
        ],
      ),
    );
  }

  /// 选择默认输出目录
  Future<void> _pickDirectory(TranscodePreferencesNotifier notifier) async {
    final dir = await getDirectoryPath();
    if (dir == null) return; // 用户取消
    await notifier.setDefaultOutputDir(dir);
  }
}

/// 关于
class _AboutSection extends ConsumerWidget {
  const _AboutSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;

    return TitleCard(
      icon: const Icon(Icons.info_outline),
      title: const Text('关于'),
      child: Column(
        crossAxisAlignment: .stretch,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.wine_bar_rounded),
            title: const Text(AppInfo.name),
            subtitle: Text('v${AppInfo.version} · ${AppInfo.license}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showAbout(context),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.code),
            title: const Text('项目主页'),
            subtitle: const Text(AppInfo.repoUrl),
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap: () => launchUrl(Uri.parse(AppInfo.repoUrl)),
          ),
          const Divider(height: 1),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.restore, color: scheme.error),
            title: Text('重置所有设置', style: TextStyle(color: scheme.error)),
            onTap: () => _resetAll(context, ref),
          ),
        ],
      ),
    );
  }

  /// 关于对话框
  void _showAbout(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          spacing: 8,
          children: [
            Icon(Icons.wine_bar_rounded),
            Text(AppInfo.name),
          ],
        ),
        content: Column(
          mainAxisSize: .min,
          crossAxisAlignment: .start,
          spacing: 8,
          children: [
            Text(
              AppInfo.tagline,
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
            Text('版本 v${AppInfo.version}'),
            Text('许可证 ${AppInfo.license}'),
            Text(
              '基于 FFmpeg 的逐流媒体转码工具',
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  /// 重置所有设置
  Future<void> _resetAll(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('重置所有设置'),
        content: const Text('主题与转码首选项都会恢复默认，正在配置的任务不受影响。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('重置'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await ref.read(preferencesServiceProvider).clearAll();
    ref.invalidate(themePreferencesProvider);
    ref.invalidate(transcodePreferencesProvider);
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('已恢复默认设置')));
  }
}
