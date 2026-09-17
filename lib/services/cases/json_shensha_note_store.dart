import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/shensha/shensha_note_store.dart';

/// 把卦例级神煞备注绑定到本地 JSON；显示层仍只依赖领域 store。
class JsonShenShaNoteStore {
  JsonShenShaNoteStore._(this._preferences, this.store);

  static const _key = 'guayan.case.shensha-notes.v1';
  final SharedPreferences _preferences;
  final ShenShaNoteStore store;

  static Future<JsonShenShaNoteStore> open() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_key);
    final store = raw == null
        ? null
        : ShenShaNoteStore.fromJson(
            (jsonDecode(raw) as Map).cast<String, Object?>(),
          );
    late final JsonShenShaNoteStore result;
    final actual = store ?? ShenShaNoteStore();
    result = JsonShenShaNoteStore._(preferences, actual);
    return result;
  }

  Future<void> save() async {
    await _preferences.setString(_key, jsonEncode(store.toJson()));
  }

  ShenShaNoteStore persistentStore() {
    late ShenShaNoteStore persistent;
    persistent = ShenShaNoteStore(
      onChanged: (_) {
        _preferences.setString(_key, jsonEncode(persistent.toJson()));
      },
    );
    persistent._copyFrom(store);
    return persistent;
  }
}

extension on ShenShaNoteStore {
  void _copyFrom(ShenShaNoteStore other) {
    final restored = ShenShaNoteStore.fromJson(other.toJson());
    for (final raw in restored.toJson()['notes'] as List<Object?>) {
      final item = (raw as Map).cast<String, Object?>();
      save(
        caseId: item['caseId'] as String,
        shenShaId: item['shenShaId'] as String,
        content: item['content'] as String,
      );
    }
  }
}
