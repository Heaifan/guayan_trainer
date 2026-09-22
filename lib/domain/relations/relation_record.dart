import '../relation_endpoint.dart';
import '../relation_type.dart';

enum RelationKind { relation, state }

enum RelationSourceKind { fact, rule, user }

enum RelationStateType {
  xunKong('空亡'),
  monthBreak('月破'),
  dayBreak('日破'),
  inTomb('在库'),
  outTomb('出库'),
  growth('十二长生'),
  movement('动静'),
  shiYing('世应');

  const RelationStateType(this.displayName);
  final String displayName;
}

class RelationRecord {
  RelationRecord._({
    required this.id,
    required this.kind,
    required this.sourceKind,
    required this.participants,
    required this.title,
    this.relationType,
    this.stateType,
    this.fromRef,
    this.toRef,
    this.category,
    this.subtitle,
    this.ruleId,
    this.knowledgeRuleId,
    this.ruleVariantId,
    this.labels = const [],
    this.keywords = const [],
    this.evidence = const [],
    this.note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? _epoch,
       updatedAt = updatedAt ?? _epoch;

  static final _epoch = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

  factory RelationRecord.relation({
    required String id,
    required RelationSourceKind sourceKind,
    required RelationType relationType,
    required RelationEndpoint fromRef,
    required RelationEndpoint toRef,
    required String title,
    String? category,
    String? subtitle,
    String? ruleId,
    String? knowledgeRuleId,
    String? ruleVariantId,
    List<String> labels = const [],
    List<String> keywords = const [],
    List<String> evidence = const [],
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => RelationRecord._(
    id: id,
    kind: RelationKind.relation,
    sourceKind: sourceKind,
    relationType: relationType,
    fromRef: fromRef,
    toRef: toRef,
    participants: [fromRef, toRef],
    title: title,
    category: category,
    subtitle: subtitle,
    ruleId: ruleId,
    knowledgeRuleId: knowledgeRuleId,
    ruleVariantId: ruleVariantId,
    labels: List.unmodifiable(labels),
    keywords: List.unmodifiable(keywords),
    evidence: List.unmodifiable(evidence),
    note: note,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  factory RelationRecord.state({
    required String id,
    required RelationSourceKind sourceKind,
    required RelationStateType stateType,
    required List<RelationEndpoint> participants,
    required String title,
    String? category,
    String? subtitle,
    String? ruleId,
    String? knowledgeRuleId,
    String? ruleVariantId,
    List<String> labels = const [],
    List<String> keywords = const [],
    List<String> evidence = const [],
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => RelationRecord._(
    id: id,
    kind: RelationKind.state,
    sourceKind: sourceKind,
    stateType: stateType,
    participants: List.unmodifiable(participants),
    title: title,
    category: category,
    subtitle: subtitle,
    ruleId: ruleId,
    knowledgeRuleId: knowledgeRuleId,
    ruleVariantId: ruleVariantId,
    labels: List.unmodifiable(labels),
    keywords: List.unmodifiable(keywords),
    evidence: List.unmodifiable(evidence),
    note: note,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  factory RelationRecord.userRelation({
    required String id,
    required RelationEndpoint fromRef,
    required RelationEndpoint toRef,
    required String title,
    String? note,
  }) => RelationRecord._(
    id: id,
    kind: RelationKind.relation,
    sourceKind: RelationSourceKind.user,
    fromRef: fromRef,
    toRef: toRef,
    participants: [fromRef, toRef],
    title: title,
    category: '手工',
    note: note,
  );

  final String id;
  final RelationKind kind;
  final RelationSourceKind sourceKind;
  final RelationType? relationType;
  final RelationStateType? stateType;
  final RelationEndpoint? fromRef;
  final RelationEndpoint? toRef;
  final List<RelationEndpoint> participants;
  final String title;
  final String? category;
  final String? subtitle;
  final String? ruleId;
  final String? knowledgeRuleId;
  final String? ruleVariantId;
  final List<String> labels;
  final List<String> keywords;
  final List<String> evidence;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;
}
