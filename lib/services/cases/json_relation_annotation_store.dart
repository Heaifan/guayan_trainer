import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../relation_annotation_store.dart';

class JsonRelationAnnotationStore {
  JsonRelationAnnotationStore._(this._preferences, this.store);

  static const _key = 'guayan.case.relation-notes.v1';
  final SharedPreferences _preferences;
  final RelationAnnotationStore store;

  static Future<JsonRelationAnnotationStore> open() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_key);
    final store = raw == null
        ? RelationAnnotationStore()
        : RelationAnnotationStore.fromJson(
            (jsonDecode(raw) as Map).cast<String, Object?>(),
          );
    return JsonRelationAnnotationStore._(preferences, store);
  }

  RelationAnnotationStore persistentStore() {
    late RelationAnnotationStore persistent;
    persistent = RelationAnnotationStore(
      onChanged: () {
        _preferences.setString(_key, jsonEncode(persistent.toJson()));
      },
    );
    for (final raw in store.toJson()['items'] as List<Object?>) {
      final item = (raw as Map).cast<String, Object?>();
      persistent.upsert(
        caseId: item['caseId'] as String,
        recordId: item['recordId'] as String,
        note: item['note'] as String? ?? '',
        labels: [
          for (final label in item['labels'] as List<Object?>? ?? const [])
            label as String,
        ],
      );
    }
    return persistent;
  }
}
