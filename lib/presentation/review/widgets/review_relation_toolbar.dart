import 'package:flutter/material.dart';

import '../../../domain/relation_endpoint.dart';
import '../../../domain/relations/relation_record.dart';
import '../relation_display_model.dart';
import '../review_page_state.dart';
import '../review_relation_filter.dart';

class ReviewRelationToolbar extends StatelessWidget {
  const ReviewRelationToolbar({
    super.key, required this.state, this.focusedPosition,
    this.selectedFilter = '全部', this.onFilterChanged, this.onRelationTap,
  });
  final ReviewPageState state;
  final int? focusedPosition;
  final String selectedFilter;
  final ValueChanged<String>? onFilterChanged;
  final ValueChanged<String>? onRelationTap;

  @override
  Widget build(BuildContext context) => _RelationFilterPanel(
    state: state, focusedPosition: focusedPosition,
    selectedFilter: selectedFilter, onFilterChanged: onFilterChanged,
    onRelationTap: onRelationTap,
  );
}

class _RelationFilterPanel extends StatelessWidget {
  const _RelationFilterPanel({
    required this.state, this.focusedPosition, required this.selectedFilter,
    this.onFilterChanged, this.onRelationTap,
  });
  final ReviewPageState state;
  final int? focusedPosition;
  final String selectedFilter;
  final ValueChanged<String>? onFilterChanged;
  final ValueChanged<String>? onRelationTap;

  RelationEndpoint? get _focus => focusedPosition == null
      ? null : YaoEndpoint(LineScope.original, focusedPosition!);
  List<RelationRecord> get _scope => filterReviewRelationRecords(
    state.relationRecords, focus: _focus, category: '全部',
  );
  List<RelationRecord> get _relations => filterReviewRelationRecords(
    state.relationRecords, focus: _focus, category: selectedFilter,
  );
  List<String> get _stateLabels =>
      focusedPosition == null ? const [] : state.lineAt(focusedPosition!).stateLabels;

  @override
  Widget build(BuildContext context) {
    const filters = ['全部', '生克', '特殊'];
    final counts = relationFilterCounts(_scope);
    return Container(
      width: double.infinity, height: focusedPosition == null ? 80 : 122,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDCE5E1)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          const Text('关系', style: TextStyle(
            fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF243744),
          )),
          const SizedBox(width: 12),
          Expanded(child: Text(
            focusedPosition == null
              ? '全卦关系 · 点击某爻查看当前爻关系'
              : '当前聚焦：${_lineName(focusedPosition!)}',
            maxLines: 1, overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10, color: Color(0xFF71838B)),
          )),
          Text('${_relations.length} 条',
            style: const TextStyle(fontSize: 10, color: Color(0xFF71838B))),
          const SizedBox(width: 8),
          Opacity(opacity: .45, child: Container(
            width: 68, height: 28, alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFF7F9F8), borderRadius: BorderRadius.circular(8),
            ),
            child: const Text('＋连线', style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF243744),
            )),
          )),
        ]),
        const Spacer(),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            for (var i = 0; i < filters.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              GestureDetector(
                onTap: () => onFilterChanged?.call(filters[i]),
                child: _FilterChip(
                  label: '${filters[i]} ${counts[filters[i]] ?? 0}',
                  isActive: selectedFilter == filters[i],
                ),
              ),
            ],
          ]),
        ),
        if (focusedPosition != null) ...[
          const SizedBox(height: 8),
          SizedBox(height: 25, child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _relations.length + (_stateLabels.isEmpty ? 0 : 1),
            separatorBuilder: (_, __) => const SizedBox(width: 6),
            itemBuilder: (_, index) {
              if (_stateLabels.isNotEmpty && index == 0) {
                return _pill('状态 ${_stateLabels.join(' · ')}',
                  const Color(0xFF536575), const Color(0xFFF1F4F8));
              }
              final i = index - (_stateLabels.isEmpty ? 0 : 1);
              final model = RelationDisplayModel.fromRecord(_relations[i]);
              return InkWell(
                onTap: () => onRelationTap?.call(model.record.id),
                child: _pill(model.type.displayName,
                  const Color(0xFF5D5146), const Color(0xFFF8F4EE)),
              );
            },
          )),
        ],
      ]),
    );
  }

  Widget _pill(String text, Color color, Color background) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9), alignment: Alignment.center,
    decoration: BoxDecoration(
      color: background, borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withValues(alpha: .20)),
    ),
    child: Text(text, style: TextStyle(fontSize: 10, color: color)),
  );
  String _lineName(int p) => switch (p) {
    1 => '初爻', 2 => '二爻', 3 => '三爻',
    4 => '四爻', 5 => '五爻', 6 => '上爻', _ => '${p}爻',
  };
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.isActive});
  final String label;
  final bool isActive;
  @override
  Widget build(BuildContext context) => Container(
    width: label.length > 3 ? 58 : 46, height: 26, alignment: Alignment.center,
    decoration: BoxDecoration(
      color: isActive ? const Color(0xFFE6F0EB) : const Color(0xFFF3F7F5),
      borderRadius: BorderRadius.circular(13),
      border: Border.all(
        color: isActive ? const Color(0xFF83A491) : const Color(0xFFD6E1DC),
        width: isActive ? 1.2 : 1,
      ),
    ),
    child: Text(label, style: TextStyle(
      fontSize: 10,
      color: isActive ? const Color(0xFF243744) : const Color(0xFF71838B),
    )),
  );
}
