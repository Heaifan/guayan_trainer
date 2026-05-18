import 'package:flutter/material.dart';

import '../../data/wuxing_self_center_data.dart';
import '../../theme/wuxing_colors.dart';
import '../../widgets/wuxing_self_center_wheel.dart';

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
    return Scaffold(
      appBar: AppBar(title: const Text('以我为中心')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _introCard(),
          const SizedBox(height: 16),
          _selector(),
          const SizedBox(height: 16),
          _wheelSection(),
          const SizedBox(height: 20),
          _explanationsCard(),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4DC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0C28A)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('以我为中心',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          SizedBox(height: 8),
          Text(
            '断五行关系时，先定一个「我」。'
            '看其它五行与我的关系：生我、我生、克我、我克、同我。'
            '对应旺、相、休、囚、死。',
            style: TextStyle(fontSize: 14, height: 1.5, color: Color(0xFF6B4E2E)),
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
                horizontal: selected ? 20 : 14,
                vertical: selected ? 12 : 8,
              ),
              decoration: BoxDecoration(
                color: selected ? WuxingColors.getColor(e) : WuxingColors.getSoftColor(e),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: selected
                      ? WuxingColors.getColor(e)
                      : WuxingColors.getBorderColor(e).withValues(alpha: 0.4),
                  width: selected ? 2.5 : 1.5,
                ),
              ),
              child: Text(e,
                  style: TextStyle(
                      fontSize: selected ? 18 : 15,
                      fontWeight: FontWeight.w900,
                      color: selected
                          ? WuxingColors.textOnColor(e)
                          : WuxingColors.getColor(e))),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _wheelSection() {
    return SizedBox(
      height: 340,
      child: WuxingSelfCenterWheel(selfElement: _self),
    );
  }

  Widget _explanationsCard() {
    final relations = wuxingSelfCenterRelations[_self]!;
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
          const Text('当前关系说明',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          ...relationOrder.map((r) {
            if (r == '同我') {
              final other = relations[r]!;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    _chip(other),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('$r ｜ ${relationStateMap[r]}　${selfCenterRelationSentence(_self, r, other)}',
                          style: const TextStyle(fontSize: 14, color: Color(0xFF3B2A1A))),
                    ),
                  ],
                ),
              );
            }
            final other = relations[r]!;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  _chip(other),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('$r ｜ ${relationStateMap[r]}　${selfCenterRelationSentence(_self, r, other)}',
                        style: const TextStyle(fontSize: 14, color: Color(0xFF3B2A1A))),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _chip(String element) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: WuxingColors.getColor(element),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(element,
          style: TextStyle(
              color: WuxingColors.textOnColor(element),
              fontWeight: FontWeight.w800,
              fontSize: 14)),
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
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          ...['旺', '相', '休', '囚', '死'].map((s) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 40,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _stateColor(s),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(s,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 13)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(stateDescriptions[s]!,
                          style: const TextStyle(fontSize: 14, color: Color(0xFF6B4E2E))),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Color _stateColor(String state) {
    switch (state) {
      case '旺': return const Color(0xFF2F6F5E);
      case '相': return const Color(0xFF3E7DBF);
      case '休': return const Color(0xFFB9770E);
      case '囚': return const Color(0xFF8A6A32);
      case '死': return const Color(0xFF6B4E2E);
      default: return const Color(0xFF6B4E2E);
    }
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
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          ...selfCenterRows.map((row) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(row,
                    style: const TextStyle(
                        fontSize: 14, color: Color(0xFF3B2A1A))),
              )),
        ],
      ),
    );
  }
}
