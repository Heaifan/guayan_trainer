import 'package:flutter/material.dart';

import '../../../domain/relations/relation_record.dart';
import '../review_page_state.dart';
import '../review_relation_filter.dart';
import '../relation_display_model.dart';

/// 审卦关系总览。
///
/// 默认展示整卦当前可绘制关系；“全部 / 生克 / 特殊”只做全卦分类过滤。
/// 不再通过点击某一爻切换为单爻关系模式。
class ReviewRelationToolbar extends StatelessWidget {
  const ReviewRelationToolbar({
    super.key,
    required this.state,
    this.focusedPosition,
    this.selectedFilter = '全部',
    this.onFilterChanged,
    this.onRelationTap,
  });

  final ReviewPageState state;

  /// 保留旧 API 兼容；R1 全卦总览模式不再消费此值。
  final int? focusedPosition;
  final String selectedFilter;
  final ValueChanged<String>? onFilterChanged;

  /// 保留旧 API 兼容；关系详情入口后续可继续复用。
  final ValueChanged<String>? onRelationTap;

  @override
  Widget build(BuildContext context) {
    return _RelationFilterPanel(
      state: state,
      selectedFilter: selectedFilter,
      onFilterChanged: onFilterChanged,
    );
  }
}

class _RelationFilterPanel extends StatefulWidget {
  const _RelationFilterPanel({
    required this.state,
    required this.selectedFilter,
    this.onFilterChanged,
  });

  final ReviewPageState state;
  final String selectedFilter;
  final ValueChanged<String>? onFilterChanged;

  @override
  State<_RelationFilterPanel> createState() => _RelationFilterPanelState();
}

class _RelationFilterPanelState extends State<_RelationFilterPanel> {
  String get _selected => widget.selectedFilter;

  List<RelationRecord> get _relations => filterReviewRelationRecords(
    widget.state.relationRecords,
    focus: null,
    category: _selected,
  );

  Map<String, int> get _counts =>
      relationFilterCounts(widget.state.relationRecords);

  @override
  Widget build(BuildContext context) {
    const filters = ['全部', '生克', '特殊'];
    return Container(
      width: double.infinity,
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDCE5E1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                '关系',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF243744),
                  height: 1.2,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  '全卦关系',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    color: Color(0xFF71838B),
                    height: 1.2,
                  ),
                ),
              ),
              Text(
                '${_relations.length} 条',
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF71838B),
                ),
              ),
              const SizedBox(width: 8),
              Opacity(
                opacity: 0.45,
                child: Container(
                  width: 68,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F9F8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '＋连线',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF243744),
                      height: 1.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            child: Row(
              children: [
                for (var i = 0; i < filters.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      setState(() {});
                      widget.onFilterChanged?.call(filters[i]);
                    },
                    child: _FilterChip(
                      label: '${filters[i]} ${_counts[filters[i]] ?? 0}',
                      isActive: _selected == filters[i],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.isActive});

  final String label;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: label.length > 3 ? 58 : 46,
      height: 26,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFE6F0EB) : const Color(0xFFF3F7F5),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: isActive ? const Color(0xFF83A491) : const Color(0xFFD6E1DC),
          width: isActive ? 1.2 : 1.0,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: isActive ? const Color(0xFF243744) : const Color(0xFF71838B),
          height: 1.2,
        ),
      ),
    );
  }
}
