import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/cases/case_record.dart';
import 'case_query.dart';
import 'case_repository.dart';

class JsonCaseRepository implements CaseRepository {
  JsonCaseRepository._(this._prefs);

  static const _indexKey = 'guayan.case.metadata.v1';
  final SharedPreferences _prefs;
  final Map<String, CaseRecord> _cache = {};

  static Future<JsonCaseRepository> open() async =>
      JsonCaseRepository._(await SharedPreferences.getInstance());

  @override
  Future<void> create(CaseRecord record) async {
    if (await read(record.id) != null) throw StateError('Case already exists: ${record.id}');
    _cache[record.id] = record;
    await _writeDetail(record);
    await _writeIndex();
  }

  @override
  Future<CaseRecord?> read(String id) async {
    if (_cache.containsKey(id)) return _cache[id];
    final raw = _prefs.getString(_detailKey(id));
    if (raw == null) return null;
    final record = CaseRecord.fromJson(Map<String, Object?>.from(jsonDecode(raw) as Map));
    _cache[id] = record;
    return record;
  }

  @override
  Future<CasePage> list(CaseQuery query) async {
    final metadata = _metadata().where((item) => _matches(item, query)).toList();
    metadata.sort((a, b) => _compare(a, b, query.sort));
    final page = metadata.skip(query.offset).take(query.limit).toList();
    final records = <CaseRecord>[];
    for (final item in page) {
      final record = await read(item['id'] as String);
      if (record != null) records.add(record);
    }
    return CasePage(items: records, hasMore: query.offset + page.length < metadata.length);
  }

  @override
  Future<void> update(CaseRecord record) async {
    if (await read(record.id) == null) throw StateError('Unknown Case: ${record.id}');
    _cache[record.id] = record;
    await _writeDetail(record);
    await _writeIndex();
  }

  @override
  Future<void> softDelete(String id) async => _change(id, (r) => r.copyWith(deletedAt: DateTime.now()));

  @override
  Future<void> restore(String id) async {
    final record = await read(id);
    if (record == null) return;
    _cache[id] = CaseRecord.fromJson({...record.toJson()}..remove('deletedAt'));
    await _writeDetail(_cache[id]!);
    await _writeIndex();
  }

  @override
  Future<void> permanentlyDelete(String id) async {
    _cache.remove(id);
    await _prefs.remove(_detailKey(id));
    await _writeIndex();
  }

  @override
  Future<void> setFavorite(String id, bool value) async => _change(id, (r) => r.copyWith(isFavorite: value));

  Future<void> _change(String id, CaseRecord Function(CaseRecord) change) async {
    final record = await read(id);
    if (record == null) return;
    await update(change(record));
  }

  @override
  Future<String> metadataJsonForTest(String id) async => jsonEncode(
        _metadata().firstWhere((item) => item['id'] == id, orElse: () => {}),
      );

  List<Map<String, Object?>> _metadata() => [
    for (final item in (jsonDecode(_prefs.getString(_indexKey) ?? '[]') as List))
      Map<String, Object?>.from(item as Map),
  ];

  bool _matches(Map<String, Object?> item, CaseQuery query) {
    final deleted = item['deletedAt'] != null;
    if (query.deletedOnly != deleted) return false;
    if (query.favoritesOnly && item['isFavorite'] != true) return false;
    final time = DateTime.parse(item['castingTime'] as String);
    if (query.from != null && time.isBefore(query.from!)) return false;
    if (query.to != null && time.isAfter(query.to!)) return false;
    final keyword = query.keyword.trim();
    if (keyword.isEmpty) return true;
    return '${item['subject']} ${item['originalHexagramName']} ${item['changedHexagramName'] ?? ''}'
        .contains(keyword);
  }

  int _compare(Map<String, Object?> a, Map<String, Object?> b, CaseSort sort) {
    final direction = sort == CaseSort.descending ? -1 : 1;
    for (final key in ['castingTime', 'createdAt']) {
      final result = (a[key] as String).compareTo(b[key] as String);
      if (result != 0) return result * direction;
    }
    return (a['id'] as String).compareTo(b['id'] as String);
  }

  Future<void> _writeDetail(CaseRecord record) => _prefs.setString(_detailKey(record.id), jsonEncode(record.toJson()));

  Future<void> _writeIndex() => _prefs.setString(_indexKey, jsonEncode([
    for (final item in _indexedMetadata()) item,
  ]));

  Iterable<Map<String, Object?>> _indexedMetadata() sync* {
    final records = <String, Map<String, Object?>>{
      for (final item in _metadata()) item['id'] as String: item,
    };
    for (final record in _cache.values) {
      records[record.id] = {
        'id': record.id,
        'subject': record.subject,
        'castingTime': record.snapshot.castingTime.toIso8601String(),
        'createdAt': record.createdAt.toIso8601String(),
        'originalHexagramName': record.snapshot.originalHexagramName,
        'changedHexagramName': record.snapshot.changedHexagramName,
        'isFavorite': record.isFavorite,
        'deletedAt': record.deletedAt?.toIso8601String(),
      };
    }
    yield* records.values;
  }

  String _detailKey(String id) => 'guayan.case.detail.v1.$id';
}
