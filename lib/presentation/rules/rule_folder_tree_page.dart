import 'dart:convert';

import 'package:flutter/material.dart';

import '../../domain/rules/core/rule_definition.dart';
import '../../domain/rules/corpus/common_rule_corpus.dart';
import '../../domain/rules/editor/custom_rule_service.dart';
import '../../domain/rules/editor/custom_rule_store.dart';
import '../../domain/rules/editor/user_governance_state.dart';
import '../../domain/rules/library/rule_library_service.dart';
import '../../domain/rules/library/rule_library_store.dart';
import '../../domain/rules/library/rule_folder.dart';
import '../../domain/rules/packages/global_rule_pack_registry.dart';
import '../../domain/rules/packages/portable_rule_package.dart';
import '../../domain/rules/packages/rule_package_importer.dart';
import '../../domain/rules/packages/rule_package_store.dart';
import '../../services/rules/rule_package_file_adapter.dart';
import 'widgets/rule_folder_tree.dart';

class RuleFolderTreePage extends StatefulWidget {
  const RuleFolderTreePage({super.key, this.fileAdapter = const RulePackageFileAdapter()});

  final RulePackageFileAdapter fileAdapter;

  @override
  State<RuleFolderTreePage> createState() => _RuleFolderTreePageState();
}

class _RuleFolderTreePageState extends State<RuleFolderTreePage> {
  late final CustomRuleStore _customStore;
  late final CustomRuleService _customService;
  late final GlobalRulePackRegistry _registry;
  late final RuleLibraryService _library;
  late final RulePackageImporter _importer;
  RuleLibraryService? _loaded;
  List<RuleDefinition> _rules = [];

  @override
  void initState() {
    super.initState();
    _customStore = CustomRuleStore();
    _customService = CustomRuleService(_customStore, UserGovernanceState());
    _registry = GlobalRulePackRegistry(RulePackageStore());
    _library = RuleLibraryService(RuleLibraryStore());
    _importer = RulePackageImporter(
      store: _registry.store,
      registry: _registry,
      existingRules: CommonRuleCorpus.v1(),
      systemRuleIds: CommonRuleCorpus.v1().map((rule) => rule.ruleId),
      libraryService: _library,
    );
    _load();
  }

  Future<void> _load() async {
    await _customService.load();
    await _registry.load();
    await _library.load();
    final packageRules = [
      for (final item in _registry.installedPacks) ...item.package.rules,
    ];
    await _library.ensureMigrated([..._customStore.getAll(), ...packageRules]);
    if (!mounted) return;
    setState(() {
      _loaded = _library;
      _rules = [..._customStore.getAll(), ...packageRules];
    });
  }

  Future<void> _toggleFolder(String id, bool enabled) async {
    await _library.setFolderEnabled(id, enabled);
    await _load();
  }

  Future<void> _toggleExpanded(String id, bool expanded) async {
    await _library.setExpanded(id, expanded);
    await _load();
  }

  Future<void> _toggleRule(RuleDefinition rule, bool enabled) async {
    if (_customStore.getAll().any((item) => item.ruleId == rule.ruleId)) {
      await _customService.setEnabled(rule, enabled);
    } else {
      final pack = _registry.installedPacks.where(
        (item) => item.package.rules.any((candidate) => candidate.ruleId == rule.ruleId),
      );
      if (pack.isNotEmpty) await _registry.setEnabled(pack.first.package.packId, enabled);
    }
    await _load();
  }

  Future<void> _createFolder({String? parentFolderId}) async {
    final name = await _textDialog('新建文件夹');
    if (name != null && name.trim().isNotEmpty) {
      await _library.createFolder(name.trim(), parentFolderId: parentFolderId);
      await _load();
    }
  }

  Future<String?> _textDialog(String title) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          FilledButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('确定')),
        ],
      ),
    );
  }

  Future<void> _importJson({String? targetFolderId}) async {
    final text = await widget.fileAdapter.pickJson();
    if (!mounted || text == null) return;
    try {
      final package = PortableRulePackage.fromJson(
        Map<String, Object?>.from(jsonDecode(text) as Map),
      );
      final ok = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('导入规则包'),
          content: Text('${package.name}\nv${package.version} · ${package.rules.length} 条规则\n导入后全局启用'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('导入')),
          ],
        ),
      );
      if (ok == true) {
        final result = await _importer.install(package, targetFolderId: targetFolderId);
        if (!mounted) return;
        _message(result.isValid ? '已导入到导入规则' : result.errors.map((e) => e.message).join('\n'));
        await _load();
      }
    } catch (error) {
      if (mounted) _message(error.toString());
    }
  }

  void _message(String value) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));

  Future<void> _folderAction(RuleFolder folder, String action) async {
    if (action == 'import') {
      await _importJson(targetFolderId: folder.folderId);
      return;
    }
    if (action == 'child') {
      await _createFolder(parentFolderId: folder.folderId);
    } else if (action == 'move') {
      final target = await _chooseFolder(exclude: {folder.folderId});
      if (target != null) {
        await _library.moveFolder(folder.folderId, target);
        await _load();
      }
    } else if (action == 'rename') {
      final name = await _textDialog('重命名文件夹');
      if (name != null && name.trim().isNotEmpty) {
        await _library.renameFolder(folder.folderId, name.trim());
        await _load();
      }
    } else if (action == 'delete') {
      if (folder.isUncategorized) {
        _message('未分类不可删除');
        return;
      }
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('删除“${folder.name}”？'),
          content: const Text('文件夹及其内容将移动到上一级。删除规则内容需要再次确认。'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('移动内容并删除')),
          ],
        ),
      );
      if (confirmed == true) {
        await _library.deleteFolder(folder.folderId);
        await _load();
      }
    }
  }

  Future<void> _ruleAction(RuleDefinition rule, String action) async {
    if (action == 'move') {
      final target = await _chooseFolder();
      if (target != null) {
        await _library.moveRule(rule.ruleId.id, target);
        await _load();
      }
    } else if (action == 'delete') {
      if (_customStore.getAll().any((item) => item.ruleId == rule.ruleId)) {
        await _customStore.delete(rule.ruleId);
        await _load();
      } else {
        _message('导入规则请删除整个规则包');
      }
    }
  }

  Future<String?> _chooseFolder({Set<String> exclude = const {}}) => showDialog<String>(
    context: context,
    builder: (context) => SimpleDialog(
      title: const Text('选择文件夹'),
      children: [
        for (final folder in _library.index.folders)
          if (!exclude.contains(folder.folderId))
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, folder.folderId),
              child: Text(folder.name),
            ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final loaded = _loaded;
    return Scaffold(
      appBar: AppBar(
        title: const Text('自定义规则'),
        actions: [
          IconButton(onPressed: _importJson, icon: const Icon(Icons.file_upload_outlined), tooltip: '导入 JSON'),
          IconButton(onPressed: _createFolder, icon: const Icon(Icons.create_new_folder_outlined), tooltip: '新建文件夹'),
        ],
      ),
      body: loaded == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: RuleFolderTree(
                    index: loaded.index,
                    rules: _rules,
                    onFolderToggle: _toggleFolder,
                    onRuleToggle: _toggleRule,
                    onFolderAction: _folderAction,
                    onFolderExpanded: _toggleExpanded,
                    onRuleAction: _ruleAction,
                  ),
                ),
                if (_rules.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Text('还没有自定义规则'),
                  ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _importJson,
        icon: const Icon(Icons.file_upload_outlined),
        label: const Text('导入 JSON'),
      ),
    );
  }
}
