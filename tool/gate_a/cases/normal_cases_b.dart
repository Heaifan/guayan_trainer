/// GA-1 普通真实卦例数据：GA-08 … GA-13（与 a 册合计 13 例）。
library;

import 'case_model.dart';

const List<GateACase> normalCasesB = <GateACase>[

  GateACase(
    id: 'GA-08',
    group: 'GA-1',
    localTime: '2026-07-22 11:11:00',
    originalBits: '100100',
    movingPositions: <int>[3],
    expectedOriginal: '震为雷',
    expectedChanged: '地雷复',
    purpose: '震宫本宫卦·六冲·四爻动·六亲含土（辰戌丑未）·未月',
  ),
  GateACase(
    id: 'GA-09',
    group: 'GA-1',
    localTime: '2026-08-22 18:30:00',
    originalBits: '000110',
    movingPositions: <int>[0, 1, 3],
    expectedOriginal: '泽地萃',
    expectedChanged: '水泽节',
    purpose: '兑宫（金）二世·初、二、四三爻同动·**变卦为六合卦（水泽节）**·'
        '验证变卦六亲仍取本卦宫·申月',
  ),
  GateACase(
    id: 'GA-10',
    group: 'GA-1',
    localTime: '2026-09-07 23:20:00',
    originalBits: '101000',
    movingPositions: <int>[2],
    expectedOriginal: '地火明夷',
    expectedChanged: '地雷复',
    purpose: '坎宫游魂（世4应1）·三爻动·23 时后（日界敏感时刻）·酉月',
  ),
  GateACase(
    id: 'GA-11',
    group: 'GA-1',
    localTime: '2026-10-12 05:50:00',
    originalBits: '100000',
    movingPositions: <int>[0],
    expectedOriginal: '地雷复',
    expectedChanged: '坤为地',
    purpose: '坤宫六合卦·初爻动·戌月',
  ),
  GateACase(
    id: 'GA-12',
    group: 'GA-1',
    localTime: '2026-11-18 15:00:00',
    originalBits: '100001',
    movingPositions: <int>[3],
    expectedOriginal: '山雷颐',
    expectedChanged: '火雷噬嗑',
    purpose: '巽宫（木）游魂（世4应1）·四爻动·亥月',
  ),
  GateACase(
    id: 'GA-13',
    group: 'GA-1',
    localTime: '2026-12-10 08:20:00',
    originalBits: '100000',
    movingPositions: <int>[1, 2],
    expectedOriginal: '地雷复',
    expectedChanged: '地天泰',
    purpose: '坤宫六合卦·二、三两爻同动（**多变爻**）·'
        '变卦为本宫三世（地天泰，**亦为六合**）·子月',
  ),
];
