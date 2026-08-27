import 'package:flutter/material.dart';

import '../shared/module_placeholder.dart';

/// 排卦（Casting）Skeleton。
///
/// 未来负责：起卦时间、问事、六爻输入、规则包选择、生成排盘。
class CastingPage extends StatefulWidget {
  const CastingPage({super.key});

  @override
  State<CastingPage> createState() => _CastingPageState();
}

class _CastingPageState extends State<CastingPage> {
  /// Foundation 阶段的状态保持探针（§35）。
  /// 用于验证 IndexedStack 切换后页面状态不被销毁，后续阶段可删除。
  int _probeCount = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Expanded(
          child: ModulePlaceholder(
            title: '排卦工作台',
            description: '起卦时间、问事、六爻输入、规则包选择与生成排盘将在后续阶段实现。',
            features: ['起卦时间', '问事信息', '六爻输入', '规则包选择', '生成排盘'],
          ),
        ),
        TextButton(
          onPressed: () => setState(() => _probeCount++),
          child: Text('状态探针：$_probeCount'),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
