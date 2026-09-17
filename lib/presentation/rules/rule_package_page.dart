import 'dart:convert';

import 'package:flutter/material.dart';

import '../../domain/rules/corpus/common_rule_corpus.dart';
import '../../domain/rules/packages/global_rule_pack_registry.dart';
import '../../domain/rules/packages/portable_rule_package.dart';
import '../../domain/rules/packages/rule_package_importer.dart';
import '../../domain/rules/packages/rule_package_store.dart';
import '../../services/rules/rule_package_file_adapter.dart';

class RulePackagePage extends StatefulWidget {
  const RulePackagePage({
    super.key,
    this.registry,
    this.importer,
    this.fileAdapter = const RulePackageFileAdapter(),
  });

  final GlobalRulePackRegistry? registry;
  final RulePackageImporter? importer;
  final RulePackageFileAdapter fileAdapter;

  @override
  State<RulePackagePage> createState() => _RulePackagePageState();
}

class _RulePackagePageState extends State<RulePackagePage> {
  late final GlobalRulePackRegistry _registry;
  late final RulePackageImporter _importer;
  List<InstalledRulePack> _items = [];

  @override
  void initState() {
    super.initState();
    final store = widget.registry?.store ?? RulePackageStore();
    _registry = widget.registry ?? GlobalRulePackRegistry(store);
    _importer = widget.importer ?? RulePackageImporter(
      store: store,
      registry: _registry,
      existingRules: CommonRuleCorpus.v1(),
      systemRuleIds: CommonRuleCorpus.v1().map((rule) => rule.ruleId),
    );
    _load();
  }

  Future<void> _load() async {
    await _registry.load();
    if (mounted) setState(() => _items = _registry.installedPacks);
  }

  Future<void> _importJson() async {
    final text = await widget.fileAdapter.pickJson();
    if (!mounted || text == null) return;
    try {
      final package = PortableRulePackage.fromJson(
        Map<String, Object?>.from(jsonDecode(text) as Map),
      );
      final shouldInstall = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('导入规则包'),
          content: Text(
            '名称：${package.name}\n版本：${package.version}\n规则：${package.rules.length}\n'
            'Mapping：${package.mappings.length}\n自定义神煞：${package.customShensha.length}\n\n'
            '状态：校验通过\n导入后全局启用',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('导入')),
          ],
        ),
      );
      if (shouldInstall != true) return;
      final result = await _importer.install(package);
      if (!mounted) return;
      if (result.isValid) {
        await _load();
        _message('已安装 · 已全局启用');
      } else {
        _message(result.errors.map((error) => error.message).join('\n'));
      }
    } catch (error) {
      if (mounted) _message(_humanError(error));
    }
  }

  Future<void> _export(InstalledRulePack item) async {
    final ok = await widget.fileAdapter.saveJson(
      const JsonEncoder.withIndent('  ').convert(item.package.toJson()),
      fileName: '${item.package.packId}.json',
    );
    if (mounted && ok) _message('已导出 JSON');
  }

  Future<void> _toggle(InstalledRulePack item, bool enabled) async {
    await _registry.setEnabled(item.package.packId, enabled);
    await _load();
  }

  Future<void> _delete(InstalledRulePack item) async {
    final next = _registry.installedPacks
        .where((current) => current.package.packId != item.package.packId)
        .toList();
    await _registry.store.saveInstalled(next);
    await _load();
  }

  void _message(String message) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(message)));

  String _humanError(Object error) {
    final text = error.toString();
    if (text.contains('FormatException')) return 'JSON 文件损坏';
    return text;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('用户规则包'),
      actions: [
        IconButton(
          key: const Key('import_rule_package'),
          onPressed: _importJson,
          icon: const Icon(Icons.file_upload_outlined),
          tooltip: '导入 JSON',
        ),
      ],
    ),
    body: _items.isEmpty
        ? const Center(child: Text('暂无用户规则包'))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _items.length,
            itemBuilder: (context, index) {
              final item = _items[index];
              return Card(
                child: ListTile(
                  title: Text(item.package.name),
                  subtitle: Text('v${item.package.version} · ${item.package.rules.length} 条规则'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(onPressed: () => _export(item), icon: const Icon(Icons.file_download_outlined)),
                      Switch(value: item.enabled, onChanged: (value) => _toggle(item, value)),
                      IconButton(onPressed: () => _delete(item), icon: const Icon(Icons.delete_outline)),
                    ],
                  ),
                ),
              );
            },
          ),
    floatingActionButton: FloatingActionButton.extended(
      key: const Key('import_rule_package_fab'),
      onPressed: _importJson,
      icon: const Icon(Icons.file_upload_outlined),
      label: const Text('导入 JSON'),
    ),
  );
}
