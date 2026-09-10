import 'package:flutter/material.dart';

import '../review_page_state.dart';

/// 神煞卡 · 数据驱动固定 4 列网格（3c00187 定稿：按实际数据渲染）。
///
/// 固定 4 列；按神煞实际数量渲染格数，不足 16 项不强制空占位
/// （避免卡片底部大片留白空洞），超过 16 项自动增加第 5 行。
/// 四行全部包含在 Card 内，禁止自由 Wrap 乱换行、禁止第 4 行越界。
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
