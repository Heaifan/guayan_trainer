import 'package:flutter/material.dart';

import '../../data/wuxing_self_center_data.dart';
import '../../services/question_generator.dart';
import '../../theme/wuxing_colors.dart';
import '../../widgets/wuxing_self_center_wheel.dart';
import '../practice/training_page.dart';

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
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _introCard(),
          const SizedBox(height: 12),
          _selector(),
          const SizedBox(height: 10),
          SizedBox(
            height: 300,
            child: WuxingSelfCenterWheel(selfElement: _self),
          ),
          const SizedBox(height: 10),
          _explanationsCard(),
          const SizedBox(height: 12),
          _stateTable(),
          const SizedBox(height: 12),
          _quickRefCard(),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const TrainingPage(
                      title: '以我为中心练习',
                      mode: TrainingMode.wuxingSelfCenter,
                    ),
                  ),
                );
              },
              child: const Text('开始以我为中心练习'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _introCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4DC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0C28A)),
      ),
      child: const Text(
        '断五行关系时，先定一个「我」。\n'
        '看其它五行与我的关系：生我、我生、克我、我克、同我。\n'
        '对应旺、相、休、囚、死。',
        style: TextStyle(fontSize: 14, height: 1.5, color: Color(0xFF6B4E2E)),
      ),
    );
  }

  Widget _selector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _elements.map((e) {
        final sel = e == _self;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: GestureDetector(
            onTap: () => setState(() => _self = e),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 60,
              height: 46,
              decoration: BoxDecoration(
                color: sel ? WuxingColors.getColor(e) : WuxingColors.getSoftColor(e),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: sel ? WuxingColors.getColor(e)
                      : WuxingColors.getBorderColor(e).withValues(alpha: 0.4),
                  width: sel ? 2.5 : 1.5,
                ),
              ),
              child: Center(
                child: Text(e,
                    style: TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w900,
                        color: sel ? WuxingColors.textOnColor(e) : WuxingColors.getColor(e))),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _explanationsCard() {
    final relations = wuxingSelfCenterRelations[_self]!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0C28A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('当前关系说明',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          ...relationOrder.map((r) {
            final other = relations[r]!;
            return _relationRow(other, r, relationStateMap[r]!,
                selfCenterRelationSentence(_self, r, other));
          }),
        ],
      ),
    );
  }

  Widget _relationRow(String other, String relation, String state, String sentence) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: WuxingColors.getColor(other),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(other,
                style: TextStyle(
                    color: WuxingColors.textOnColor(other),
                    fontWeight: FontWeight.w800, fontSize: 13)),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text('$relation · $state　$sentence',
                style: const TextStyle(fontSize: 13, color: Color(0xFF3B2A1A))),
          ),
        ],
      ),
    );
  }

  Widget _stateTable() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0C28A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('旺相休囚死',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          ...['旺', '相', '休', '囚', '死'].map((s) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _stateBadge(s),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(stateDescriptions[s]!,
                          style: const TextStyle(fontSize: 13, color: Color(0xFF6B4E2E))),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _stateBadge(String state) {
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
      width: 34,
      padding: const EdgeInsets.symmetric(vertical: 1),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
      child: Text(state,
          textAlign: TextAlign.center,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
    );
  }

  Widget _quickRefCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0C28A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('五行速查',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          ...selfCenterRows.map((row) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 1),
                child: Text(row,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF3B2A1A))),
              )),
        ],
      ),
    );
  }
}
