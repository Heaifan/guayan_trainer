import 'package:flutter/material.dart';

import '../../models/mistake_item.dart';
import '../../models/training_question.dart';
import '../../models/training_result.dart';
import '../../services/mistake_store.dart';
import '../../services/question_generator.dart';
import '../../theme/wuxing_colors.dart';
import '../../widgets/effects/control/control_relation_effect.dart';
import '../../widgets/wuxing_control_wheel.dart';
import '../../widgets/wuxing_wheel.dart';
import 'result_page.dart';

/// 五行相生练习的三种题型阶段。
enum GeneratePracticeStyle {
  /// 轮盘题：在五行轮盘上点击答案
  wheel,

  /// 彩色单选：五张五行彩色选项卡
  colorChoice,

  /// 无色单选：去掉颜色提示，纯文字卡
  textChoice,
}

class TrainingPage extends StatefulWidget {
  final String title;
  final TrainingMode mode;

  const TrainingPage({
    super.key,
    required this.title,
    required this.mode,
  });

  @override
  State<TrainingPage> createState() => _TrainingPageState();
}

class _TrainingPageState extends State<TrainingPage> {
  final QuestionGenerator _generator = QuestionGenerator();

  late final List<TrainingQuestion> _questions;
  final List<QuestionAnswerResult> _results = [];

  int _index = 0;
  DateTime _questionStartTime = DateTime.now();

  String? _selectedAnswer;
  bool _hasAnswered = false;

  TrainingQuestion get _current => _questions[_index];

  /// 当前题型阶段（仅相生/相克模式有效）。
  GeneratePracticeStyle get _currentStyle {
    if (_index < 4) return GeneratePracticeStyle.wheel;
    if (_index < 8) return GeneratePracticeStyle.colorChoice;
    return GeneratePracticeStyle.textChoice;
  }

  /// 阶段标签文案。
  String get _stageLabel {
    switch (_currentStyle) {
      case GeneratePracticeStyle.wheel:
        return '阶段一 · 轮盘题';
      case GeneratePracticeStyle.colorChoice:
        return '阶段二 · 彩色单选';
      case GeneratePracticeStyle.textChoice:
        return '阶段三 · 无色单选';
    }
  }

  @override
  void initState() {
    super.initState();
    _questions = _generator.generateSession(
      mode: widget.mode,
      count: (widget.mode == TrainingMode.wuxingGenerate || widget.mode == TrainingMode.wuxingControl) ? 12 : 10,
    );
    _questionStartTime = DateTime.now();
  }

  Future<void> _answer(String answer) async {
    if (_hasAnswered) return;

    final used = DateTime.now().difference(_questionStartTime).inMilliseconds;
    final isCorrect = answer == _current.correctAnswer;

    final result = QuestionAnswerResult(
      question: _current,
      selectedAnswer: answer,
      isCorrect: isCorrect,
      milliseconds: used,
    );

    _results.add(result);

    if (!isCorrect) {
      // 写入持久化错题库
      String? topic;
      String? relationPrefix;
      if (widget.mode == TrainingMode.wuxingGenerate) {
        topic = 'generate';
        relationPrefix = '生';
      } else if (widget.mode == TrainingMode.wuxingControl) {
        topic = 'control';
        relationPrefix = '克';
      }

      if (topic != null) {
        final now = DateTime.now();
        final id = 'wuxing_${topic}_${_current.sourceElement}_${_current.correctAnswer}';
        final existing = MistakeStore.instance.all.where((e) => e.id == id).firstOrNull;
        await MistakeStore.instance.addOrUpdateMistake(
          MistakeItem(
            id: id,
            module: 'wuxing',
            topic: topic!,
            questionText: _current.prompt,
            sourceElement: _current.sourceElement ?? '',
            correctAnswer: _current.correctAnswer,
            wrongAnswer: answer,
            relationText: '${_current.sourceElement}$relationPrefix${_current.correctAnswer}',
            practiceStyle: _currentStyle.name,
            wrongCount: existing != null ? existing.wrongCount + 1 : 1,
            createdAt: existing?.createdAt ?? now,
            updatedAt: now,
          ),
        );
      }
    }

    setState(() {
      _selectedAnswer = answer;
      _hasAnswered = true;
    });
  }

