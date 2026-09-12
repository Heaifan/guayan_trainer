/// GA-1 普通真实卦例数据：GA-01 … GA-07。
library;

import 'package:guayan_trainer/domain/line_state.dart';

import '../logic/case_model.dart';

const _y = MovementType.shaoYang;
const _o = MovementType.shaoYin;
const _Y = MovementType.laoYang;
const _O = MovementType.laoYin;

const List<GateACase> normalCasesA = <GateACase>[

  GateACase(
    id: 'GA-01',
    group: 'GA-1',
    localTime: '2026-01-08 09:30:00',
    originalBits: '111111',
    expectedOriginal: '乾为天',
    purpose: '乾宫本宫卦·六冲·静卦·甲子旬（旬空申酉）·丑月',
  ),
  GateACase(
    id: 'GA-02',
    group: 'GA-1',
    localTime: '2026-02-12 20:15:00',
    originalBits: '000000',
    expectedOriginal: '坤为地',
    purpose: '坤宫本宫卦·六冲·静卦·子丑旬空·寅月（立春后）',
  ),
  GateACase(
    id: 'GA-03',
    group: 'GA-1',
    localTime: '2026-02-25 14:00:00',
    originalBits: '100000',
    movingPositions: <int>[0],
    expectedOriginal: '地雷复',
    expectedChanged: '坤为地',
    purpose: '坤宫六合卦·一世（世1应4）·初爻动·六神起例',
  ),
  GateACase(
    id: 'GA-04',
    group: 'GA-1',
    localTime: '2026-03-15 10:20:30',
    originalBits: '010000',
    movingPositions: <int>[1],
    expectedOriginal: '地水师',
    expectedChanged: '坤为地',
    purpose: '坎宫归魂（世3应6）·二爻动·秒级输入 10:20:30·卯月',
  ),
  GateACase(
    id: 'GA-05',
    group: 'GA-1',
    localTime: '2026-04-10 16:45:00',
    originalBits: '100100',
    movingPositions: <int>[3],
    expectedOriginal: '震为雷',
    expectedChanged: '地雷复',
    purpose: '震宫本宫卦·六冲·四爻动·辰月',
  ),
  GateACase(
    id: 'GA-06',
    group: 'GA-1',
    localTime: '2026-05-20 07:05:00',
    originalBits: '000000',
    expectedOriginal: '坤为地',
    purpose: '坤宫本宫卦·六冲·静卦（与 GA-02 不同干支日：甲午日）·巳月',
  ),
  GateACase(
    id: 'GA-07',
    group: 'GA-1',
    localTime: '2026-06-15 21:40:00',
    originalBits: '010000',
    movingPositions: <int>[1],
    expectedOriginal: '地水师',
    expectedChanged: '坤为地',
    purpose: '坎宫归魂·二爻动（与 GA-04 不同干支日：庚申日）·午月',
  ),
];
