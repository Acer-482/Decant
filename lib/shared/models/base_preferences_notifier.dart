import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:decant/shared/services/preferences_service.dart';

/// 首选项通知器基类
///
/// 负责键前缀与状态更新，子类只关心读写哪些字段
abstract class BasePreferencesNotifier<T> extends AsyncNotifier<T> {
  /// 首选项主键，作为字段键的前缀
  String get mainKey;

  /// 首选项服务
  PreferencesService get config => ref.read(preferencesServiceProvider);

  /// 拼上主键的完整键
  String getKey(String key) => mainKey.isEmpty ? key : '${mainKey}_$key';

  /// 更新状态
  ///
  /// 首选项还没加载完时，值已经写进存储，这里让它重新读一次
  void updateState(T Function(T value) create) {
    final value = state.value;
    if (value == null) {
      ref.invalidateSelf();
      return;
    }
    state = AsyncData(create(value));
  }
}