  void _next() {
    if (_index >= _questions.length - 1) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ResultPage(
            result: TrainingSessionResult(_results),
          ),
        ),
      );
      return;
    }

    setState(() {
      _index += 1;
      _selectedAnswer = null;
      _hasAnswered = false;
      _questionStartTime = DateTime.now();
    });
  }

  Color? _optionBg(String option) {
    if (!_hasAnswered) {
      final wuxing = WuxingColors.mainColor.containsKey(option)
          ? option
          : WuxingColors.getWuxingByBranch(option);
      if (wuxing != null) {
        return WuxingColors.getSoftColor(wuxing);
      }
      return null;
    }

    if (option == _current.correctAnswer) return WuxingColors.getColor(option);
    if (option == _selectedAnswer) return const Color(0xFFC0392B);
    return null;
  }

  Color? _optionFg(String option) {
    if (!_hasAnswered) return null;
    if (option == _current.correctAnswer) {
      return WuxingColors.textOnColor(option);
    }
    if (option == _selectedAnswer) {
      return WuxingColors.textOnColor(option);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final progress = '${_index + 1}/${_questions.length}';
    final isGenerate = widget.mode == TrainingMode.wuxingGenerate;
    final isControl = widget.mode == TrainingMode.wuxingControl;
    final showArrow = (isGenerate || isControl) && _currentStyle == GeneratePracticeStyle.wheel;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (_index + 1) / _questions.length,
              minHeight: 8,
              borderRadius: BorderRadius.circular(99),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (isGenerate || isControl)
                  Text(_stageLabel,
                      style: const TextStyle(
                          color: Color(0xFF8A6A3A), fontSize: 13)),
                Text(progress),
              ],
            ),
            const SizedBox(height: 24),
            _questionCard(),
            const SizedBox(height: 20),
            Expanded(child: _answerArea()),
            if (_hasAnswered) _feedbackArea(),
          ],
        ),
      ),
    );
  }

  Widget _questionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4DC),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE0C28A)),
      ),
      child: Column(
        children: [
          const Text(
            '请判断',
            style: TextStyle(color: Color(0xFF8A6A3A), fontSize: 14),
          ),
          const SizedBox(height: 12),
          Text(
            _current.prompt,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Color(0xFF3B2A1A),
            ),
          ),
        ],
      ),
    );
  }

  /// 根据当前题型阶段返回对应的答题区域。
  Widget _answerArea() {
    if (widget.mode == TrainingMode.wuxingGenerate ||
        widget.mode == TrainingMode.wuxingControl) {
      switch (_currentStyle) {
        case GeneratePracticeStyle.wheel:
          return _wheelArea();
        case GeneratePracticeStyle.colorChoice:
          return _colorChoiceArea();
        case GeneratePracticeStyle.textChoice:
          return _textChoiceArea();
      }
    }
    // 非相生模式：使用原有的垂直列表
    return ListView.separated(
      itemCount: _current.options.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, i) => _answerButton(_current.options[i]),
    );
  }

  Widget _wheelArea() {
    final isControl = widget.mode == TrainingMode.wuxingControl;
    return Column(
      children: [
        Expanded(
          child: isControl
              ? WuxingControlWheel(
                  selected: _selectedAnswer,
                  correctAnswer: _current.correctAnswer,
                  hasAnswered: _hasAnswered,
                  sourceElement: _current.sourceElement,
                  onTap: _answer,
                  showBaseLines: _hasAnswered,
                  showActiveArrow: _hasAnswered,
                  showActiveHighlight: _hasAnswered,
                )
              : WuxingWheel(
                  selected: _selectedAnswer,
                  correctAnswer: _current.correctAnswer,
                  hasAnswered: _hasAnswered,
                  sourceElement: _current.sourceElement,
                  showArrow: true,
                  onTap: _answer,
                ),
        ),
        if (!_hasAnswered)
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
              '凭记忆点击答案',
              style: TextStyle(color: Color(0xFF8A6A3A), fontSize: 14),
            ),
          ),
        if (_hasAnswered && isControl) _controlEffectArea(),
      ],
    );
  }

  Widget _controlEffectArea() {
    final from = _current.sourceElement;
    final to = _current.correctAnswer;
    if (from == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: ControlRelationEffect(
        sourceElement: from,
        targetElement: to,
        visible: true,
        size: 130,
      ),
    );
  }

  /// 彩色单选：五张五行颜色卡片，以 3+2 Wrap 布局。
  Widget _colorChoiceArea() {
    final options = _current.options;
    return Center(
      child: Wrap(
        spacing: 14,
        runSpacing: 14,
        alignment: WrapAlignment.center,
        children: options.map((opt) {
          final bg = _optionBg(opt);
          final fg = _optionFg(opt);
          final wuxing = WuxingColors.mainColor.containsKey(opt) ? opt : null;
          final cardColor = wuxing != null ? WuxingColors.getSoftColor(wuxing) : null;
          final textColor = wuxing != null ? WuxingColors.getColor(wuxing) : null;

          return SizedBox(
            width: 64,
            height: 80,
            child: FilledButton.tonal(
              style: FilledButton.styleFrom(
                backgroundColor: _hasAnswered ? bg : cardColor,
                foregroundColor: _hasAnswered ? fg : textColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: _hasAnswered && opt == _current.correctAnswer
                        ? const Color(0xFF2F6F5E)
                        : Colors.transparent,
                    width: 2.5,
                  ),
                ),
                padding: EdgeInsets.zero,
              ),
              onPressed: () => _answer(opt),
              child: Text(
                opt,
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w900),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 无色单选：五张统一浅色卡片，去掉颜色提示。
  Widget _textChoiceArea() {
    final options = _current.options;
    return Center(
      child: Wrap(
        spacing: 14,
        runSpacing: 14,
        alignment: WrapAlignment.center,
        children: options.map((opt) {
          return SizedBox(
            width: 64,
            height: 80,
            child: FilledButton.tonal(
              style: FilledButton.styleFrom(
                backgroundColor: _hasAnswered && opt != _selectedAnswer && opt != _current.correctAnswer
                    ? null
                    : _optionBg(opt),
                foregroundColor: _optionFg(opt),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: _hasAnswered && opt == _current.correctAnswer
                        ? const Color(0xFF2F6F5E)
                        : const Color(0xFFE0C28A),
                    width: _hasAnswered && opt == _current.correctAnswer ? 2.5 : 1.5,
                  ),
                ),
                padding: EdgeInsets.zero,
              ),
              onPressed: () => _answer(opt),
              child: Text(
                opt,
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w900),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _answerButton(String option) {
    final bg = _optionBg(option);
    final fg = _optionFg(option);

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: FilledButton.tonal(
        style: FilledButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: () => _answer(option),
        child: Text(
          option,
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _feedbackArea() {
    final isCorrect = _selectedAnswer == _current.correctAnswer;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCorrect ? const Color(0xFFE9F5EF) : const Color(0xFFFFEFEA),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isCorrect ? const Color(0xFF2F6F5E) : const Color(0xFFC0392B),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isCorrect ? '正确' : '回炉',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: isCorrect ? const Color(0xFF2F6F5E) : const Color(0xFFC0392B),
            ),
          ),
          const SizedBox(height: 8),
          if (!isCorrect)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text('你选了$_selectedAnswer。 正确是：${_current.correctAnswer}。',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          Text(
            _current.explanation,
            style: const TextStyle(fontSize: 16, height: 1.4),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _next,
              child: Text(_index >= _questions.length - 1 ? '查看结果' : '下一题'),
            ),
          ),
        ],
      ),
    );
  }
}
