import 'package:flutter/material.dart';

import '../shared/module_placeholder.dart';

/// 训练（Training）Skeleton。
///
/// 旧卦眼的学习与训练能力未来统一收编到这里（学习/练习/测试/错题/进度）。
/// 本阶段禁止直接搬旧 Training 页面过来。
class TrainingPage extends StatelessWidget {
  const TrainingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModulePlaceholder(
      title: '训练',
      description: '旧卦眼的学习与训练能力将在后续阶段统一迁移到这里。',
      features: ['学习', '练习', '测试', '错题', '进度'],
    );
  }
}
