library;

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/rule_id.dart';

class UserGovernanceState {
  static const _key = 'guayan_disabled_sys_rules_v1';
  Set<RuleId> _disabledSystemRules = {};

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_key);
    if (str != null && str.isNotEmpty) {
      final List list = jsonDecode(str);
      _disabledSystemRules = list.map((e) => RuleId(e)).toSet();
    } else {
      _disabledSystemRules = {};
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _disabledSystemRules.map((e) => e.id).toList();
    await prefs.setString(_key, jsonEncode(list));
  }

  bool isSystemRuleDisabled(RuleId id) => _disabledSystemRules.contains(id);

  Future<void> setSystemRuleEnabled(RuleId id, bool enabled) async {
    if (enabled) {
      _disabledSystemRules.remove(id);
    } else {
      _disabledSystemRules.add(id);
    }
    await _save();
  }

  void seedForTest(Set<RuleId> disabled) {
    _disabledSystemRules = Set.of(disabled);
  }
}
