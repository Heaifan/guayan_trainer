import 'rule_package_store.dart';
import '../../rule_execution_context.dart';

class GlobalRulePackRegistry {
  GlobalRulePackRegistry(this.store);

  final RulePackageStore store;

  Future<void> load() async => store.load();

  List<InstalledRulePack> get installedPacks => store.loadInstalled();

  List<InstalledRulePack> get enabledUserPacks =>
      installedPacks.where((item) => item.enabled).toList(growable: false);

  List<RulePackVersionRef> get enabledPackRefs => [
    for (final item in enabledUserPacks)
      RulePackVersionRef(item.package.packId, item.package.version.version),
  ];

  Future<void> setEnabled(String packId, bool enabled) async {
    final updated = installedPacks
        .map((item) => item.package.packId == packId
            ? InstalledRulePack(
                package: item.package,
                enabled: enabled,
                installedAt: item.installedAt,
              )
            : item)
        .toList();
    await store.saveInstalled(updated);
  }
}
