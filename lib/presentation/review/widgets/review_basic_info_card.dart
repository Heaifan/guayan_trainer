import 'package:flutter/material.dart';

import '../../casting/casting_tokens.dart';
import '../review_page_state.dart';

/// 基本信息卡（审卦一屏版总 SVG：问事 / 公历 / 农历 / meta 单行）。
///
/// 紧凑单卡：问事 + 起卦方式 chip + 公历/农历两栏 + meta
/// （规则包版本 · 手动起卦 · 排盘已生成）。不再拆大卡片。
class ReviewBasicInfoCard extends StatelessWidget {
  const ReviewBasicInfoCard({super.key, required this.state});

  final ReviewPageState state;

  String get _rulePackLabel {
    final id = state.rulePackId;
    if (id == null) return '—';
    final name = id == 'sys.default' ? '默认规则包' : id;
    return '$name v${state.ruleVersion ?? 1}';
  }

  @override
  Widget build(BuildContext context) {
    final solar =
        state.solarDateTime == null ? '—' : formatSolar(state.solarDateTime!);
    final lunar = state.lunarDateTime ?? '—';

    return Container(
      width: double.infinity,
      height: 72,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDCE5E1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                '问事',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF243744),
                  height: 1.2,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  state.question.isEmpty ? '—' : state.question,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF405E6C),
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 72,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F5F2),
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(color: const Color(0xFF9BB2A6)),
                ),
                child: Text(
                  state.castingMethod ?? '—',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF71838B),
                    height: 1.1,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            '公历 $solar　农历 $lunar',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF71838B),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$_rulePackLabel　${state.castingMethod == null ? '—' : '手动起卦'}　排盘已生成',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF71838B),
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
