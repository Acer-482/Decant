import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:decant/features/settings/models/theme_config.dart';
import 'package:decant/features/settings/pages/settings_page.dart';
import 'package:decant/features/settings/providers/theme_preferences.dart';
import 'package:decant/features/settings/providers/transcode_preferences.dart';

/// 包一层应用
Widget _app() => const ProviderScope(
  child: MaterialApp(home: Scaffold(body: SettingsPage())),
);

/// 等首选项加载与动画结束
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// 取出页面所在的容器，用来断言状态
ProviderContainer _container(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(SettingsPage)));

Future<void> _pump(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(900, 1400));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(_app());
  await _settle(tester);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('渲染外观、转码、关于三组设置', (tester) async {
    await _pump(tester);

    expect(find.text('外观'), findsOneWidget);
    expect(find.text('转码'), findsOneWidget);
    expect(find.text('关于'), findsOneWidget);
    expect(find.text('主题模式'), findsOneWidget);
    expect(find.text('默认输出目录'), findsOneWidget);
    expect(find.text('完成后自动打开输出文件夹'), findsOneWidget);
    expect(find.text('重置所有设置'), findsOneWidget);
  });

  testWidgets('点击开关会写入首选项', (tester) async {
    await _pump(tester);
    expect(
      _container(tester).read(transcodeConfigProvider).autoOpenOutput,
      isTrue,
    );

    await tester.tap(find.text('完成后自动打开输出文件夹'));
    await _settle(tester);

    expect(
      _container(tester).read(transcodeConfigProvider).autoOpenOutput,
      isFalse,
    );
  });

  testWidgets('点击主题色会写入首选项', (tester) async {
    await _pump(tester);
    expect(
      _container(tester).read(themeConfigProvider).seedColor.toARGB32(),
      ThemeConfig.defaults.seedColor.toARGB32(),
    );

    await tester.tap(find.byKey(ValueKey(Colors.orange.toARGB32())));
    await _settle(tester);

    expect(
      _container(tester).read(themeConfigProvider).seedColor.toARGB32(),
      Colors.orange.toARGB32(),
    );
  });

  testWidgets('重置所有设置会恢复默认', (tester) async {
    await _pump(tester);

    // 先把主题色改掉
    await tester.tap(find.byKey(ValueKey(Colors.orange.toARGB32())));
    await _settle(tester);
    expect(
      _container(tester).read(themeConfigProvider).seedColor.toARGB32(),
      Colors.orange.toARGB32(),
    );

    // 触发重置
    await tester.tap(find.text('重置所有设置'));
    await _settle(tester);
    await tester.tap(find.widgetWithText(FilledButton, '重置'));
    await _settle(tester);

    final container = _container(tester);
    expect(container.read(themeConfigProvider), ThemeConfig.defaults);
    expect(container.read(transcodeConfigProvider).autoOpenOutput, isTrue);
  });
}
