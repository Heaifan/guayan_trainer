import 'package:flutter/material.dart';

import '../../domain/hexagram_case.dart';
import '../casting/casting_tokens.dart';
import 'review_case_adapter.dart';
import 'review_demo_data.dart';
import 'review_page_state.dart';
import 'widgets/review_app_bar.dart';
import 'widgets/review_basic_info_card.dart';
import 'widgets/review_four_pillars_strip.dart';
import 'widgets/review_hexagram_result_header.dart';
import 'widgets/review_hexagram_result_table.dart';
import 'widgets/review_relation_focus_card.dart';
import 'widgets/review_shensha_card.dart';

/// 审卦页 —— XYUI 长页排盘工作台（GUAYAN-2.0-REVIEW-UI-R1 定稿布局）。
///
/// 产品心智：排卦结果上下文 → 完整传统六爻排盘 → 人工审卦 →
/// 关系焦点 / 规则依据 → 必要时进入关系页继续深入。
///
/// 数据接入（T12/T13）：
/// - [latestCase]：App Shell 传入的最近排盘结果（排卦生成后自动带入）；
/// - [initialCase]：测试注入；
/// - 两者皆无时渲染视觉定稿演示排盘（[ReviewDemoData]，含传统档案）；
/// - 真实卦例仅携带 Domain 字段（六爻/地支/时间/关系），
///   六神/伏神/六亲/神煞/四柱/卦名等传统字段显式置空（排盘引擎 R3 GAP）。
///
/// 布局（任务书 §3）：SafeArea → Column → ReviewAppBar → Expanded
/// SingleChildScrollView（BasicInfo → ShenSha → FourPillars →
/// HexagramHeader → HexagramTable → RelationFocus）→ MainTabBar 固定在 App Shell。
class ReviewPage extends StatelessWidget {
  const ReviewPage({super.key, this.latestCase, this.initialCase});

  /// App Shell 传入的最近排盘结果；null 时回退演示排盘。
  final HexagramCase? latestCase;

  /// 测试注入（优先于 [latestCase]）。
  final HexagramCase? initialCase;

  @override
  Widget build(BuildContext context) {
    final provided = initialCase ?? latestCase;
    final state = provided == null
        ? ReviewCaseAdapter.adapt(
            ReviewDemoData.hexagramCase(),
            profile: ReviewDemoData.profile(),
          )
        : ReviewCaseAdapter.adapt(provided);
    return _ReviewWorkbench(state: state);
  }
}

class _ReviewWorkbench extends StatelessWidget {
  const _ReviewWorkbench({required this.state});

  final ReviewPageState state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CastingTokens.page,
      body: SafeArea(
        top: true,
        bottom: false,
        child: Column(
          children: [
            const ReviewAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ReviewBasicInfoCard(state: state),
                    const SizedBox(height: 12),
                    ReviewShenShaCard(state: state),
                    const SizedBox(height: 12),
                    ReviewFourPillarsStrip(state: state),
                    const SizedBox(height: 12),
                    ReviewHexagramResultHeader(state: state),
                    const SizedBox(height: 12),
                    ReviewHexagramResultTable(state: state),
                    const SizedBox(height: 12),
                    ReviewRelationFocusCard(state: state),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
