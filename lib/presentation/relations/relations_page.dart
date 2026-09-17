import 'package:flutter/material.dart';
import '../../domain/hexagram_case.dart';
import '../../domain/relation_calculator.dart';
import '../../domain/relation_endpoint.dart';
import '../../domain/relations/relation_projection.dart';
import '../../domain/relations/relation_record.dart';
import '../../services/manual_relation_store.dart';
import '../../services/relation_annotation_store.dart';
import '../../services/relation_ledger_query.dart';
import '../review/review_case_adapter.dart';
import '../review/review_page_state.dart';
import 'relation_endpoint_presenter.dart';
import 'widgets/relation_glyph.dart';

class RelationsPage extends StatefulWidget {
  const RelationsPage({super.key, this.latestCase, this.records, this.annotationStore, this.manualStore});
  final HexagramCase? latestCase;
  final List<RelationRecord>? records;
  final RelationAnnotationStore? annotationStore;
  final ManualRelationStore? manualStore;
  @override
  State<RelationsPage> createState() => _RelationsPageState();
}

class _RelationsPageState extends State<RelationsPage> {
  final _search = TextEditingController();
  late final RelationAnnotationStore _annotations =
      widget.annotationStore ?? RelationAnnotationStore();
  late final ManualRelationStore _manual =
      widget.manualStore ?? ManualRelationStore();
  RelationKind? _kind;
  int? _position;
  String? _category;
  String get _caseId => widget.latestCase?.id ?? 'preview';
  ReviewPageState? get _state => widget.latestCase == null
      ? null
      : ReviewCaseAdapter.adapt(widget.latestCase!);
  RelationEndpointPresenter get _presenter => RelationEndpointPresenter(_state);
  List<RelationRecord> get _records => [
    ...(widget.records ??
        (widget.latestCase == null
            ? const []
            : RelationProjection.projectRelationInstances(
                calculateRelations(widget.latestCase!),
              ))),
    ..._manual.recordsFor(_caseId),
  ];
  List<RelationRecord> get _visible {
    final indexed = RelationLedgerQuery.filter(
      _records,
      kind: _kind,
      position: _position,
      category: _category,
      keyword: _search.text,
      store: _annotations,
      caseId: _caseId,
    );
    final query = _search.text.trim().toLowerCase();
    if (query.isEmpty) return indexed;
    final displayMatches = [
      for (final record in _records)
        if (_displaySearchMatch(record, query)) record,
    ];
    return {...indexed, ...displayMatches}.where((record) {
      if (_kind != null && record.kind != _kind) return false;
      if (_position != null &&
          !record.participants.any(
            (e) => e is YaoEndpoint && e.position == _position,
          )) {
        return false;
      }
      if (_category != null && record.category != _category) return false;
      return true;
    }).toList();
  }

