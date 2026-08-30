import 'package:flutter/material.dart';

import '../../domain/hexagram_case.dart';
import '../../domain/line_state.dart';
import '../../domain/rule_execution_context.dart';
import '../../services/draft/casting_draft.dart';
import '../../services/draft/draft_repository.dart';
import 'casting_page_state.dart';
import 'casting_tokens.dart';
import 'widgets/casting_app_bar.dart';
import 'widgets/casting_draft_context.dart';
import 'widgets/casting_generate_row.dart';
import 'widgets/casting_question_row.dart';
import 'widgets/casting_rule_pack_row.dart';
import 'widgets/casting_time_row.dart';
import 'widgets/line_editor_sheet.dart';
import 'widgets/question_editor_sheet.dart';
import 'widgets/rule_pack_sheet.dart';
import 'widgets/six_yao_input_panel.dart';
import 'widgets/time_editor_sheet.dart';

/// 排卦页 —— XYUI 排卦工作台（GUAYAN-2.0-CASTING-UI-R1 定稿布局）。
///
/// 行顺序（已拍板，不可调整）：
/// 1 起卦时间 → 2 问事信息 → 3 六爻录入 → 4 规则包 → 5 生成排盘。
/// 页面是 INPUT WORKBENCH：输入 / 编辑 / 草稿 / 生成，不做关系分析。
///
/// 状态全部进入 [CastingPageState]（任务书 §7），草稿自动写入
/// [DraftRepository]（任务书 §15）；默认初始草稿为视觉定稿演示态
/// （[CastingDraft.demo]），正式版本可改传空草稿。
class CastingPage extends StatefulWidget {
  const CastingPage({
    super.key,
    this.initialDraft,
    this.repository,
    this.onGenerated,
  });

  /// 初始草稿；null 时使用视觉定稿演示草稿（4/6 爻）。
  final CastingDraft? initialDraft;

  /// 草稿仓库；null 时使用内存实现（接口边界已留，任务书 §15）。
  final DraftRepository? repository;

  /// 生成成功回调：App Shell 借此把最新排盘结果带给审卦页。
  final ValueChanged<HexagramCase>? onGenerated;

  @override
  State<CastingPage> createState() => _CastingPageState();
}

class _CastingPageState extends State<CastingPage> {
  late DraftRepository _repository;

  String _questionTitle = '';
  String _questionBody = '';
  String _questionObject = '';
  String _questionNote = '';
  DateTime? _castingTime;
  final List<LineState?> _lines = List<LineState?>.filled(6, null);
  RuleVersionRef _ruleRef = const RuleVersionRef('sys.default', 1);

