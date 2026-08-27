import 'package:flutter/material.dart';

/// Foundation 阶段共用的模块占位组件。
///
/// 只表达「该模块未来做什么」，不承载任何业务。
/// 每个 Skeleton 页面使用小型占位区域，不做巨大空白 Hero 页。
class ModulePlaceholder extends StatelessWidget {
  const ModulePlaceholder({
    super.key,
    required this.title,
    required this.description,
    this.features = const [],
  });

  /// 模块工作台名称，例如「排卦工作台」。
  final String title;

  /// 一句话说明，例如「起卦时间、问事、六爻输入将在后续阶段实现。」
  final String description;

  /// 未来职责清单（可选）。
  final List<String> features;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.construction_rounded, size: 40, color: theme.colorScheme.primary),
              const SizedBox(height: 12),
              Text(title, style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                description,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (features.isNotEmpty) ...[
                const SizedBox(height: 20),
                for (final feature in features)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.chevron_right_rounded, size: 16),
                        const SizedBox(width: 4),
                        Text(feature, style: theme.textTheme.bodyMedium),
                      ],
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