  bool _displaySearchMatch(RelationRecord record, String query) {
    final endpoints = [
      ...record.participants,
    ].map((endpoint) => _presenter.present(endpoint));
    final text = endpoints
        .expand(
          (endpoint) => [
            endpoint.position,
            endpoint.identity,
            endpoint.fullName,
          ],
        )
        .join(' ')
        .toLowerCase();
    return text.contains(query);
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = <String>{
      for (final r in _records)
        if (r.category != null) r.category!,
    };
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8F6),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '关系',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _search,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: '搜索六亲、干支、关系、规则、备注……',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 8),
              _FilterStrip(
                kind: _kind,
                position: _position,
                category: _category,
                categories: categories,
                onKind: (v) => setState(() => _kind = v),
                onPosition: (v) => setState(() => _position = v),
                onCategory: (v) => setState(() => _category = v),
                onClear: () => setState(() {
                  _kind = null;
                  _position = null;
                  _category = null;
                }),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _visible.length == _records.length
                          ? '共 ${_visible.length} 条关系与状态'
                          : '找到 ${_visible.length} 条',
                      style: const TextStyle(color: Color(0xFF71838B)),
                    ),
                  ),
                  TextButton.icon(
                    key: const Key('manual_relation_button'),
                    onPressed: _createManual,
                    icon: const Icon(Icons.add_link, size: 17),
                    label: const Text('连线'),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Expanded(
                child: _visible.isEmpty
                    ? const Center(child: Text('当前卦暂无关系记录'))
                    : ListView.separated(
                        itemCount: _visible.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 4),
                        itemBuilder: (_, i) => _LedgerRow(
                          record: _visible[i],
                          presenter: _presenter,
                          note: _annotations
                              .annotationFor(
                                caseId: _caseId,
                                recordId: _visible[i].id,
                              )
                              ?.note,
                          onTap: () => _openDetail(_visible[i]),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openDetail(RelationRecord record) async {
    final note = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _RelationDetailSheet(
        record: record,
        presenter: _presenter,
        note: _annotations
            .annotationFor(caseId: _caseId, recordId: record.id)
            ?.note,
      ),
    );
    if (note != null) {
      setState(
        () => _annotations.upsert(
          caseId: _caseId,
          recordId: record.id,
          note: note,
        ),
      );
    }
  }

  Future<void> _createManual() async {
    final draft = await showDialog<_ManualDraft>(
      context: context,
      builder: (_) => const _ManualRelationDialog(),
    );
    if (draft == null) return;
    setState(
      () => _manual.create(
        caseId: _caseId,
        id: 'user:${DateTime.now().microsecondsSinceEpoch}',
        from: YaoEndpoint(LineScope.original, draft.from),
        to: YaoEndpoint(LineScope.original, draft.to),
        title: draft.title,
        note: draft.note,
      ),
    );
  }
}

class _FilterStrip extends StatelessWidget {
  const _FilterStrip({
    required this.kind,
    required this.position,
    required this.category,
    required this.categories,
    required this.onKind,
    required this.onPosition,
    required this.onCategory,
    required this.onClear,
  });
  final RelationKind? kind;
  final int? position;
  final String? category;
  final Set<String> categories;
  final ValueChanged<RelationKind?> onKind;
  final ValueChanged<int?> onPosition;
  final ValueChanged<String?> onCategory;
  final VoidCallback onClear;
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _Choice(
              label: kind == null
                  ? '全部'
                  : kind == RelationKind.relation
                  ? '关系'
                  : '状态',
              selected: kind != null,
              onTap: () => onKind(
                kind == null
                    ? RelationKind.relation
                    : kind == RelationKind.relation
                    ? RelationKind.state
                    : null,
              ),
            ),
            for (var i = 1; i <= 6; i++)
              _Choice(
                label: _positionName(i),
                selected: position == i,
                onTap: () => onPosition(position == i ? null : i),
              ),
          ],
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            for (final item in categories)
              _Choice(
                label: item,
                selected: category == item,
                onTap: () => onCategory(category == item ? null : item),
              ),
            TextButton(onPressed: onClear, child: const Text('清除')),
          ],
        ),
      ],
    ),
  );
}

String _positionName(int position) =>
    const ['初爻', '二爻', '三爻', '四爻', '五爻', '上爻'][position - 1];

class _Choice extends StatelessWidget {
  const _Choice({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(right: 5),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE6F0EB) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFD6E1DC)),
        ),
        child: Text(label, style: const TextStyle(fontSize: 11)),
      ),
    ),
  );
}

class _LedgerRow extends StatelessWidget {
  const _LedgerRow({
    required this.record,
    required this.presenter,
    this.note,
    required this.onTap,
  });
  final RelationRecord record;
  final RelationEndpointPresenter presenter;
  final String? note;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 9),
      color: Colors.white,
      child: record.kind == RelationKind.state
          ? _StateRow(record: record, presenter: presenter)
          : _RelationRow(record: record, presenter: presenter, note: note),
    ),
  );
}

class _RelationRow extends StatelessWidget {
  const _RelationRow({
    required this.record,
    required this.presenter,
    this.note,
  });
  final RelationRecord record;
  final RelationEndpointPresenter presenter;
  final String? note;
  @override
  Widget build(BuildContext context) {
    final from = presenter.present(record.fromRef!);
    final to = presenter.present(record.toRef!);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: _EndpointText(value: from)),
            RelationGlyph(type: record.relationType!),
            Expanded(child: _EndpointText(value: to, alignEnd: true)),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          '${presenter.categoryName(record.category, record.relationType)} · ${presenter.sourceName()}',
          style: const TextStyle(fontSize: 11, color: Color(0xFF71838B)),
        ),
        if (note != null && note!.trim().isNotEmpty)
          Text(
            '备注：${note!.trim()}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: Color(0xFF71838B)),
          ),
      ],
    );
  }
}

class _StateRow extends StatelessWidget {
  const _StateRow({required this.record, required this.presenter});
  final RelationRecord record;
  final RelationEndpointPresenter presenter;
  @override
  Widget build(BuildContext context) {
    final endpoint = record.participants.isEmpty
        ? null
        : presenter.present(record.participants.first);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            if (endpoint != null)
              Expanded(child: _EndpointText(value: endpoint)),
            Text(
              record.title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF397C7C),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          '状态 · ${presenter.sourceName()}',
          style: const TextStyle(fontSize: 11, color: Color(0xFF71838B)),
        ),
      ],
    );
  }
}