  int? _editingPosition;
  bool _generated = false;
  bool _regenerateNeeded = false;
  HexagramCase? _generatedCase;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? InMemoryDraftRepository();
    final isDemo = widget.initialDraft == null;
    _apply(widget.initialDraft ?? CastingDraft.demo());
    // 视觉基准：演示草稿下三爻为当前编辑爻（任务书 §5.5）。
    if (isDemo) _editingPosition = 3;
  }

  void _apply(CastingDraft draft) {
    _questionTitle = draft.questionTitle;
    _questionBody = draft.questionBody;
    _questionObject = draft.questionObject;
    _questionNote = draft.questionNote;
    _castingTime = draft.castingTime;
    for (var i = 0; i < 6; i++) {
      _lines[i] = draft.lines[i];
    }
    _ruleRef = draft.ruleRef;
  }

  CastingDraft get _draft => CastingDraft(
        questionTitle: _questionTitle,
        questionBody: _questionBody,
        questionObject: _questionObject,
        questionNote: _questionNote,
        castingTime: _castingTime,
        lines: List<LineState?>.unmodifiable(_lines),
        ruleRef: _ruleRef,
      );

  /// 统一变更入口：更新状态 + 草稿自动保存（任务书 §15）。
  void _update(VoidCallback mutate) {
    setState(mutate);
    _repository.save(_draft);
  }

  /// 生成后关键数据被修改 → 标记需重新生成（不清空已生成排盘）。
  void _markChanged() {
    if (_generated) _regenerateNeeded = true;
  }

  void _saveTime(DateTime time) {
    _update(() {
      _castingTime = time;
      _markChanged();
    });
  }

  void _clearTime() {
    _update(() {
      _castingTime = null;
      _markChanged();
    });
  }

  void _saveQuestion(String title, String body, String object, String note) {
    _update(() {
      _questionTitle = title;
      _questionBody = body;
      _questionObject = object;
      _questionNote = note;
      _markChanged();
    });
  }

  void _setLine(int position, MovementType type) {
    _update(() {
      _lines[position - 1] = LineState(position: position, movementType: type);
      _markChanged();
    });
  }

  void _clearLine(int position) {
    _update(() {
      _lines[position - 1] = null;
      _markChanged();
    });
  }

  void _generate() {
    if (!_lines.every((l) => l != null)) return;
    final caseLines = List<LineState>.generate(6, (i) => _lines[i]!);
    final generated = HexagramCase(
      id: 'draft-${DateTime.now().millisecondsSinceEpoch}',
      question: _questionTitle.isEmpty ? _questionBody : _questionTitle,
      lines: caseLines,
      createdAt: _castingTime ?? DateTime.now(),
      ruleContext: RuleExecutionContext([_ruleRef]),
    );
    _update(() {
      _generated = true;
      _regenerateNeeded = false;
      _generatedCase = generated;
    });
    widget.onGenerated?.call(generated);
  }

  Future<void> _openLineEditor(int position) async {
    setState(() => _editingPosition = position);
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => LineEditorSheet(
        position: position,
        current: _lines[position - 1],
        onSelect: (type) => _setLine(position, type),
        onClear: _lines[position - 1] == null
            ? null
            : () => _clearLine(position),
      ),
    );
  }

  Future<void> _openTimeEditor() {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => TimeEditorSheet(
        initial: _castingTime,
        onSave: _saveTime,
        onClear: _castingTime == null ? null : _clearTime,
      ),
    );
  }

  Future<void> _openQuestionEditor() {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => QuestionEditorSheet(
        initialTitle: _questionTitle,
        initialBody: _questionBody,
        initialObject: _questionObject,
        initialNote: _questionNote,
        onSave: _saveQuestion,
      ),
    );
  }

  Future<void> _openRulePackSheet() {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => RulePackSheet(rulePackLabel: _rulePackLabel),
    );
  }

  String get _rulePackName =>
      _ruleRef.ruleId == 'sys.default' ? '默认规则包' : _ruleRef.ruleId;

  String get _rulePackLabel => '$_rulePackName · v${_ruleRef.version}';

  CastingPageState _buildState() {
    final linesComplete = _lines.every((l) => l != null);
    final generationState = _generated && !_regenerateNeeded
        ? GenerationState.generated
        : (linesComplete ? GenerationState.ready : GenerationState.locked);
    return CastingPageState(
      questionTitle: _questionTitle,
      questionBody: _questionBody,
      questionObject: _questionObject,
      questionNote: _questionNote,
      castingTime: _castingTime,
      rulePackName: _rulePackName,
      ruleVersion: _ruleRef.version,
      lines: List<LineState?>.unmodifiable(_lines),
      editingPosition: _editingPosition,
      generationState: generationState,
      draftState: DraftState.drafting,
      regenerateNeeded: _regenerateNeeded,
      generatedCase: _generatedCase,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = _buildState();
    return Scaffold(
      backgroundColor: CastingTokens.page,
      body: SafeArea(
        top: true,
        bottom: false,
        child: Column(
          children: [
            const CastingAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CastingDraftContext(
                      title: state.questionTitle,
                      rulePackName: state.rulePackName,
                      rulePackVersionLabel: state.rulePackVersionLabel,
                    ),
                    const SizedBox(height: 12),
                    CastingTimeRow(
                      castingTime: state.castingTime,
                      onTap: _openTimeEditor,
                    ),
                    const SizedBox(height: 12),
                    CastingQuestionRow(
                      title: state.questionTitle,
                      body: state.questionBody,
                      hasDetail:
                          state.questionObject.isNotEmpty ||
                              state.questionNote.isNotEmpty,
                      onTap: _openQuestionEditor,
                    ),
                    const SizedBox(height: 12),
                    SixYaoInputPanel(
                      lines: state.lines,
                      editingPosition: state.editingPosition,
                      completedLineCount: state.completedLineCount,
                      movingLineCount: state.movingLineCount,
                      onLineTap: _openLineEditor,
                    ),
                    const SizedBox(height: 12),
                    CastingRulePackRow(
                      rulePackLabel: state.rulePackLabel,
                      onTap: _openRulePackSheet,
                    ),
                    const SizedBox(height: 12),
                    CastingGenerateRow(
                      generationState: state.generationState,
                      regenerateNeeded: state.regenerateNeeded,
                      onGenerate: state.generationState == GenerationState.ready
                          ? _generate
                          : (state.regenerateNeeded ? _generate : null),
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
