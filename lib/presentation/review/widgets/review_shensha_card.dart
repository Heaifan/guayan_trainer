import 'package:flutter/material.dart';

import '../review_page_state.dart';

/// 神煞卡：紧凑 4×5 网格，19 项完整显示，避免裁切核心卦盘。
class ReviewShenShaCard extends StatelessWidget {
  const ReviewShenShaCard({super.key, required this.state, this.onItemTap});

  final ReviewPageState state;
  final ValueChanged<ReviewShenShaItem>? onItemTap;

  @override
  Widget build(BuildContext context) {
    final items = state.shenShaItems;
    if (items.isEmpty) return _emptyCard();
    return Container(
      key: const Key('shensha_card'),
      height: 150,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDCE5E1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '神煞',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 2),
          Expanded(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 4,
                mainAxisExtent: 20,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return GestureDetector(
                  key: Key('shensha_${item.name}'),
                  onTap: onItemTap == null ? null : () => onItemTap!(item),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAF9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Semantics(
                      label: item.id ?? item.name,
                      child: Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF71838B),
                          height: 1.1,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyCard() => Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFDCE5E1)),
    ),
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('神煞', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        SizedBox(height: 12),
        Text('暂无神煞', style: TextStyle(fontSize: 10, color: Color(0xFF71838B))),
      ],
    ),
  );
}
