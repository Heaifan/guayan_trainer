/// Gate A 公共上下文：装载真实历法数据包 → 构建 CalendarEngine。
///
/// 与产品路径完全一致：JSON → 解析 → 校验 → 导入 → 内存仓储 → Provider
/// → MonthBranchResolver → CalendarEngine。Gate A 不允许绕开任何一层，
/// 否则验的就不是产品真值。
///
/// 时间输入辅助见 `core/time_input.dart`，装载实现见 `core/pack_loader.dart`。
library;

import 'package:guayan_trainer/domain/calendar/calendar_engine.dart';

import 'core/time/pack_loader.dart';

/// 数据包年份范围（`assets/calendar/` 内实际存在的年份）。
const List<int> gateAYears = <int>[
  2019,
  2020,
  2021,
  2022,
  2023,
  2024,
  2025,
  2026,
  2027,
  2028,
];

/// 组装好的历法引擎。
class GateAContext {
  const GateAContext(this.engine, this.installedYears);

  final CalendarEngine engine;
  final List<int> installedYears;
}

/// 从 `assets/calendar/` 装载全部年份并构建引擎。
Future<GateAContext> loadGateAContext() => loadContextFromAssets(gateAYears);
