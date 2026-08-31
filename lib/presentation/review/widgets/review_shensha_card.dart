import 'package:flutter/material.dart';

import '../../casting/casting_tokens.dart';
import '../review_page_state.dart';

/// 神煞卡 · FIXED 4×4 定稿版（审卦首屏 R4 SVG：402×128）。
///
/// 真正固定的 4 列 × 4 行 Grid：格宽 89、格高 18、列距 6、行距 4，
/// 四行全部包含在 Card 内，禁止自由 Wrap 乱换行、禁止第 4 行越界。
/// 数据不足 16 个时留空占位（保持 4×4 几何）；超过 16 个才增加第 5 行。
class ReviewShenShaCard extends StatelessWidget {
  const ReviewShenShaCard({super.key, required this.state});

  final ReviewPageState state;

  @override
  Widget build(BuildContext context) {
    final items = state.shenShaItems;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
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
              color: Color(0xFF243744),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            const Text(
              '暂无神煞数据（排盘引擎接入后展示）',
              style: TextStyle(
                fontSize: 10,
                color: Color(0xFF71838B),
                height: 1.4,
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 7,
                mainAxisExtent: 20,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return Container(
                  key: Key('shensha_${items[index].name}'),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAF9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    items[index].label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF71838B),
                      height: 1.1,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
