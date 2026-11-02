import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:decant/features/settings/enums/theme_mode_option.dart';
import 'package:decant/shared/services/preferences_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('没有存过时返回默认值', () async {
    final service = PreferencesService();

    expect(await service.getString('str', 'fallback'), 'fallback');
    expect(await service.getBool('bool', true), isTrue);
    expect(await service.getInt('int', 7), 7);
    expect((await service.getColor('color', Colors.cyan)).toARGB32(), Colors.cyan.toARGB32());
    expect(
      await service.getEnum(
        'enum',
        ThemeModeOption.values,
        ThemeModeOption.dark,
      ),
      ThemeModeOption.dark,
    );
  });

  test('写入后能原样读回', () async {
    final service = PreferencesService();

    await service.setString('str', 'value');
    await service.setBool('bool', false);
    await service.setInt('int', 3);
    await service.setColor('color', Colors.orange);
    await service.setEnum('enum', ThemeModeOption.light);

    expect(await service.getString('str', ''), 'value');
    expect(await service.getBool('bool', true), isFalse);
    expect(await service.getInt('int', 0), 3);
    expect((await service.getColor('color', Colors.cyan)).toARGB32(), Colors.orange.toARGB32());
    expect(
      await service.getEnum(
        'enum',
        ThemeModeOption.values,
        ThemeModeOption.dark,
      ),
      ThemeModeOption.light,
    );
  });

  test('枚举存了未知值时回落到默认', () async {
    SharedPreferences.setMockInitialValues({'enum': 'nope'});
    final service = PreferencesService();

    expect(
      await service.getEnum(
        'enum',
        ThemeModeOption.values,
        ThemeModeOption.system,
      ),
      ThemeModeOption.system,
    );
  });

  test('remove 与 clearAll', () async {
    final service = PreferencesService();
    await service.setString('str', 'value');

    await service.remove('str');
    expect(await service.getString('str', ''), '');

    await service.setString('str', 'again');
    await service.clearAll();
    expect(await service.getString('str', ''), '');
  });
}
