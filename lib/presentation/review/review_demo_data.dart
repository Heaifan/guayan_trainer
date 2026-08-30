/// 审卦页视觉定稿演示数据（任务书总 SVG 基准，GUAYAN-2.0-REVIEW-UI-R1）。
///
/// 传统排盘字段（六神/伏神/六亲/神煞/四柱/卦名/世应）逐项转录自定稿 SVG；
/// 排盘引擎（R3）落地前仅作为演示档案，真实卦例不带这些字段。
/// 演示六爻来自现有 Domain：LineState + 地支，动爻与六合可经
/// calculateRelations 真实计算（辰酉合、午未合、二/三爻动变）。
library;

import '../../domain/hexagram_case.dart';
import '../../domain/line_state.dart';
import '../../domain/rule_execution_context.dart';
import 'review_case_adapter.dart';
import 'review_page_state.dart';

/// 视觉定稿演示数据。
abstract final class ReviewDemoData {
  /// 演示 HexagramCase（六爻完整、两动爻、地支满足六合）。
  /// 爻序与 Domain 契约一致：按 position 升序（1 初爻 .. 6 上爻）。
  static HexagramCase hexagramCase() => HexagramCase(
        id: 'demo-review-r1',
        question: '我的正缘什么时候出现？',
        lines: [
          LineState(position: 1, movementType: MovementType.shaoYin, branch: '辰'),
          LineState(position: 2, movementType: MovementType.laoYang, branch: '午'),
          LineState(position: 3, movementType: MovementType.laoYin, branch: '申'),
          LineState(position: 4, movementType: MovementType.shaoYang, branch: '亥'),
          LineState(position: 5, movementType: MovementType.shaoYin, branch: '酉'),
          LineState(position: 6, movementType: MovementType.shaoYin, branch: '未'),
        ],
        createdAt: DateTime(2026, 8, 30, 17, 59),
        ruleContext: RuleExecutionContext(const [
          RuleVersionRef('sys.default', 1),
        ]),
      );

  /// 传统排盘演示档案（SVG 定稿转录；真实卦例不携带）。
  static ReviewTraditionalProfile profile() => const ReviewTraditionalProfile(
        castingMethod: '铜钱手动',
        lunarDateTime: '二零二六年七月十八日 酉时',
        shenShaItems: [
          ReviewShenShaItem(name: '卦身', value: '申'),
          ReviewShenShaItem(name: '香闺', value: '寅卯'),
          ReviewShenShaItem(name: '床帐', value: '子亥'),
          ReviewShenShaItem(name: '驿马', value: '寅'),
          ReviewShenShaItem(name: '桃花', value: '酉'),
          ReviewShenShaItem(name: '华盖', value: '辰'),
          ReviewShenShaItem(name: '贵人', value: '酉亥'),
          ReviewShenShaItem(name: '天喜', value: '酉'),
          ReviewShenShaItem(name: '天医', value: '未'),
          ReviewShenShaItem(name: '文昌', value: '申'),
          ReviewShenShaItem(name: '劫煞', value: '巳'),
          ReviewShenShaItem(name: '灾煞', value: '午'),
          ReviewShenShaItem(name: '金舆', value: '未'),
          ReviewShenShaItem(name: '亡神', value: '亥'),
          ReviewShenShaItem(name: '将星', value: '子'),
          ReviewShenShaItem(name: '羊刃', value: '午'),
        ],
        yearPillar: '丙午年',
        monthPillar: '丙申月',
        dayPillar: '丙子日',
        hourPillar: '丁酉时',
        xunKong: '(申酉空)',
        originalHexagramName: '泽山咸',
        changedHexagramName: '泽水困',
        originalPalaceInfo: '兑4',
        changedPalaceInfo: '兑2',
        changedHexagramExtra: '六合卦',
        focusedLine: 3,
        focusSummaryOverride: '世爻发动，化官鬼午火；当前建议优先继续查看：',
        lineTraditional: {
          6: ReviewLineTraditional(
            sixSpirit: '青龙',
            hiddenSpirit: '财丙寅　父丁未',
            sixRelative: '父母丁未土',
            displayExtra: '天河水',
            shiYing: '应',
            changed: ReviewChangedLine(
              sixRelative: '父母丁未土',
              displayExtra: '天河水',
              movementType: MovementType.shaoYin,
            ),
          ),
          5: ReviewLineTraditional(
            sixSpirit: '玄武',
            hiddenSpirit: '孙丙子　兄丁酉',
            sixRelative: '兄弟丁酉金',
            displayExtra: '山下火',
            changed: ReviewChangedLine(
              sixRelative: '兄弟丁酉金',
              displayExtra: '山下火',
              movementType: MovementType.shaoYin,
            ),
          ),
          4: ReviewLineTraditional(
            sixSpirit: '白虎',
            hiddenSpirit: '父戊戌　孙丁亥',
            sixRelative: '子孙丁亥水',
            displayExtra: '屋上土',
            changedShiYing: '应',
            changed: ReviewChangedLine(
              sixRelative: '子孙丁亥水',
              displayExtra: '屋上土',
              movementType: MovementType.shaoYang,
            ),
          ),
          3: ReviewLineTraditional(
            sixSpirit: '腾蛇',
            hiddenSpirit: '兄丙申　父丁丑',
            sixRelative: '兄弟丙申金',
            displayExtra: '山下火',
            shiYing: '世',
            changed: ReviewChangedLine(
              sixRelative: '官鬼戊午火',
              displayExtra: '天上火',
              movementType: MovementType.shaoYin,
            ),
          ),
          2: ReviewLineTraditional(
            sixSpirit: '勾陈',
            hiddenSpirit: '官丙午　财丁卯',
            sixRelative: '官鬼丙午火',
            displayExtra: '天河水',
            changed: ReviewChangedLine(
              sixRelative: '父母戊辰土',
              displayExtra: '大林木',
              movementType: MovementType.shaoYang,
            ),
          ),
          1: ReviewLineTraditional(
            sixSpirit: '朱雀',
            hiddenSpirit: '父丙辰　官丁巳',
            sixRelative: '父母丙辰土',
            displayExtra: '沙中土',
            changedShiYing: '世',
            changed: ReviewChangedLine(
              sixRelative: '妻财戊寅木',
              displayExtra: '城头土',
              movementType: MovementType.shaoYin,
            ),
          ),
        },
      );
}
