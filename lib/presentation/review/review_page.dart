import 'package:flutter/material.dart';

import '../../domain/hexagram_case.dart';
import '../casting/casting_tokens.dart';
import 'review_case_adapter.dart';
import 'review_demo_data.dart';
import 'review_page_state.dart';
import 'widgets/review_app_bar.dart';
import 'widgets/review_basic_info_card.dart';
import 'widgets/review_time_card.dart';
import 'widgets/review_hexagram_result_table.dart';
import 'widgets/review_line_detail_sheet.dart';
import 'widgets/review_shensha_card.dart';
import 'widgets/review_relation_toolbar.dart';

/// 审卦页 —— 审卦一屏版（GUAYAN-2.0 审卦首屏总基准）。
///
/// 一屏先看完整：基本信息（问事/公历/农历/meta）→ 四柱 → 4×4 神煞 →
/// 完整卦盘（主/变卦标题 + 六行排盘，六亲地支与纳音拆两行、无省略号）。
/// 「关系焦点」不再常驻大卡：点击某一爻 → 高亮该爻 → Bottom Sheet
/// （当前爻关系列表 / 规则依据 / 关系备注 / 进入关系页）。
///
/// 数据接入：App Shell 传入最近排盘结果 [latestCase]；测试可注入
/// [initialCase] / [initialProfile]；皆无时渲染视觉定稿演示排盘。
class ReviewPage extends StatelessWidget {
  const ReviewPage({
    super.key,
    this.latestCase,
    this.initialCase,
    this.initialProfile,
    this.onOpenRelations,
  });

  /// App Shell 传入的最近排盘结果；null 时回退演示排盘。
  final HexagramCase? latestCase;

  /// 测试注入（优先于 [latestCase]）。
  final HexagramCase? initialCase;

  /// 测试注入的传统排盘档案（与 [initialCase] 搭配使用）。
  final ReviewTraditionalProfile? initialProfile;

  /// 点爻弹层「进入关系页」回调（App Shell 切换到关系 Tab）。
  final VoidCallback? onOpenRelations;

  @override
  Widget build(BuildContext context) {
    final provided = initialCase ?? latestCase;
    final state = provided == null
        ? ReviewCaseAdapter.adapt(
            ReviewDemoData.hexagramCase(),
            profile: initialProfile ?? ReviewDemoData.profile(),
          )
        : ReviewCaseAdapter.adapt(provided, profile: initialProfile);
    return _ReviewWorkbench(state: state, onOpenRelations: onOpenRelations);
  }
}

class _ReviewWorkbench extends StatefulWidget {
  const _ReviewWorkbench({required this.state, this.onOpenRelations});

  final ReviewPageState state;
  final VoidCallback? onOpenRelations;

  @override
  State<_ReviewWorkbench> createState() => _ReviewWorkbenchState();
}

class _ReviewWorkbenchState extends State<_ReviewWorkbench> {
  int? _selectedPosition;

  void _onLineTap(int position) {
    setState(() => _selectedPosition = position);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ReviewLineDetailSheet(
        state: widget.state,
        position: position,
        onOpenRelations: widget.onOpenRelations,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8F6),
      body: SafeArea(
        top: true,
        bottom: false,
        child: Column(
          children: [
            const ReviewAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ReviewBasicInfoCard(state: widget.state),
                    const SizedBox(height: 6),
                    ReviewShenShaCard(state: widget.state),
                    const SizedBox(height: 6),
                    ReviewTimeCard(state: widget.state),
                    const SizedBox(height: 6),
                    ReviewHexagramResultTable(
                      state: widget.state,
                      selectedPosition: _selectedPosition,
                      onLineTap: _onLineTap,
                    ),
                    const SizedBox(height: 6),
                    const ReviewRelationToolbar(),
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
