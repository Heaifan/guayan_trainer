import 'package:flutter/material.dart';

import '../../domain/hexagram_case.dart';
import '../../domain/rules/evidence/derived_evidence.dart';
import '../../domain/rules/engine/rule_trace.dart';
import '../../domain/relation_endpoint.dart';
import '../../domain/shensha/shensha_note_store.dart';
import 'review_case_adapter.dart';
import 'review_demo_data.dart';
import 'review_page_state.dart';
import 'widgets/review_app_bar.dart';
import 'widgets/review_basic_info_card.dart';
import 'widgets/review_time_card.dart';
import 'widgets/review_hexagram_result_table.dart';
import 'widgets/review_shensha_card.dart';
import 'widgets/review_shensha_detail_dialog.dart';
import 'widgets/review_relation_toolbar.dart';
import 'widgets/relation_overlay.dart';
import 'widgets/review_evidence_card.dart';
import 'widgets/review_rule_runs_card.dart';
import '../rules/widgets/rule_trace_tree.dart';

/// 审卦页 —— 审卦一屏版（GUAYAN-2.0 审卦首屏总基准）。
///
/// 一屏先看完整：基本信息（问事/公历/农历/meta）→ 四柱 → 紧凑神煞 →
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
    this.useDemoFallback = true,
    this.shenShaNoteStore,
    this.onRecompute,
  });

  /// App Shell 传入的最近排盘结果；null 时回退演示排盘。
  final HexagramCase? latestCase;

  /// 测试注入（优先于 [latestCase]）。
  final HexagramCase? initialCase;

  /// 测试注入的传统排盘档案（与 [initialCase] 搭配使用）。
  final ReviewTraditionalProfile? initialProfile;

  /// 点爻弹层「进入关系页」回调（App Shell 切换到关系 Tab）。
  final VoidCallback? onOpenRelations;

  /// 仅测试/视觉基准允许演示数据；真实 App 路径关闭此回退。
  final bool useDemoFallback;
  final ShenShaNoteStore? shenShaNoteStore;
  final VoidCallback? onRecompute;

  @override
  Widget build(BuildContext context) {
    final provided = initialCase ?? latestCase;
    final state = provided == null && useDemoFallback
        ? ReviewCaseAdapter.adapt(
            ReviewDemoData.hexagramCase(),
            profile: initialProfile ?? ReviewDemoData.profile(),
          )
        : provided == null
        ? ReviewPageState(
            question: '尚未生成排盘',
            lines: const [],
            focusedRelations: const [],
            allRelations: const [],
          )
        : ReviewCaseAdapter.adapt(provided, profile: initialProfile);
    return _ReviewWorkbench(
      state: state,
      onOpenRelations: onOpenRelations,
      shenShaNoteStore: shenShaNoteStore ?? ShenShaNoteStore(),
      onRecompute: onRecompute,
    );
  }
}

class _ReviewWorkbench extends StatefulWidget {
  const _ReviewWorkbench({
    required this.state,
    this.onOpenRelations,
    required this.shenShaNoteStore,
    this.onRecompute,
  });

  final ReviewPageState state;
  final VoidCallback? onOpenRelations;
  final ShenShaNoteStore shenShaNoteStore;
  final VoidCallback? onRecompute;

  @override
  State<_ReviewWorkbench> createState() => _ReviewWorkbenchState();
}

class _ReviewWorkbenchState extends State<_ReviewWorkbench> {
  int? _selectedPosition;
  String _relationFilter = '全部';
  late final _anchorKeys = <String, GlobalKey>{
    for (var i = 1; i <= 6; i++) 'yao:original:$i': GlobalKey(),
    for (var i = 1; i <= 6; i++) 'yao:changed:$i': GlobalKey(),
    'month': GlobalKey(),
    'day': GlobalKey(),
    'hour': GlobalKey(),
  };

  void _onLineTap(int position) {
    if (_selectedPosition == position) {
      setState(() => _selectedPosition = null);
      return;
    }
    setState(() => _selectedPosition = position);
  }

  Future<void> _onShenShaTap(ReviewShenShaItem item) async {
    final id = item.id;
    if (id == null) return;
    final note = await showDialog<String>(
      context: context,
      builder: (_) => ReviewShenShaDetailDialog(
        item: item,
        note: widget.shenShaNoteStore.noteFor(
          caseId: widget.state.caseId ?? widget.state.question,
          shenShaId: id,
        ),
      ),
    );
    if (note == null) return;
    setState(() {
      widget.shenShaNoteStore.save(
        caseId: widget.state.caseId ?? widget.state.question,
        shenShaId: id,
        content: note,
      );
    });
  }

  Future<void> _showEvidence(DerivedEvidence evidence) async {
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(evidence.value),
        content: Text(
          '来源：${evidence.ruleOrigin.name == 'CUSTOM' ? '自定义规则' : '系统规则'}\n'
          '规则：${evidence.ruleId.id}\n'
          '版本：${evidence.ruleVersion.version}\n'
          '目标：${evidence.targetRefs.map((ref) => '${ref.kind}/${ref.key}').join(' → ')}\n'
          '依据：${evidence.supports.length} 条',
        ),
      ),
    );
  }

  Future<void> _showTrace(RuleTrace trace) async {
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(trace.label),
        content: SingleChildScrollView(child: RuleTraceTree(trace: trace)),
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
            ReviewAppBar(onRecompute: widget.onRecompute),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  14,
                  8,
                  14,
                  // 页面可滚动，但底部导航不能覆盖关系栏或卦盘尾部。
                  MediaQuery.of(context).viewPadding.bottom + 112,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ReviewBasicInfoCard(state: widget.state),
                    const SizedBox(height: 6),
                    ReviewShenShaCard(
                      state: widget.state,
                      onItemTap: _onShenShaTap,
                    ),
                    const SizedBox(height: 6),
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Column(
                          children: [
                            ReviewTimeCard(
                              state: widget.state,
                              anchorKeys: _anchorKeys,
                            ),
                            const SizedBox(height: 6),
                            ReviewHexagramResultTable(
                              state: widget.state,
                              selectedPosition: _selectedPosition,
                              onLineTap: _onLineTap,
                              anchorKeys: _anchorKeys,
                            ),
                          ],
                        ),
                        RelationOverlay(
                          records: widget.state.relationRecords,
                          anchorKeys: _anchorKeys,
                          category: _relationFilter,
                          focus: _selectedPosition == null
                              ? null
                              : YaoEndpoint(
                                  LineScope.original,
                                  _selectedPosition!,
                                ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ReviewRelationToolbar(
                      state: widget.state,
                      focusedPosition: _selectedPosition,
                      selectedFilter: _relationFilter,
                      onFilterChanged: (filter) =>
                          setState(() => _relationFilter = filter),
                    ),
                    const SizedBox(height: 6),
                    ReviewEvidenceCard(
                      state: widget.state,
                      onOpen: _showEvidence,
                    ),
                    const SizedBox(height: 6),
                    ReviewRuleRunsCard(
                      state: widget.state,
                      onOpen: _showTrace,
                    ),
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
