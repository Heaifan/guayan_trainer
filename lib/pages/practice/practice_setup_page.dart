import 'package:flutter/material.dart';

import '../../data/practice/wuxing_practice_question_generator.dart';
import '../../models/practice/practice_enums.dart';
import '../../theme/wuxing_colors.dart';
import '../../utils/practice_labels.dart';
import 'games/falling_block_game_page.dart';
import 'games/link_match_game_page.dart';
import 'practice_session_page.dart';

class PracticeSetupPage extends StatefulWidget {
  final String title;
  final String subtitle;
  final Set<PracticeTopic> initialTopics;
  final int initialQuestionCount;
  final String? recommendationText;
  final String? sessionTitle;
  final PracticeMode initialMode;

  const PracticeSetupPage({
    super.key,
    this.title = '综合练习',
    this.subtitle = '选择要训练的知识点，可单选或混合练习。',
    this.initialTopics = const {
      PracticeTopic.wuxingGenerate,
      PracticeTopic.wuxingControl,
    },
    this.initialQuestionCount = 12,
    this.recommendationText,
    this.sessionTitle,
    this.initialMode = PracticeMode.normal,
  });

  @override
  State<PracticeSetupPage> createState() => _PracticeSetupPageState();
}

class _PracticeSetupPageState extends State<PracticeSetupPage> {
  late Set<PracticeTopic> _selected;
  late int _questionCount;
  late PracticeMode _mode;

  static const _allTopics = PracticeTopic.values;
  static const _gameTopics = [PracticeTopic.wuxingGenerate, PracticeTopic.wuxingControl];
  static const _countOptions = [10, 12, 20];

  static const _gameRules = {
    PracticeTopic.wuxingGenerate: '五行相生：看到下落元素，点击它所生的元素',
    PracticeTopic.wuxingControl: '五行相克：看到下落元素，点击它所克的元素',
  };

  @override
  void initState() {
    super.initState();
    _selected = Set.from(widget.initialTopics);
    _questionCount = widget.initialQuestionCount;
    _mode = widget.initialMode;
  }

  void _toggle(PracticeTopic topic) {
    setState(() {
      if (_selected.contains(topic)) {
        _selected.remove(topic);
      } else {
        _selected.add(topic);
      }
    });
  }

  void _selectGameTopic(PracticeTopic topic) {
    setState(() => _selected = {topic});
  }

  void _onModeChanged(PracticeMode mode) {
    setState(() {
      _mode = mode;
      final singleModes = {PracticeMode.fallingBlock, PracticeMode.linkMatch};
      if (singleModes.contains(mode) && _selected.length != 1) {
        _selected = {PracticeTopic.wuxingGenerate};
      }
    });
  }

