import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'rule_library_index.dart';

class RuleLibraryStore {
  static const key = 'guayan_rule_library_index_v1';

  RuleLibraryStore({this.preferences});

  final SharedPreferences? preferences;

  Future<RuleLibraryIndex> load() async {
    final prefs = preferences ?? await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    if (raw == null) return RuleLibraryIndex.defaults();
    try {
      return RuleLibraryIndex.fromJson(
        Map<String, Object?>.from(jsonDecode(raw) as Map),
      );
    } catch (_) {
      return RuleLibraryIndex.defaults();
    }
  }

  Future<void> save(RuleLibraryIndex index) async {
    final prefs = preferences ?? await SharedPreferences.getInstance();
    if (!await prefs.setString(key, jsonEncode(index.toJson()))) {
      throw StateError('规则库索引存储失败');
    }
  }
}
