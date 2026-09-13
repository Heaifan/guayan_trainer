import 'dart:io';

import 'package:guayan_trainer/domain/calendar_snapshot.dart';
import 'package:guayan_trainer/domain/di_zhi.dart';
import 'package:guayan_trainer/domain/hexagram_case.dart';
import 'package:guayan_trainer/domain/line_state.dart';
import 'package:guayan_trainer/domain/relation_calculator.dart';
import 'package:guayan_trainer/domain/relation_endpoint.dart';
import 'package:guayan_trainer/domain/relation_key.dart';
import 'package:guayan_trainer/domain/relation_type.dart';

void main() {
  // ignore_for_file: avoid_print
  
  final gb01 = buildGb01();
  final gb02 = buildGb02();
  final gb03 = buildGb03();
  
  final cases = {
    '01-gb-01.md': gb01,
    '02-gb-02.md': gb02,
    '03-gb-03.md': gb03,
  };
  
  final dir = Directory('gate-b');
  if (!dir.existsSync()) {
    dir.createSync();
  }
  
  for (final entry in cases.entries) {
    runCaseAndGenerateLedger(entry.key, entry.value, dir.path);
  }
  
  runMissingInputTests();
  runDeterminismTests();
  runSerializationTests();
  
  print('Gate B tests completed. Output generated in gate-b/ directory.');
}

HexagramCase buildGb01() {
  return HexagramCase(
    id: 'GB-01',
    question: 'GB-01: 单动爻综合案例',
    createdAt: DateTime.now(),
    calendar: CalendarSnapshot(
      monthBranch: '子',
      dayGanZhi: '甲寅',
    ),
    lines: [
      LineState(position: 1, movementType: MovementType.shaoYin, branch: '子'),
      LineState(position: 2, movementType: MovementType.laoYang, branch: '午', changedBranch: '寅'),
      LineState(position: 3, movementType: MovementType.shaoYang, branch: '申'),
      LineState(position: 4, movementType: MovementType.shaoYin, branch: '卯'),
      LineState(position: 5, movementType: MovementType.shaoYang, branch: '戌'),
      LineState(position: 6, movementType: MovementType.shaoYin, branch: '辰'),
    ],
  );
}

HexagramCase buildGb02() {
  return HexagramCase(
    id: 'GB-02',
    question: 'GB-02: 多动爻 / 回头关系',
    createdAt: DateTime.now(),
    calendar: CalendarSnapshot(
      monthBranch: '卯',
      dayGanZhi: '乙酉',
    ),
    lines: [
      LineState(position: 1, movementType: MovementType.laoYin, branch: '亥', changedBranch: '申'),
      LineState(position: 2, movementType: MovementType.laoYang, branch: '巳', changedBranch: '亥'),
      LineState(position: 3, movementType: MovementType.shaoYang, branch: '丑'),
      LineState(position: 4, movementType: MovementType.shaoYin, branch: '酉'),
      LineState(position: 5, movementType: MovementType.shaoYang, branch: '卯'),
      LineState(position: 6, movementType: MovementType.shaoYin, branch: '未'),
    ],
  );
}

HexagramCase buildGb03() {
  return HexagramCase(
    id: 'GB-03',
    question: 'GB-03: 静爻事实账本',
    createdAt: DateTime.now(),
    calendar: CalendarSnapshot(
      monthBranch: '午',
      dayGanZhi: '丙申',
    ),
    lines: [
      LineState(position: 1, movementType: MovementType.shaoYin, branch: '寅'),
      LineState(position: 2, movementType: MovementType.shaoYang, branch: '午'),
      LineState(position: 3, movementType: MovementType.shaoYin, branch: '戌'),
      LineState(position: 4, movementType: MovementType.shaoYang, branch: '申'),
      LineState(position: 5, movementType: MovementType.shaoYin, branch: '子'),
      LineState(position: 6, movementType: MovementType.shaoYang, branch: '辰'),
    ],
  );
}

