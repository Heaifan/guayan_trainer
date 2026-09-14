import 'package:flutter/material.dart';

import '../../casting/casting_tokens.dart';

/// 关系工具栏（审卦一屏版总 SVG：关系、全部/重点/生克等）。
///
/// 包含标题、副标题、＋连线按钮，以及可滚动的 Chip 列表。
class ReviewRelationToolbar extends StatelessWidget {
  const ReviewRelationToolbar({super.key});

  @override
  Widget build(BuildContext context) {
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
              const Text(
                '筛选卦盘上的关系箭头',
                style: TextStyle(
                  fontSize: 10,
                  color: Color(0xFF71838B),
                  height: 1.2,
                ),
              ),
              const Spacer(),
              Container(
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
            ],
          ),
          const Spacer(),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            child: Row(
              children: [
                const _FilterChip(label: '全部', isActive: true),
                const SizedBox(width: 8),
                const _FilterChip(label: '重点', isActive: false),
                const SizedBox(width: 8),
                const _FilterChip(label: '生克', isActive: false),
                const SizedBox(width: 8),
                const _FilterChip(label: '冲合', isActive: false),
                const SizedBox(width: 8),
                const _FilterChip(label: '墓库', isActive: false),
                const SizedBox(width: 8),
                const _FilterChip(label: '月日', isActive: false),
                const SizedBox(width: 8),
                const _FilterChip(label: '动变', isActive: false),
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
      width: 46,
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
