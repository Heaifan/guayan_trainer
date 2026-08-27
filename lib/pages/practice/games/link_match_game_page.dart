import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../data/wuxing_data.dart';
import '../../../models/mistake_item.dart';
import '../../../models/practice/practice_answer_record.dart';
import '../../../models/practice/practice_enums.dart';
import '../../../models/practice/practice_question.dart';
import '../../../services/mistake_store.dart';
import '../../../theme/wuxing_colors.dart';

/// 关系连连看 — 25 对配对消除。
/// 源牌显示元素，目标牌显示"生火"/"克土"关系卡。
class LinkMatchGamePage extends StatefulWidget {
  final PracticeTopic topic;
  final List<PracticeQuestion> questions;
  final String sessionTitle;

  const LinkMatchGamePage({
    super.key,
    required this.topic,
    required this.questions,
    this.sessionTitle = '关系连连看',
  });

  @override
  State<LinkMatchGamePage> createState() => _LinkMatchGamePageState();
}

class _SourceCard {
  final int uid;
  final PracticeQuestion question;
  bool matched = false;
  _SourceCard(this.uid, this.question);
  String get element => question.sourceElement ?? '';
}

class _AnswerCard {
  final int uid;
  final String display;
  final String element;
  bool matched = false;
  _AnswerCard(this.uid, this.display, this.element);
}

