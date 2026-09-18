import 'package:flutter/material.dart';

import '../../domain/hexagram_case.dart';
import '../../domain/cases/case_record.dart';
import '../../domain/shensha/shensha_note_store.dart';
import 'more_menu.dart';
import 'navigation/guayan_main_tab_bar.dart';
import 'navigation/main_tabs.dart';
import '../presentation/casting/casting_page.dart';
import '../presentation/cases/cases_page.dart';
import '../presentation/review/review_page.dart';
import '../presentation/relations/relations_page.dart';
import '../services/calendar/casting_calendar_service.dart';
import '../services/cases/case_repository.dart';
import '../services/cases/json_case_repository.dart';
import '../services/cases/case_recompute_service.dart';
import '../services/relation_annotation_store.dart';
import '../services/manual_relation_store.dart';

/// 卦眼 2.0 应用壳。
///
/// 持有唯一权威的底部导航状态 [AppShellState.selectedIndex]，
/// 通过 IndexedStack 保持五个主页面在切换时不被销毁。
/// 排卦页与审卦页自带 XYUI TopBar（无全局 AppBar）；其余页面沿用全局 AppBar。
/// 排卦生成结果经 [AppShellState._latestCase] 桥接给审卦页（T12 数据接入）。
class AppShell extends StatefulWidget {
  const AppShell({super.key, this.calendarService});

  final CastingCalendarService? calendarService;

  @override
  State<AppShell> createState() => AppShellState();
}

class AppShellState extends State<AppShell> {
  /// 底部导航唯一权威来源；默认进入排卦（Index 0）。
  int selectedIndex = 0;

  /// 最近一次排卦生成结果（排卦 → 审卦 数据桥接）。
  HexagramCase? _latestCase;
  CaseRecord? _activeRecord;
  final ShenShaNoteStore _shenShaNoteStore = ShenShaNoteStore();
  CaseRepository? _caseRepository;
  final RelationAnnotationStore _relationAnnotations =
      RelationAnnotationStore();
  final ManualRelationStore _manualRelations = ManualRelationStore();

  @override
  void initState() {
    super.initState();
    JsonCaseRepository.open().then((repository) {
      if (mounted) setState(() => _caseRepository = repository);
    });
  }

  void _openCase(CaseRecord record) {
    setState(() {
      _activeRecord = record;
      _latestCase = record.toHexagramCase();
      selectedIndex = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final useCustomTopBar = selectedIndex == 0 || selectedIndex == 1;
    return Scaffold(
      appBar: useCustomTopBar
          ? null
          : AppBar(
              title: Text(mainTabs[selectedIndex].title),
              actions: [MoreMenuButton(latestCase: _latestCase)],
            ),
      body: IndexedStack(
        index: selectedIndex,
        children: [
          CastingPage(
            calendarService: widget.calendarService,
            caseRepository: _caseRepository,
            useDemoDraft: false,
            onGenerated: (case_) {
              setState(() {
                _latestCase = case_;
                _activeRecord = null;
                selectedIndex = 1;
              });
              _caseRepository?.read(case_.id).then((record) {
                if (mounted && record != null) {
                  setState(() => _activeRecord = record);
                }
              });
            },
          ),
          ReviewPage(
            latestCase: _latestCase,
            useDemoFallback: false,
            shenShaNoteStore: _shenShaNoteStore,
            onRecompute: _recomputeActiveCase,
            onOpenRelations: () => setState(() => selectedIndex = 2),
          ),
          RelationsPage(
            latestCase: _latestCase,
            annotationStore: _relationAnnotations,
            manualStore: _manualRelations,
          ),
          CasesPage(
            repository: _caseRepository,
            onOpenCase: _openCase,
            showAppBar: false,
          ),
          mainTabs[4].builder(context),
        ],
      ),
      bottomNavigationBar: GuayanMainTabBar(
        tabs: mainTabs,
        selectedIndex: selectedIndex,
        onSelect: (index) {
          setState(() => selectedIndex = index);
        },
      ),
    );
  }

  Future<void> _recomputeActiveCase() async {
    final record = _activeRecord;
    final repository = _caseRepository;
    if (record == null || repository == null || record.ruleRuns.isEmpty) return;
    final latest = record.ruleRuns.last;
    await CaseRecomputeService(repository).recompute(
      caseId: record.id,
      ruleContext: latest.ruleContext,
      result: latest.result,
      evidence: latest.evidence,
    );
    if (!mounted) return;
    final refreshed = await repository.read(record.id);
    if (refreshed != null) setState(() => _activeRecord = refreshed);
  }
}
