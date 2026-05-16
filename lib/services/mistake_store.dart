import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/mistake_item.dart';

/// 错题持久化存储器。
///
/// 每次修改后自动保存到 SharedPreferences。
class MistakeStore {
  MistakeStore._();

  static final MistakeStore instance = MistakeStore._();

  List<MistakeItem> _items = [];
  bool _loaded = false;

  /// 当前所有错题。
  List<MistakeItem> get all => List.unmodifiable(_items);

  Future<void> _ensureLoaded() async {
    if (!_loaded) await _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('mistake_items');
    if (raw != null) {
      final list = json.decode(raw) as List<dynamic>;
      _items = list
          .map((e) => MistakeItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    _loaded = true;
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = json.encode(_items.map((e) => e.toJson()).toList());
    await prefs.setString('mistake_items', raw);
  }

  /// 添加或更新错题（按 id 去重）。
  Future<void> addOrUpdateMistake(MistakeItem item) async {
    await _ensureLoaded();
    final idx = _items.indexWhere((e) => e.id == item.id);
    if (idx >= 0) {
      _items[idx] = item;
    } else {
      _items.add(item);
    }
    await _save();
  }

  /// 按 id 移除错题。
  Future<void> removeMistake(String id) async {
    await _ensureLoaded();
    _items.removeWhere((e) => e.id == id);
    await _save();
  }

  /// 清空所有错题。
  Future<void> clearAll() async {
    await _ensureLoaded();
    _items.clear();
    await _save();
  }

  /// 按模块/主题筛选。
  List<MistakeItem> getByTopic(String module, String topic) {
    return _items
        .where((e) => e.module == module && e.topic == topic)
        .toList();
  }
}
