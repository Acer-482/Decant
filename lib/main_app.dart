import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:decant/features/home/pages/home_pages.dart';
import 'package:decant/features/settings/enums/theme_mode_option.dart';
import 'package:decant/features/settings/providers/theme_preferences.dart';

/// 主程序
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProviderScope(child: _App());
  }
}

/// 应用主体
///
/// 主题跟着设置走，首选项还没读出来时先用默认主题
class _App extends ConsumerWidget {
  const _App();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(themeConfigProvider);

    return MaterialApp(
      locale: const Locale('zh', 'CN'),
      supportedLocales: const [Locale('zh', 'CN'), Locale('en', 'US')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: _theme(config.seedColor, Brightness.light), // 亮色主题
      darkTheme: _theme(config.seedColor, Brightness.dark), // 暗色主题
      themeMode: config.mode.themeMode,
      home: const HomePage(),
    ); // Material风格App
  }

  /// 由种子色生成主题
  ThemeData _theme(Color seedColor, Brightness brightness) {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: brightness,
      ),
    );
  }
}
