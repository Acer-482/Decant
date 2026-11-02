import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 首选项服务
final preferencesServiceProvider = Provider<PreferencesService>(
  (ref) => PreferencesService(),
);

/// 首选项服务
///
/// 对 [SharedPreferences] 的薄封装，只做类型转换与默认值兜底
class PreferencesService {
  /// 获取实例
  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  /// 清空全部配置
  Future<bool> clearAll() async => (await _prefs).clear();

  /// 删除单个配置
  Future<bool> remove(String key) async => (await _prefs).remove(key);

  /// 字符串
  Future<String> getString(String key, String fallback) async =>
      (await _prefs).getString(key) ?? fallback;

  Future<void> setString(String key, String value) async {
    await (await _prefs).setString(key, value);
  }

  /// 布尔值
  Future<bool> getBool(String key, bool fallback) async =>
      (await _prefs).getBool(key) ?? fallback;

  Future<void> setBool(String key, bool value) async {
    await (await _prefs).setBool(key, value);
  }

  /// 整数
  Future<int> getInt(String key, int fallback) async =>
      (await _prefs).getInt(key) ?? fallback;

  Future<void> setInt(String key, int value) async {
    await (await _prefs).setInt(key, value);
  }

  /// 颜色，按 ARGB 整数存
  Future<Color> getColor(String key, Color fallback) async =>
      Color((await _prefs).getInt(key) ?? fallback.toARGB32());

  Future<void> setColor(String key, Color value) async {
    await (await _prefs).setInt(key, value.toARGB32());
  }

  /// 枚举，按 name 存
  Future<T> getEnum<T extends Enum>(
    String key,
    List<T> values,
    T fallback,
  ) async {
    final name = (await _prefs).getString(key);
    for (final value in values) {
      if (value.name == name) return value;
    }
    return fallback;
  }

  Future<void> setEnum(String key, Enum value) async {
    await (await _prefs).setString(key, value.name);
  }
}