List<RelationKey> expectedTruth(HexagramCase c) {
  final out = <RelationKey>[];
  
  // Dong Bian, Hui Tou Sheng, Hui Tou Ke
  for (final line in c.lines) {
    if (line.movementType.isMoving) {
      out.add(RelationKey.from(
        type: RelationType.dongBian,
        ruleId: 'sys.dong_bian',
        source: YaoEndpoint(LineScope.original, line.position),
        target: YaoEndpoint(LineScope.changed, line.position),
      ));
      
      if (line.changedBranch != null && line.branch != null) {
        final originalZhi = DiZhi.fromLabel(line.branch!);
        final changedZhi = DiZhi.fromLabel(line.changedBranch!);
        if (changedZhi.wuXing.generates == originalZhi.wuXing) {
          out.add(RelationKey.from(
            type: RelationType.huiTouSheng,
            ruleId: 'sys.hui_tou_sheng',
            source: YaoEndpoint(LineScope.changed, line.position),
            target: YaoEndpoint(LineScope.original, line.position),
          ));
        } else if (changedZhi.wuXing.controls == originalZhi.wuXing) {
          out.add(RelationKey.from(
            type: RelationType.huiTouKe,
            ruleId: 'sys.hui_tou_ke',
            source: YaoEndpoint(LineScope.changed, line.position),
            target: YaoEndpoint(LineScope.original, line.position),
          ));
        }
      }
    }
  }
  
  // Chong He
  for (int i = 0; i < c.lines.length; i++) {
    for (int j = i + 1; j < c.lines.length; j++) {
      final a = c.lines[i].branch;
      final b = c.lines[j].branch;
      if (a == null || b == null) continue;
      
      final zhiA = DiZhi.fromLabel(a);
      final zhiB = DiZhi.fromLabel(b);
      
      final src = YaoEndpoint(LineScope.original, c.lines[i].position);
      final tgt = YaoEndpoint(LineScope.original, c.lines[j].position);
      
      if (zhiA.chong == zhiB) {
        out.add(RelationKey.from(
          type: RelationType.liuChong,
          ruleId: 'sys.liu_chong',
          source: src,
          target: tgt,
        ));
      }
      
      if (zhiA.he == zhiB) {
        out.add(RelationKey.from(
          type: RelationType.liuHe,
          ruleId: 'sys.liu_he',
          source: src,
          target: tgt,
        ));
      }
    }
  }
  
  // Wu Xing
  for (int i = 0; i < c.lines.length; i++) {
    for (int j = i + 1; j < c.lines.length; j++) {
      final a = c.lines[i].branch;
      final b = c.lines[j].branch;
      if (a == null || b == null) continue;
      
      final zhiA = DiZhi.fromLabel(a);
      final zhiB = DiZhi.fromLabel(b);
      
      final pA = c.lines[i].position;
      final pB = c.lines[j].position;
      
      if (zhiA.wuXing.generates == zhiB.wuXing) {
        out.add(RelationKey.from(
          type: RelationType.sheng,
          ruleId: 'sys.sheng',
          source: YaoEndpoint(LineScope.original, pA),
          target: YaoEndpoint(LineScope.original, pB),
        ));
      } else if (zhiB.wuXing.generates == zhiA.wuXing) {
        out.add(RelationKey.from(
          type: RelationType.sheng,
          ruleId: 'sys.sheng',
          source: YaoEndpoint(LineScope.original, pB),
          target: YaoEndpoint(LineScope.original, pA),
        ));
      } else if (zhiA.wuXing.controls == zhiB.wuXing) {
        out.add(RelationKey.from(
          type: RelationType.ke,
          ruleId: 'sys.ke',
          source: YaoEndpoint(LineScope.original, pA),
          target: YaoEndpoint(LineScope.original, pB),
        ));
      } else if (zhiB.wuXing.controls == zhiA.wuXing) {
        out.add(RelationKey.from(
          type: RelationType.ke,
          ruleId: 'sys.ke',
          source: YaoEndpoint(LineScope.original, pB),
          target: YaoEndpoint(LineScope.original, pA),
        ));
      }
    }
  }
  
  // Month Day
  if (c.calendar != null) {
    final monthZhi = DiZhi.tryFromLabel(c.calendar!.monthBranch);
    final dayBranchStr = c.calendar!.dayGanZhi.substring(1);
    final dayZhi = DiZhi.tryFromLabel(dayBranchStr);
    
    for (final line in c.lines) {
      if (line.branch == null) continue;
      final tgtZhi = DiZhi.fromLabel(line.branch!);
      final tgtEp = YaoEndpoint(LineScope.original, line.position);
      
      if (monthZhi != null) {
        if (monthZhi.wuXing.generates == tgtZhi.wuXing) {
          out.add(RelationKey.from(
            type: RelationType.sheng,
            ruleId: 'sys.month_branch',
            source: const MonthEndpoint(),
            target: tgtEp,
          ));
        } else if (monthZhi.wuXing.controls == tgtZhi.wuXing) {
          out.add(RelationKey.from(
            type: RelationType.ke,
            ruleId: 'sys.month_branch',
            source: const MonthEndpoint(),
            target: tgtEp,
          ));
        }
      }
      
      if (dayZhi != null) {
        if (dayZhi.wuXing.generates == tgtZhi.wuXing) {
          out.add(RelationKey.from(
            type: RelationType.sheng,
            ruleId: 'sys.day_branch',
            source: const DayEndpoint(),
            target: tgtEp,
          ));
        } else if (dayZhi.wuXing.controls == tgtZhi.wuXing) {
          out.add(RelationKey.from(
            type: RelationType.ke,
            ruleId: 'sys.day_branch',
            source: const DayEndpoint(),
            target: tgtEp,
          ));
        }
      }
    }
  }
  
  return out;
}