  void _start() {
    if (_selected.isEmpty) return;
    final isInfinite = _mode == PracticeMode.fallingBlock && _questionCount == 0;
    final count = isInfinite ? 100 : _questionCount;
    final questions = WuxingPracticeQuestionGenerator().generate(
      topics: _selected,
      count: count,
    );
    if (_mode == PracticeMode.normal) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PracticeSessionPage(
            sessionTitle: widget.sessionTitle ?? widget.title,
            topics: _selected,
            questions: questions,
          ),
        ),
      ).then((_) => setState(() {}));
    } else if (_mode == PracticeMode.fallingBlock) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => FallingBlockGamePage(
            topic: _selected.first,
            questions: questions,
            sessionTitle: widget.sessionTitle ?? widget.title,
            isInfinite: isInfinite,
          ),
        ),
      ).then((_) => setState(() {}));
    } else if (_mode == PracticeMode.linkMatch) {
      final matchQuestions = WuxingPracticeQuestionGenerator().generateUniqueForLinkMatch(
        topic: _selected.first,
      );
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => LinkMatchGamePage(
            topic: _selected.first,
            questions: matchQuestions,
            sessionTitle: widget.sessionTitle ?? widget.title,
          ),
        ),
      ).then((_) => setState(() {}));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_mode == PracticeMode.linkMatch ? '关系连连看'
          : _mode == PracticeMode.fallingBlock ? '方块速答'
          : widget.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _subtitleCard(),
          const SizedBox(height: 20),
          const Text('练习方式',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Row(
            children: [
              _modeChip(PracticeMode.normal, '普通练习'),
              const SizedBox(width: 12),
              _modeChip(PracticeMode.fallingBlock, '方块速答'),
              const SizedBox(width: 12),
              _modeChip(PracticeMode.linkMatch, '连连看'),
            ],
          ),
          const SizedBox(height: 20),
          if (_mode == PracticeMode.fallingBlock || _mode == PracticeMode.linkMatch)
            _gameTopicSection(),
          if (_mode == PracticeMode.normal) _normalTopicSection(),
          const SizedBox(height: 20),
          if (_mode == PracticeMode.linkMatch)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE9F5EF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF2F6F5E).withValues(alpha: 0.3)),
              ),
              child: const Text('连连看每局 25 对 · 共 50 张卡牌',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF2F6F5E))),
            ),
          if (_mode != PracticeMode.linkMatch) ...[
            const SizedBox(height: 20),
            const Text('题数',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            _countSelector(),
          ],
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _selected.isEmpty ? null : _start,
              child: Text(_mode == PracticeMode.fallingBlock ? '开始方块速答'
                  : _mode == PracticeMode.linkMatch ? '开始连连看'
                  : '开始练习'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _subtitleCard() {
    final text = _mode == PracticeMode.fallingBlock
        ? '五行元素从上方掉落，根据训练规则点击底部对应答案。\n'
            '考验你的快速反应和关系记忆。'
        : _mode == PracticeMode.linkMatch
            ? '上方为源元素，下方为目标答案。\n'
                '点击源元素，再点击对应的目标答案完成配对。'
            : widget.subtitle;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4DC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE0C28A)),
      ),
      child: Text(text,
          style: const TextStyle(fontSize: 14, color: Color(0xFF6B4E2E))),
    );
  }

  Widget _gameTopicSection() {
    final topic = _selected.length == 1 ? _selected.first : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('选择训练规则',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        ..._gameTopics.map((t) {
          final sel = t == topic;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Card(
              color: sel ? const Color(0xFFE9F5EF) : null,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: sel ? const Color(0xFF2F6F5E) : const Color(0xFFE0C28A),
                  width: sel ? 2 : 1,
                ),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _selectGameTopic(t),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Icon(
                        sel ? Icons.radio_button_checked : Icons.radio_button_off,
                        color: sel ? const Color(0xFF2F6F5E) : const Color(0xFFB8A98A),
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(practiceTopicLabel(t),
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: sel ? const Color(0xFF2F6F5E) : null,
                                )),
                            const SizedBox(height: 2),
                            Text(
                              _gameRules[t]!,
                              style: TextStyle(
                                fontSize: 12,
                                color: sel ? const Color(0xFF2F6F5E).withValues(alpha: 0.7) : const Color(0xFF6B4E2E),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _normalTopicSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('选择练习内容',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        ..._allTopics.map((t) => CheckboxListTile(
              title: Text('${practiceTopicLabel(t)}（${practicePoolSize(t)}题）'),
              value: _selected.contains(t),
              onChanged: (_) => _toggle(t),
              activeColor: const Color(0xFF2F6F5E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: _selected.contains(t) ? const Color(0xFF2F6F5E) : const Color(0xFFE0C28A),
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            )),
      ],
    );
  }

  Widget _countSelector() {
    final opts = _mode == PracticeMode.fallingBlock
        ? [10, 12, 20, 0]
        : _countOptions;
    return Wrap(
      spacing: 10, runSpacing: 10,
      children: opts.map((n) {
        final sel = n == _questionCount;
        return ChoiceChip(
          label: Text(n == 0 ? '无限' : '$n 题'),
          selected: sel,
          onSelected: (_) => setState(() => _questionCount = n),
          selectedColor: const Color(0xFF2F6F5E),
          labelStyle: TextStyle(
            color: sel ? Colors.white : null,
            fontWeight: FontWeight.w700,
          ),
        );
      }).toList(),
    );
  }

  Widget _modeChip(PracticeMode mode, String label) {
    final sel = mode == _mode;
    return Expanded(
      child: ChoiceChip(
        label: Text(label,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: sel ? Colors.white : null,
            )),
        selected: sel,
        onSelected: (_) => _onModeChanged(mode),
        selectedColor: const Color(0xFF2F6F5E),
      ),
    );
  }
}