class _LinkMatchGamePageState extends State<LinkMatchGamePage>
    with SingleTickerProviderStateMixin {
  static const int lifeCount = 5;

  late final List<_SourceCard> _sources;
  late final List<_AnswerCard> _answers;

  _SourceCard? _selected;
  int? _flashSourceUid;
  int? _flashAnswerUid;
  bool _flashCorrect = false;

  bool _feedbackVisible = false;
  String _feedbackText = '';
  bool _feedbackCorrect = false;

  int _score = 0;
  int _combo = 0;
  int _maxCombo = 0;
  int _lives = lifeCount;
  int _errorCount = 0;

  final List<PracticeAnswerRecord> _records = [];
  late final DateTime _sessionStartedAt;
  String _timeStr = '00:00';
  Timer? _timer;
  bool _gameOver = false;
  bool _showResult = false;

  @override
  void initState() {
    super.initState();
    _sessionStartedAt = DateTime.now();

    // Expand 5 questions → 25 pairs
    final expanded = <PracticeQuestion>[];
    for (int i = 0; i < 5; i++) expanded.addAll(widget.questions);

    _sources = expanded.asMap().entries
        .map((e) => _SourceCard(e.key, e.value)).toList()
      ..shuffle();

    _answers = expanded.asMap().entries
        .map((e) {
          final el = e.value.correctAnswer;
          final display = widget.topic == PracticeTopic.wuxingControl ? '克$el' : '生$el';
          return _AnswerCard(e.key, display, el);
        }).toList()
      ..shuffle();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final d = DateTime.now().difference(_sessionStartedAt);
      setState(() {
        _timeStr = '${(d.inSeconds ~/ 60).toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  bool get _isBreak => widget.topic == PracticeTopic.wuxingControl;
  int get _matchedCount => _sources.where((c) => c.matched).length;
  int get _totalPairs => _sources.length;

  // ──────────────── 交互 ────────────────

  void _selectSource(_SourceCard card) {
    if (_gameOver || _showResult || card.matched) return;
    setState(() => _selected = card);
  }

  void _selectAnswer(_AnswerCard aCard) {
    if (_gameOver || _showResult || _selected == null) return;
    final src = _selected!;
    if (src.matched || aCard.matched) return;

    final q = src.question;
    final correct = aCard.element == q.correctAnswer;

    final now = DateTime.now();
    _records.add(PracticeAnswerRecord(
      question: q,
      selectedAnswer: aCard.display,
      isCorrect: correct,
      isTimeout: false,
      isHesitant: false,
      reactionMs: 0,
      answeredAt: now,
    ));

    if (correct) {
      src.matched = true;
      aCard.matched = true;
      _score += 10 + _combo;
      _combo += 1;
      _maxCombo = math.max(_maxCombo, _combo);

      setState(() {
        _selected = null;
        _flashSourceUid = src.uid;
        _flashAnswerUid = aCard.uid;
        _flashCorrect = true;
        _feedbackText = _isBreak ? '${src.element}克${aCard.element}' : '${src.element}生${aCard.element}';
        _feedbackCorrect = true;
        _feedbackVisible = true;
      });

      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) setState(() { _flashSourceUid = null; _flashAnswerUid = null; _feedbackVisible = false; });
      });

      if (_matchedCount >= _totalPairs) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) setState(() => _showResult = true);
        });
      }
    } else {
      _lives -= 1;
      _combo = 0;
      _errorCount += 1;

      MistakeStore.instance.addOrUpdateMistake(MistakeItem(
        id: 'linkmatch_${q.id}',
        module: q.domain.name,
        topic: q.topic.name,
        questionText: q.prompt,
        sourceElement: q.sourceElement ?? '',
        correctAnswer: q.correctAnswer,
        wrongAnswer: aCard.display,
        relationText: q.relationText,
        practiceStyle: PracticeMode.linkMatch.name,
        wrongCount: 1,
        explanation: q.explanation,
        reactionMs: 0,
        isHesitant: false,
        createdAt: now,
        updatedAt: now,
      ));

      setState(() {
        _selected = null;
        _flashSourceUid = src.uid;
        _flashAnswerUid = aCard.uid;
        _flashCorrect = false;
        _feedbackText = '正确：${q.correctAnswer}';
        _feedbackCorrect = false;
        _feedbackVisible = true;
      });

      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) setState(() { _flashSourceUid = null; _flashAnswerUid = null; _feedbackVisible = false; });
        if (_lives <= 0) {
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) setState(() => _showResult = true);
          });
        }
      });
    }
  }

  // ──────────────── 构建 ────────────────

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(title: Text(widget.sessionTitle), centerTitle: true),
          body: Column(
            children: [
              _hud(),
              Expanded(child: _gameArea()),
            ],
          ),
        ),
        if (_showResult) _resultOverlay(),
      ],
    );
  }

  Widget _hud() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: const Color(0xFFFFF4DC),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('❤️$_lives', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
          Text('$_timeStr', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF6B4E2E))),
          Text('✗$_errorCount', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _errorCount > 0 ? const Color(0xFFC0392B) : null)),
          Text('$_matchedCount/$_totalPairs', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: const Color(0xFF2F6F5E))),
        ],
      ),
    );
  }

  Widget _gameArea() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      color: _isBreak ? const Color(0xFFFFF9F5) : const Color(0xFFFAF8F5),
      child: Column(
        children: [
          _ruleBar(),
          const SizedBox(height: 4),
          _sectionLabel('源元素'),
          Expanded(flex: 5, child: _scrollCards(_sources, isSource: true)),
          _feedbackBar(),
          _sectionLabel('目标关系'),
          Expanded(flex: 5, child: _scrollCards(_answers, isSource: false)),
        ],
      ),
    );
  }

  Widget _ruleBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Text(
        _isBreak ? '五行相克：点击源牌，再点击对应的关系牌。' : '五行相生：点击源牌，再点击对应的关系牌。',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12, fontWeight: FontWeight.w700,
          color: _isBreak ? const Color(0xFF9C3B2E) : const Color(0xFF2F6F5E),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 2, bottom: 2),
      child: Text(text, style: const TextStyle(
        fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF6B4E2E),
      )),
    );
  }

  Widget _scrollCards(List cards, {required bool isSource}) {
    if (cards.isEmpty || cards.every((c) => c is _SourceCard ? c.matched : (c as _AnswerCard).matched)) {
      return const SizedBox.shrink();
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Wrap(
        spacing: 6, runSpacing: 6,
        alignment: WrapAlignment.center,
        children: cards.map((c) {
          if (c is _SourceCard) {
            if (c.matched) return const SizedBox(width: 48, height: 48);
            return _sourceWidget(c);
          }
          if (c is _AnswerCard) {
            if (c.matched) return const SizedBox(width: 48, height: 48);
            return _answerWidget(c);
          }
          return const SizedBox.shrink();
        }).toList(),
      ),
    );
  }

  Widget _sourceWidget(_SourceCard card) {
    final el = card.element;
    final sel = _selected == card;
    final flashing = _flashSourceUid == card.uid;
    final color = WuxingColors.getColor(el);
    return GestureDetector(
      onTap: () => _selectSource(card),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 48, height: 48,
        decoration: BoxDecoration(
          color: flashing
              ? (_flashCorrect ? const Color(0xFFE9F5EF) : const Color(0xFFFFEFEA))
              : (sel ? color.withValues(alpha: 0.25) : WuxingColors.getSoftColor(el)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: flashing
                ? (_flashCorrect ? const Color(0xFF2F6F5E) : const Color(0xFFC0392B))
                : (sel ? color : color.withValues(alpha: 0.3)),
            width: sel ? 2.5 : 1.2,
          ),
        ),
        child: Center(child: Text(el, style: TextStyle(
          fontSize: 20, fontWeight: FontWeight.w900,
          color: sel ? color : color.withValues(alpha: 0.8),
        ))),
      ),
    );
  }

  Widget _answerWidget(_AnswerCard card) {
    final flashing = _flashAnswerUid == card.uid;
    final color = flashing
        ? (_flashCorrect ? const Color(0xFF2F6F5E) : const Color(0xFFC0392B))
        : WuxingColors.getColor(card.element);
    return GestureDetector(
      onTap: _selected != null ? () => _selectAnswer(card) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 58, height: 48,
        decoration: BoxDecoration(
          color: flashing
              ? (_flashCorrect ? const Color(0xFFE9F5EF) : const Color(0xFFFFEFEA))
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: flashing ? 1.0 : 0.4),
            width: flashing ? 2.5 : 1.2,
          ),
        ),
        child: Center(child: Text(card.display, style: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w800,
          color: color,
        ))),
      ),
    );
  }

  Widget _feedbackBar() {
    const h = 32.0;
    if (!_feedbackVisible && _selected == null) {
      return SizedBox(height: h,
        child: Center(child: Text('点击上方源牌开始',
            style: TextStyle(fontSize: 12, color: Color(0xFFB8A98A)))),
      );
    }
    if (!_feedbackVisible && _selected != null) {
      final el = _selected!.element;
      return SizedBox(height: h,
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: WuxingColors.getColor(el).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('已选 $el',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800,
                        color: WuxingColors.getColor(el))),
              ),
              const SizedBox(width: 6),
              const Text('→ 点下方关系牌',
                  style: TextStyle(fontSize: 12, color: Color(0xFF6B4E2E))),
            ],
          ),
        ),
      );
    }
    return Container(
      height: h,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: _feedbackCorrect
            ? (_isBreak ? const Color(0xFFFFF0E8) : const Color(0xFFE9F5EF))
            : const Color(0xFFFFEFEA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _feedbackCorrect
              ? (_isBreak ? const Color(0xFF9C3B2E) : const Color(0xFF2F6F5E))
              : const Color(0xFFC0392B),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(_feedbackCorrect ? (_isBreak ? '⚡' : '❤️') : '✗ ',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900,
                  color: _feedbackCorrect
                      ? (_isBreak ? const Color(0xFF9C3B2E) : const Color(0xFF2F6F5E))
                      : const Color(0xFFC0392B))),
          const SizedBox(width: 4),
          Flexible(
            child: Text(_feedbackText,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                    color: _feedbackCorrect
                        ? (_isBreak ? const Color(0xFF9C3B2E) : const Color(0xFF2F6F5E))
                        : const Color(0xFFC0392B)),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  // ──────────────── 结算 ────────────────

  Widget _resultOverlay() {
    final d = DateTime.now().difference(_sessionStartedAt);
    final m = (d.inSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    final total = _totalPairs;
    final correct = _matchedCount;
    final accuracy = total > 0 ? (correct / total * 100) : 0;

    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🎉', style: TextStyle(fontSize: 36)),
              const SizedBox(height: 8),
              Text(_matchedCount >= _totalPairs ? '全部配对完成！' : '结束',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF2F6F5E))),
              const SizedBox(height: 16),
              _resultRow('用时', '$m:$s'),
              _resultRow('配对', '$correct / $total'),
              _resultRow('错误', '$_errorCount 次'),
              _resultRow('正确率', '${accuracy.round()}%'),
              if (_score > 0) _resultRow('得分', '$_score'),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
                  child: const Text('返回'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _resultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 15, color: Color(0xFF6B4E2E))),
          Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
