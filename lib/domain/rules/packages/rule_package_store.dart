import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../core/rule_origin.dart';
import '../packs/rule_pack.dart';
import '../packs/rule_pack_id.dart';
import '../packs/rule_pack_scope.dart';
import 'portable_rule_package.dart';

class InstalledRulePack {
  const InstalledRulePack({
    required this.package,
    required this.enabled,
    required this.installedAt,
  });

  final PortableRulePackage package;
  final bool enabled;
  final DateTime installedAt;

  RulePack toRulePack() => RulePack(
    packId: RulePackId(package.packId),
    version: package.version,
    origin: RuleOrigin.CUSTOM,
    scope: RulePackScope.COMMON,
    title: package.name,
    ruleIds: package.rules.map((rule) => rule.ruleId).toList(),
  );

  Map<String, Object?> toJson() => {
    'package': package.toJson(),
    'enabled': enabled,
    'installedAt': installedAt.toIso8601String(),
  };

  factory InstalledRulePack.fromJson(Map<String, Object?> json) =>
      InstalledRulePack(
        package: PortableRulePackage.fromJson(
          Map<String, Object?>.from(json['package'] as Map),
        ),
        enabled: json['enabled'] as bool? ?? true,
        installedAt: DateTime.parse(json['installedAt'] as String),
      );
}

class RulePackageStore {
  static const _key = 'guayan_rule_packages_v1';

  final SharedPreferences? preferences;
  List<InstalledRulePack> _items = [];

  RulePackageStore({this.preferences});

  Future<void> load() async {
    final prefs = preferences ?? await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    _items = raw == null
        ? []
        : (jsonDecode(raw) as List)
              .map((item) => InstalledRulePack.fromJson(
                    Map<String, Object?>.from(item as Map),
                  ))
              .toList();
  }

  List<InstalledRulePack> loadInstalled() => List.unmodifiable(_items);

  Future<void> saveInstalled(List<InstalledRulePack> items) async {
    final prefs = preferences ?? await SharedPreferences.getInstance();
    final payload = jsonEncode(items.map((item) => item.toJson()).toList());
    if (!await prefs.setString(_key, payload)) {
      throw StateError('规则包存储失败');
    }
    _items = List.of(items);
  }
}
