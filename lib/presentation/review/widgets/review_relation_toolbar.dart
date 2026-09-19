import 'package:flutter/material.dart';

import '../../../domain/relations/relation_record.dart';
import '../../../domain/relation_endpoint.dart';
import '../review_page_state.dart';
import '../review_relation_filter.dart';
import '../relation_display_model.dart';

/// 关系工具栏（审卦一屏版总 SVG：关系、全部/重点/生克等）。
///
/// 包含标题、副标题、＋连线按钮，以及可滚动的 Chip 列表。
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
  final int? focusedPosition;
  final String selectedFilter;
  final ValueChanged<String>? onFilterChanged;
  final ValueChanged<String>? onRelationTap;

  @override
  Widget build(BuildContext context) {
    return _RelationFilterPanel(
      state: state,
      focusedPosition: focusedPosition,
      selectedFilter: selectedFilter,
      onFilterChanged: onFilterChanged,
      onRelationTap: onRelationTap,
    );
  }
}

class _RelationFilterPanel extends StatefulWidget {
  const _RelationFilterPanel({
    required this.state,
    this.focusedPosition,
    required this.selectedFilter,
    this.onFilterChanged,
    this.onRelationTap,
  });

  final ReviewPageState state;
  final int? focusedPosition;
  final String selectedFilter;
  final ValueChanged<String>? onFilterChanged;
  final ValueChanged<String>? onRelationTap;

  @override
  State<_RelationFilterPanel> createState() => _RelationFilterPanelState();
}

class _RelationFilterPanelState extends State<_RelationFilterPanel> {
  String get _selected => widget.selectedFilter;

  List<RelationRecord> get _relations {
    if (widget.focusedPosition == null) return const [];
    return filterReviewRelationRecords(
      widget.state.relationRecords,
      focus: YaoEndpoint(LineScope.original, widget.focusedPosition!),
      category: _selected,
    );
  }

  int get _totalCount =>
      relationFilterCounts(widget.state.relationRecords)['全部'] ?? 0;

  Map<String, int> get _counts =>
      relationFilterCounts(widget.state.relationRecords);

  @override
  Widget build(BuildContext context) {
    final filters = ['全部', '生克', '特殊'];
    return Container(
      width: double.infinity,
      height: widget.focusedPosition == null ? 80 : 122,
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
              Expanded(
                child: Text(
                  widget.focusedPosition == null
                      ? '当前卦共 $_totalCount 条关系，点击某一爻后显示相关关系'
                      : '当前聚焦：${reviewLinePositionName(widget.focusedPosition!)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF71838B),
                    height: 1.2,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                widget.focusedPosition == null
                    ? '$_totalCount 条'
                    : '${_relations.length} 条',
                style: const TextStyle(fontSize: 10, color: Color(0xFF71838B)),
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
          if (widget.focusedPosition != null) ...[
            const SizedBox(height: 8),
            SizedBox(
              height: 25,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _relations.length,
                separatorBuilder: (context, index) => const SizedBox(width: 6),
                itemBuilder: (context, index) {
                  final model = RelationDisplayModel.fromRecord(
                    _relations[index],
                  );
                  return InkWell(
                    onTap: () => widget.onRelationTap?.call(model.record.id),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F4EE),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE4D8C8)),
                      ),
                      child: Text(
                        model.type.displayName,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF5D5146),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
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