void runCaseAndGenerateLedger(String filename, HexagramCase c, String outDir) {
  final expectedKeys = expectedTruth(c);
  expectedKeys.sort((a, b) => a.canonical.compareTo(b.canonical));
  
  final res = calculateRelationResult(c);
  final actualInsts = res.instances;
  final actualKeys = actualInsts.map((e) => e.key).toList();
  // Calculator should already sort them stably
  
  final out = StringBuffer();
  out.writeln('# ${c.id} / ${c.question}');
  out.writeln();
  
  bool allMatch = true;
  
  final expectedSet = expectedKeys.map((e) => e.canonical).toSet();
  final actualSet = actualKeys.map((e) => e.canonical).toSet();
  
  final missing = expectedKeys.where((k) => !actualSet.contains(k.canonical)).toList();
  final extra = actualKeys.where((k) => !expectedSet.contains(k.canonical)).toList();
  
  out.writeln('## Comparison Summary');
  out.writeln('- Expected count: ${expectedKeys.length}');
  out.writeln('- Actual count: ${actualKeys.length}');
  out.writeln('- Missing count: ${missing.length}');
  out.writeln('- Extra count: ${extra.length}');
  
  if (missing.isEmpty && extra.isEmpty) {
    out.writeln('\n**Result: PASS**');
  } else {
    out.writeln('\n**Result: FAIL**');
    allMatch = false;
  }
  
  out.writeln('\n## Missing Relations');
  if (missing.isEmpty) {
    out.writeln('None.');
  } else {
    for (final k in missing) {
      out.writeln('- `${k.canonical}`');
    }
  }
  
  out.writeln('\n## Extra Relations');
  if (extra.isEmpty) {
    out.writeln('None.');
  } else {
    for (final k in extra) {
      out.writeln('- `${k.canonical}`');
    }
  }
  
  out.writeln('\n## Full Ledger');
  out.writeln('| Type | Source | Target | Rule ID | Expected | Actual | Result |');
  out.writeln('|---|---|---|---|---|---|---|');
  
  final allCanons = {...expectedSet, ...actualSet}.toList()..sort();
  for (final canon in allCanons) {
    final hasExp = expectedSet.contains(canon);
    final hasAct = actualSet.contains(canon);
    final key = hasAct ? actualKeys.firstWhere((k) => k.canonical == canon) : expectedKeys.firstWhere((k) => k.canonical == canon);
    
    final status = (hasExp && hasAct) ? 'PASS' : 'FAIL';
    
    out.writeln('| ${key.type.name} | ${key.source.semanticId} | ${key.target.semanticId} | ${key.ruleId} | ${hasExp ? 'PRESENT' : 'ABSENT'} | ${hasAct ? 'PRESENT' : 'ABSENT'} | $status |');
  }
  
  File('$outDir/$filename').writeAsStringSync(out.toString());
  print('Wrote $outDir/$filename - ${allMatch ? "PASS" : "FAIL"}');
  
  if (!allMatch) {
    throw Exception('Gate B mismatch for ${c.id}');
  }
}

