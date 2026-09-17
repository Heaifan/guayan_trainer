library;

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'custom_shen_sha_definition.dart';

class CustomShenShaStore {
  static const _key = 'guayan_custom_shen_sha_v1';
  List<CustomShenShaDefinition> _items = [];

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) {
      _items = [];
      return;
    }
    final list = (jsonDecode(raw) as List).cast<Map<String, Object?>>();
    _items = list.map(CustomShenShaDefinition.fromJson).toList();
  }

  List<CustomShenShaDefinition> getAll() => List.unmodifiable(_items);

  Future<void> addOrUpdate(CustomShenShaDefinition item) async {
    final index = _items.indexWhere((current) => current.id == item.id);
    if (index < 0) {
      _items.add(item);
    } else {
      _items[index] = item;
    }
    await _save();
  }

  Future<void> delete(String id, {Set<String> referencedIds = const {}}) async {
    if (referencedIds.contains(id)) {
      throw StateError('Cannot delete referenced custom ShenSha: $id');
    }
    _items.removeWhere((item) => item.id == id);
    await _save();
  }

  void seedForTest(List<CustomShenShaDefinition> items) {
    _items = List.of(items);
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(_items.map((item) => item.toJson()).toList()),
    );
  }
}
