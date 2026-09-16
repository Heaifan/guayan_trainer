library;

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/rule_definition.dart';
import '../core/rule_id.dart';
import 'rule_definition_codec.dart';

class CustomRuleStore {
  static const _key = 'guayan_custom_rules_v1';
  List<RuleDefinition> _rules = [];

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_key);
    if (str != null && str.isNotEmpty) {
      final List list = jsonDecode(str);
      _rules = list.map((e) => RuleDefinitionCodec.fromJson(e)).toList();
    } else {
      _rules = [];
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _rules.map(RuleDefinitionCodec.toJson).toList();
    await prefs.setString(_key, jsonEncode(list));
  }

  List<RuleDefinition> getAll() => List.unmodifiable(_rules);

  Future<void> addOrUpdate(RuleDefinition rule) async {
    final idx = _rules.indexWhere((r) => r.ruleId == rule.ruleId);
    if (idx >= 0) {
      _rules[idx] = rule;
    } else {
      _rules.add(rule);
    }
    await _save();
  }

  Future<void> delete(RuleId ruleId) async {
    _rules.removeWhere((r) => r.ruleId == ruleId);
    await _save();
  }

  // Set initial rules for tests without saving
  void seedForTest(List<RuleDefinition> rules) {
    _rules = List.of(rules);
  }
}
