import '../core/rule_definition.dart';
import 'global_rule_pack_registry.dart';
import 'portable_rule_package.dart';
import 'rule_package_error.dart';
import 'rule_package_store.dart';
import 'rule_package_validator.dart';
import '../library/rule_folder.dart';
import '../library/rule_library_service.dart';

class RulePackageImporter {
  RulePackageImporter({
    required this.store,
    required this.registry,
    required this.existingRules,
    required this.systemRuleIds,
    this.installedMappingIds = const [],
    this.installedCustomShenShaIds = const [],
    this.libraryService,
  });

  final RulePackageStore store;
  final GlobalRulePackRegistry registry;
  final List<RuleDefinition> existingRules;
  final Iterable<dynamic> systemRuleIds;
  final Iterable<String> installedMappingIds;
  final Iterable<String> installedCustomShenShaIds;
  final RuleLibraryService? libraryService;

  Future<RulePackageValidationResult> install(
    PortableRulePackage package, {
    String? targetFolderId,
  }) async {
    await registry.load();
    final installed = registry.installedPacks;
    final validation = RulePackageValidator.validate(
      package,
      existingRules: existingRules,
      installedPacks: installed.map((item) => item.toRulePack()),
      systemRuleIds: systemRuleIds,
      installedMappingIds: installedMappingIds,
      installedCustomShenShaIds: installedCustomShenShaIds,
    );
    if (!validation.isValid) return validation;
    final next = [
      ...installed,
      InstalledRulePack(
        package: package,
        enabled: true,
        installedAt: DateTime.now().toUtc(),
      ),
    ];
    await store.saveInstalled(next);
    if (libraryService != null) {
      await libraryService!.load();
      final folderId = targetFolderId ?? RuleFolder.importedId;
      for (final rule in package.rules) {
        await libraryService!.moveRule(rule.ruleId.id, folderId);
      }
    }
    return validation;
  }
}
