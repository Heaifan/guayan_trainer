import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/relation_endpoint.dart';
import '../manual_relation_store.dart';

class JsonManualRelationStore {
  JsonManualRelationStore._(this._preferences, this.store);

  static const _key = 'guayan.case.manual-relations.v1';
  final SharedPreferences _preferences;
  final ManualRelationStore store;

  static Future<JsonManualRelationStore> open() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_key);
    final store = raw == null
        ? ManualRelationStore()
        : ManualRelationStore.fromJson(
            (jsonDecode(raw) as Map).cast<String, Object?>(),
          );
    return JsonManualRelationStore._(preferences, store);
  }

  ManualRelationStore persistentStore() {
    late ManualRelationStore persistent;
    persistent = ManualRelationStore(
      onChanged: () {
        _preferences.setString(_key, jsonEncode(persistent.toJson()));
      },
    );
    for (final raw in store.toJson()['records'] as List<Object?>) {
      final item = (raw as Map).cast<String, Object?>();
      persistent.create(
        caseId: item['caseId'] as String,
        id: item['id'] as String,
        from: RelationEndpoint.fromJson(
          (item['from'] as Map).cast<String, Object?>(),
        ),
        to: RelationEndpoint.fromJson(
          (item['to'] as Map).cast<String, Object?>(),
        ),
        title: item['title'] as String,
        note: item['note'] as String?,
      );
    }
    return persistent;
  }
}
