/// 规则模块共用的小工具。
///
/// 只有两件事：把「卦例的 replay 上下文 + 规则 id」变成正确的 ruleVersion，
/// 以及把地支文本安全解析成 [DiZhi]。抽出来是为了让每个规则模块
/// 只表达**规则语义**，而不是重复七行样板。
library;

import '../di_zhi.dart';
import '../hexagram_case.dart';
import '../relation_endpoint.dart';
import '../relation_instance.dart';
import '../relation_type.dart';

/// 构造一条系统关系；ruleVersion 取自 [c] 的 replay 上下文（缺失回退 v1）。
///
/// 必须走 replay 上下文：旧卦例重算时才能复现历史 RelationKey，
/// 否则系统升级规则版本会让旧笔记全部失联。
RelationInstance systemRelation({
  required HexagramCase c,
  required RelationType type,
  required String ruleId,
  required RelationEndpoint source,
  required RelationEndpoint target,
  String? subtype,
}) => RelationInstance.from(
  type: type,
  ruleId: ruleId,
  ruleVersion: c.ruleContext.versionForOrDefault(ruleId),
  source: source,
  target: target,
  subtype: subtype,
);

/// 地支文本 → [DiZhi]；缺失或无法识别返回 null（外部数据不因此崩溃）。
DiZhi? zhiOf(String? label) => label == null ? null : DiZhi.tryFromLabel(label);

/// 本卦某爻的端点。
YaoEndpoint originalYao(int position) =>
    YaoEndpoint(LineScope.original, position);

/// 变卦某爻的端点。
YaoEndpoint changedYao(int position) =>
    YaoEndpoint(LineScope.changed, position);
