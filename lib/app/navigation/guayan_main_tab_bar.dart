import 'package:flutter/material.dart';

import '../../presentation/casting/casting_tokens.dart';
import 'main_tabs.dart';

/// XYUI 化底部主模块导航（任务书 §15 GuayanMainTabBar SVG）。
///
/// 属于 App Shell 公共导航，禁止为单个页面复制独立 BottomBar。
/// 活动 tab：圆角底色 + 加粗标签；非活动：浅色标签。
/// tab 数据（标题/图标/页面构建器）单一来源为 [mainTabs]。
class GuayanMainTabBar extends StatelessWidget {
  const GuayanMainTabBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onSelect,
  });

  final List<MainTab> tabs;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: CastingTokens.header,
        border: Border(top: BorderSide(color: CastingTokens.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
          child: Row(
            children: [
              for (var i = 0; i < tabs.length; i++)
                Expanded(
                  child: _TabItem(
                    tab: tabs[i],
                    selected: i == selectedIndex,
                    onTap: () => onSelect(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.tab,
    required this.selected,
    required this.onTap,
  });

  final MainTab tab;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? CastingTokens.textPrimary
        : CastingTokens.textSecondary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 58,
            height: 42,
            decoration: BoxDecoration(
              color:
                  selected ? CastingTokens.activeStrong : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: CustomPaint(
                size: const Size(24, 24),
                painter: tab.iconBuilder(color),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            tab.title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: color,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// 五个主模块图标（SVG path 复刻，任务书 §15）。
class GuayanTabIcons {
  GuayanTabIcons._();

  /// 排卦：四条爻线。
  static CustomPainter cast(Color color) => _LinesPainter(color);

  /// 审卦：椭圆 + 圆心。
  static CustomPainter review(Color color) => _ReviewPainter(color);

  /// 关系：三节点 + 连线。
  static CustomPainter relation(Color color) => _RelationPainter(color);

  /// 卦例：文档卡片 + 两行。
  static CustomPainter cases(Color color) => _CasesPainter(color);

  /// 训练：菱形。
  static CustomPainter training(Color color) => _TrainingPainter(color);
}

class _LinesPainter extends CustomPainter {
  _LinesPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final w = size.width;
    final h = size.height;
    canvas.drawLine(Offset(0, h * 0.25), Offset(w, h * 0.25), paint);
    canvas.drawLine(Offset(0, h * 0.5), Offset(w * 0.45, h * 0.5), paint);
    canvas.drawLine(Offset(w * 0.65, h * 0.5), Offset(w, h * 0.5), paint);
    canvas.drawLine(Offset(0, h * 0.75), Offset(w, h * 0.75), paint);
  }

  @override
  bool shouldRepaint(_LinesPainter oldDelegate) => oldDelegate.color != color;
}

class _ReviewPainter extends CustomPainter {
  _ReviewPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final fill = Paint()..color = color;
    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawOval(
      Rect.fromCenter(center: center, width: 18, height: 12),
      stroke,
    );
    canvas.drawCircle(center, 2.5, fill);
  }

  @override
  bool shouldRepaint(_ReviewPainter oldDelegate) => oldDelegate.color != color;
}

class _RelationPainter extends CustomPainter {
  _RelationPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final top = Offset(size.width / 2, size.height * 0.25);
    final left = Offset(size.width * 0.3, size.height * 0.75);
    final right = Offset(size.width * 0.7, size.height * 0.75);
    final line = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawLine(
        Offset(size.width * 0.47, size.height * 0.33),
        Offset(size.width * 0.36, size.height * 0.67),
        line);
    canvas.drawLine(
        Offset(size.width * 0.53, size.height * 0.33),
        Offset(size.width * 0.64, size.height * 0.67),
        line);
    canvas.drawCircle(top, 3, paint);
    canvas.drawCircle(left, 3, paint);
    canvas.drawCircle(right, 3, paint);
  }

  @override
  bool shouldRepaint(_RelationPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _CasesPainter extends CustomPainter {
  _CasesPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final w = size.width;
    final h = size.height;
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.1, h * 0.15, w * 0.8, h * 0.72),
      const Radius.circular(2),
    );
    canvas.drawRRect(rect, stroke);
    final line = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawLine(
        Offset(w * 0.25, h * 0.42), Offset(w * 0.75, h * 0.42), line);
    canvas.drawLine(
        Offset(w * 0.25, h * 0.58), Offset(w * 0.75, h * 0.58), line);
  }

  @override
  bool shouldRepaint(_CasesPainter oldDelegate) => oldDelegate.color != color;
}

class _TrainingPainter extends CustomPainter {
  _TrainingPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeJoin = StrokeJoin.round;
    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(w / 2, h * 0.15)
      ..lineTo(w * 0.85, h * 0.5)
      ..lineTo(w / 2, h * 0.85)
      ..lineTo(w * 0.15, h * 0.5)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_TrainingPainter oldDelegate) => oldDelegate.color != color;
}
