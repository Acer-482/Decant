import 'package:flutter/material.dart';

/// 紧凑的开关行
class SwitchRow extends StatelessWidget {
  /// 标题
  final String title;

  /// 说明
  final String? subtitle;

  /// 当前值
  final bool value;

  /// 变化回调
  final ValueChanged<bool>? onChanged;

  const SwitchRow({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onChanged == null ? null : () => onChanged!(!value),
      borderRadius: .circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  Text(title, style: theme.textTheme.bodyMedium),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              materialTapTargetSize: .shrinkWrap,
            ),
          ],
        ),
      ),
    );
  }
}
