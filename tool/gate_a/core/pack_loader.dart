/// 从 `assets/calendar/` 装载年度数据包并装配 [GateAContext]。
///
/// 走完整产品链路（JSON → 解析 → 校验 → 导入 → 仓储 → Provider → Engine），
/// 不绕过任何一层。
library;

import 'dart:io';

import 'package:guayan_trainer/domain/calendar/calendar_engine.dart';
import 'package:guayan_trainer/domain/calendar/import/calendar_data_pack_importer.dart';
import 'package:guayan_trainer/domain/calendar/solar_term/month_branch_resolver.dart';
import 'package:guayan_trainer/domain/calendar/store/calendar_data_store.dart';
import 'package:guayan_trainer/domain/calendar/store/stored_solar_term_provider.dart';

import '../gate_a_context.dart';

/// 按给定年份列表装载；列表中不存在的文件自动跳过。
Future<GateAContext> loadContextFromAssets(List<int> years) async {
  final store = InMemoryCalendarDataStore();
  final importer = CalendarDataPackImporter(store);
  final loaded = <int>[];

  for (final year in years) {
    final file = File('assets/calendar/$year.calendar.json');
    if (!file.existsSync()) continue;
    await importer.importPack(file.readAsStringSync());
    loaded.add(year);
  }
  if (loaded.isEmpty) {
    throw StateError('assets/calendar/ 下没有任何数据包，Gate A 无法运行');
  }

  final provider = await StoredSolarTermProvider.load(store);
  return GateAContext(
    CalendarEngine(monthBranchResolver: MonthBranchResolver(provider)),
    loaded,
  );
}
