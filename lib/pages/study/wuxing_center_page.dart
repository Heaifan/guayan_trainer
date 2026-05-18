import 'package:flutter/material.dart';

import '../../data/wuxing_self_center_data.dart';
import '../../theme/wuxing_colors.dart';

class WuxingCenterPage extends StatefulWidget {
  const WuxingCenterPage({super.key});

  @override
  State<WuxingCenterPage> createState() => _WuxingCenterPageState();
}

class _WuxingCenterPageState extends State<WuxingCenterPage> {
  String _self = '木';

  static const _elements = ['木', '火', '土', '金', '水'];

  @override
  Widget build(BuildContext context) {
    final relations = wuxingSelfCenterRelations[_self]!;

    return Scaffold(
      appBar: AppBar(title: const Text('以我为中心')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _introCard(),
          const SizedBox(height: 16),
          _selector(),
          const SizedBox(height: 20),
          _diagramCard(relations),
          const SizedBox(height: 20),
          _stateTable(),
          const SizedBox(height: 20),
          _quickRefCard(),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('以我为中心练习'),
                    content: const Text('以我为中心练习即将开放，敬请期待。'),
                    actions: [
                      FilledButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('知道了'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('开始以我为中心练习'),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _introCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4DC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0C28A)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('以我为中心',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          SizedBox(height: 10),
          Text(
            '断五行关系时，先定一个「我」。\n\n'
            '看其它五行与「我」的关系：\n'
            '生我、我生、克我、我克、同我。\n\n'
            '这五种关系，对应旺、相、休、囚、死。',
            style: TextStyle(fontSize: 15, height: 1.6, color: Color(0xFF6B4E2E)),
          ),
        ],
      ),
    );
  }

  Widget _selector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _elements.map((e) {
        final selected = e == _self;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: GestureDetector(
            onTap: () => setState(() => _self = e),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(
                horizontal: selected ? 22 : 16,
                vertical: selected ? 14 : 10,
              ),
              decoration: BoxDecoration(
                color: selected
                    ? WuxingColors.getColor(e)
                    : WuxingColors.getSoftColor(e),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected
                      ? WuxingColors.getColor(e)
                      : WuxingColors.getBorderColor(e).withValues(alpha: 0.4),
                  width: selected ? 2.5 : 1.5,
                ),
              ),
              child: Text(
                e,
                style: TextStyle(
                  fontSize: selected ? 20 : 16,
                  fontWeight: FontWeight.w900,
                  color: selected
                      ? WuxingColors.textOnColor(e)
                      : WuxingColors.getColor(e),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _diagramCard(Map<String, String> relations) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0C28A)),
      ),
      child: Column(
        children: [
          Text('我为 $_self',
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w900,
                  color: Color(0xFF3B2A1A))),
          const SizedBox(height: 16),
          ...relationOrder.map((r) {
            final other = relations[r]!;
            final state = relationStateMap[r]!;
            final desc = stateDescriptions[state]!;
            final expl = relationExplanation(_self, other, r);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  SizedBox(
                    width: 48,
                    child: _stateChip(state),
                  ),
                  const SizedBox(width: 8),
                  _elementBadge(other),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$r · $state',
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 14)),
                        Text(desc,
                            style: const TextStyle(
                                fontSize: 13, color: Color(0xFF6B4E2E))),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _stateChip(String state) {
    Color bg;
    switch (state) {
      case '旺': bg = const Color(0xFF2F6F5E); break;
      case '相': bg = const Color(0xFF3E7DBF); break;
      case '休': bg = const Color(0xFFB9770E); break;
      case '囚': bg = const Color(0xFF8A6A32); break;
      case '死': bg = const Color(0xFF6B4E2E); break;
      default: bg = const Color(0xFF6B4E2E);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(state,
          style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 13)),
    );
  }

  Widget _elementBadge(String element) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: WuxingColors.getColor(element),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(element,
          style: TextStyle(
              color: WuxingColors.textOnColor(element),
              fontWeight: FontWeight.w800,
              fontSize: 15)),
    );
  }

  Widget _stateTable() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0C28A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('旺相休囚死',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          ...['旺', '相', '休', '囚', '死'].map((s) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _stateChip(s),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(stateDescriptions[s]!,
                          style: const TextStyle(
                              fontSize: 14, height: 1.4, color: Color(0xFF6B4E2E))),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _quickRefCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0C28A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('五行速查',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          ...selfCenterRows.map((row) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Text(row,
                    style: const TextStyle(
                        fontSize: 14, height: 1.5, color: Color(0xFF3B2A1A))),
              )),
        ],
      ),
    );
  }
}
