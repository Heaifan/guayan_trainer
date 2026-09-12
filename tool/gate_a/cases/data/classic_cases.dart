/// GA-2 经典卦体专项数据：6 例（R3-A Golden Tests 之外的第二道清单）。
library;

import '../logic/case_model.dart';

const List<GateACase> classicCases = <GateACase>[

  GateACase(
    id: 'GA-C-01',
    group: 'GA-2',
    localTime: '2026-04-08 12:00:00',
    originalBits: '111111',
    expectedOriginal: '乾为天',
    purpose: '乾为天：本宫卦世6应3·纳甲甲子甲寅甲辰壬午壬申壬戌·六冲·静卦',
  ),
  GateACase(
    id: 'GA-C-02',
    group: 'GA-2',
    localTime: '2026-04-08 12:00:00',
    originalBits: '000000',
    expectedOriginal: '坤为地',
    purpose: '坤为地：本宫卦世6应3·纳甲乙未乙巳乙卯癸丑癸亥癸酉·六冲·静卦',
  ),
  GateACase(
    id: 'GA-C-03',
    group: 'GA-2',
    localTime: '2026-04-08 12:00:00',
    originalBits: '001110',
    expectedOriginal: '泽山咸',
    purpose: '泽山咸：兑宫三世（世3应6）·纳甲丙辰丙午丙申丁亥丁酉丁未',
  ),
  GateACase(
    id: 'GA-C-04',
    group: 'GA-2',
    localTime: '2026-04-08 12:00:00',
    originalBits: '111101',
    expectedOriginal: '火天大有',
    purpose: '火天大有：乾宫**归魂**（世3应6）·'
        '纳甲己卯己丑己亥壬午壬申壬戌·宫位五行为金',
  ),
  GateACase(
    id: 'GA-C-05',
    group: 'GA-2',
    localTime: '2026-04-08 12:00:00',
    originalBits: '100001',
    expectedOriginal: '山雷颐',
    purpose: '山雷颐：巽宫**游魂**（世4应1）·宫位五行为木（与他宫不同）',
  ),
  GateACase(
    id: 'GA-C-06',
    group: 'GA-2',
    localTime: '2026-04-08 12:00:00',
    originalBits: '010000',
    movingPositions: <int>[1],
    expectedOriginal: '地水师',
    expectedChanged: '坤为地',
    purpose: '地水师：坎宫归魂（世3应6）·二爻动，专门验证'
        '**变卦六亲仍取本卦宫（坎水）为「我」**',
  ),
];