class _EndpointText extends StatelessWidget {
  const _EndpointText({required this.value, this.alignEnd = false});
  final RelationEndpointDisplay value;
  final bool alignEnd;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: alignEnd
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start,
    children: [
      Text(
        value.position,
        style: const TextStyle(fontSize: 11, color: Color(0xFF71838B)),
      ),
      Text(
        value.identity,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: alignEnd ? TextAlign.right : TextAlign.left,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
      ),
    ],
  );
}

class _RelationDetailSheet extends StatefulWidget {
  const _RelationDetailSheet({
    required this.record,
    required this.presenter,
    this.note,
  });
  final RelationRecord record;
  final RelationEndpointPresenter presenter;
  final String? note;
  @override
  State<_RelationDetailSheet> createState() => _RelationDetailSheetState();
}

class _RelationDetailSheetState extends State<_RelationDetailSheet> {
  late final _controller = TextEditingController(
    text: widget.note ?? widget.record.note ?? '',
  );
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(
      20,
      20,
      20,
      MediaQuery.of(context).viewInsets.bottom + 20,
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          '关系详情',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        if (widget.record.kind == RelationKind.relation)
          _DetailRelation(record: widget.record, presenter: widget.presenter)
        else
          _StateRow(record: widget.record, presenter: widget.presenter),
        const SizedBox(height: 12),
        if (widget.record.kind == RelationKind.relation) ...[
          _DetailLine(
            '关系类型',
            '${widget.presenter.categoryName(widget.record.category, widget.record.relationType)} · ${widget.record.relationType?.displayName ?? '手工'}',
          ),
          _DetailLine('来源', widget.presenter.sourceName()),
          _DetailLine(
            '规则依据',
            widget.presenter.ruleName(
              widget.record.relationType,
              widget.record.ruleId,
            ),
          ),
        ],
        const SizedBox(height: 10),
        const Text('备注', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        TextField(
          controller: _controller,
          maxLines: 3,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        const SizedBox(height: 10),
        FilledButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: const Text('保存备注'),
        ),
      ],
    ),
  );
}

class _DetailRelation extends StatelessWidget {
  const _DetailRelation({required this.record, required this.presenter});
  final RelationRecord record;
  final RelationEndpointPresenter presenter;
  @override
  Widget build(BuildContext context) {
    final from = presenter.present(record.fromRef!);
    final to = presenter.present(record.toRef!);
    return Column(
      children: [
        _EndpointText(value: from),
        RelationGlyph(type: record.relationType!),
        _EndpointText(value: to),
      ],
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine(this.label, this.value);
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 62,
          child: Text(label, style: const TextStyle(color: Color(0xFF71838B))),
        ),
        Expanded(child: Text(value)),
      ],
    ),
  );
}

class _ManualDraft {
  const _ManualDraft(this.from, this.to, this.title, this.note);
  final int from;
  final int to;
  final String title;
  final String note;
}

class _ManualRelationDialog extends StatefulWidget {
  const _ManualRelationDialog();
  @override
  State<_ManualRelationDialog> createState() => _ManualRelationDialogState();
}

class _ManualRelationDialogState extends State<_ManualRelationDialog> {
  int _from = 1;
  int _to = 5;
  final _title = TextEditingController();
  final _note = TextEditingController();
  @override
  void dispose() {
    _title.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('新增手工关系'),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Text('起点'),
              const SizedBox(width: 12),
              DropdownButton<int>(
                value: _from,
                items: _items,
                onChanged: (v) => setState(() => _from = v!),
              ),
            ],
          ),
          Row(
            children: [
              const Text('终点'),
              const SizedBox(width: 12),
              DropdownButton<int>(
                value: _to,
                items: _items,
                onChanged: (v) => setState(() => _to = v!),
              ),
            ],
          ),
          TextField(
            controller: _title,
            decoration: const InputDecoration(labelText: '关系类型'),
          ),
          TextField(
            controller: _note,
            decoration: const InputDecoration(labelText: '备注'),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('取消'),
      ),
      FilledButton(onPressed: _save, child: const Text('保存')),
    ],
  );
  List<DropdownMenuItem<int>> get _items => [
    for (var i = 1; i <= 6; i++)
      DropdownMenuItem(value: i, child: Text(_positionName(i))),
  ];
  void _save() {
    if (_from == _to || _title.text.trim().isEmpty) return;
    Navigator.pop(
      context,
      _ManualDraft(_from, _to, _title.text.trim(), _note.text.trim()),
    );
  }
}