void runMissingInputTests() {
  print('Running missing input tests...');
  final c = HexagramCase(
    id: 'B-MISSING',
    question: 'Missing Calendar',
    createdAt: DateTime.now(),
    calendar: null,
    lines: [
      LineState(position: 1, movementType: MovementType.laoYin, branch: '子'), // moving, no changed branch
      LineState(position: 2, movementType: MovementType.shaoYang, branch: '午'),
      LineState(position: 3, movementType: MovementType.shaoYin, branch: '申'),
      LineState(position: 4, movementType: MovementType.shaoYang, branch: '卯'),
      LineState(position: 5, movementType: MovementType.shaoYin, branch: '戌'),
      LineState(position: 6, movementType: MovementType.shaoYang, branch: '辰'),
    ],
  );
  
  final res = calculateRelationResult(c);
  final diags = res.diagnostics.missingInputs;
  if (!diags.contains('calendar.monthBranch')) throw Exception('Missing month missing in diagnostics');
  if (!diags.contains('calendar.dayBranch')) throw Exception('Missing day missing in diagnostics');
  if (!diags.contains('line[1].changedBranch')) throw Exception('Missing changedBranch missing in diagnostics');
  
  for (final inst in res.instances) {
    if (inst.source is MonthEndpoint || inst.source is DayEndpoint) {
      throw Exception('Should not generate month/day relations when calendar is null');
    }
    if (inst.type == RelationType.huiTouSheng || inst.type == RelationType.huiTouKe) {
      throw Exception('Should not generate huitou relations when changedBranch is null');
    }
  }
  print('Missing input tests passed.');
}

void runDeterminismTests() {
  print('Running determinism tests...');
  final c = buildGb01();
  final res1 = calculateRelationResult(c);
  final res2 = calculateRelationResult(c);
  
  if (res1.instances.length != res2.instances.length) throw Exception('Lengths differ');
  for (int i = 0; i < res1.instances.length; i++) {
    if (res1.instances[i].key.canonical != res2.instances[i].key.canonical) {
      throw Exception('Keys differ at index $i: ${res1.instances[i].key.canonical} vs ${res2.instances[i].key.canonical}');
    }
  }
  
  // duplicate checks
  if (res1.diagnostics.warnings.isNotEmpty) {
    throw Exception('Found duplicate keys: ${res1.diagnostics.warnings}');
  }
  
  print('Determinism tests passed.');
}

void runSerializationTests() {
  print('Running serialization regression...');
  
  // Legacy JSON:
  final legacyJson = {
    "type": "sheng",
    "ruleId": "sys.sheng",
    "ruleVersion": 1,
    "source": {
      "scope": "original",
      "position": 1
    },
    "target": {
      "scope": "original",
      "position": 4
    }
  };
  
  final key = RelationKey.fromJson(legacyJson);
  if (key.canonical != 'sheng|sys.sheng|v1|-|yao:original:1->yao:original:4') {
    throw Exception('Legacy parse failed: ${key.canonical}');
  }
  
  print('Serialization regression passed.');
}
