/// 神煞领域模型与计算上下文（纯 Dart）。
library;

import '../di_zhi.dart';
import '../tian_gan.dart';

class ShenShaContext {
  const ShenShaContext({
    required this.yearGanZhi,
    required this.monthGanZhi,
    required this.dayGanZhi,
    required this.hourGanZhi,
    required this.shiPosition,
    required this.shiIsYang,
  });

  final String yearGanZhi;
  final String monthGanZhi;
  final String dayGanZhi;
  final String hourGanZhi;
  final int shiPosition;
  final bool shiIsYang;

  TianGan get dayGan => TianGan.fromLabel(dayGanZhi.substring(0, 1));
  DiZhi get dayBranch => DiZhi.fromLabel(dayGanZhi.substring(1));
  DiZhi get monthBranch => DiZhi.fromLabel(monthGanZhi.substring(1));
}

class ShenShaResult {
  const ShenShaResult({
    required this.id,
    required this.displayName,
    required this.branches,
    required this.basisType,
    required this.basisValue,
    required this.ruleSetId,
    required this.ruleVersion,
    required this.reasonSnapshot,
  });

  final String id;
  final String displayName;
  final List<String> branches;
  final String basisType;
  final String basisValue;
  final String ruleSetId;
  final int ruleVersion;
  final String reasonSnapshot;

  String get value => branches.join();

  Map<String, Object?> toJson() => {
    'id': id,
    'displayName': displayName,
    'branches': branches,
    'basisType': basisType,
    'basisValue': basisValue,
    'ruleSetId': ruleSetId,
    'ruleVersion': ruleVersion,
    'reasonSnapshot': reasonSnapshot,
  };

  factory ShenShaResult.fromJson(Map<String, Object?> json) => ShenShaResult(
    id: json['id'] as String,
    displayName: json['displayName'] as String,
    branches: [for (final b in json['branches'] as List<Object?>) b as String],
    basisType: json['basisType'] as String,
    basisValue: json['basisValue'] as String,
    ruleSetId: json['ruleSetId'] as String,
    ruleVersion: json['ruleVersion'] as int,
    reasonSnapshot: json['reasonSnapshot'] as String,
  );

  @override
  bool operator ==(Object other) =>
      other is ShenShaResult &&
      other.id == id &&
      other.displayName == displayName &&
      _same(other.branches, branches) &&
      other.basisType == basisType &&
      other.basisValue == basisValue &&
      other.ruleSetId == ruleSetId &&
      other.ruleVersion == ruleVersion &&
      other.reasonSnapshot == reasonSnapshot;

  @override
  int get hashCode => Object.hash(
    id,
    displayName,
    branches.join(','),
    basisType,
    basisValue,
    ruleSetId,
    ruleVersion,
    reasonSnapshot,
  );
}

bool _same(List<String> first, List<String> second) =>
    first.length == second.length &&
    first.asMap().entries.every((entry) => entry.value == second[entry.key]);
