import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/cases/case_record.dart';
import '../../services/cases/case_query.dart';
import '../../services/cases/case_repository.dart';
import '../../services/cases/json_case_repository.dart';

/// 卦例档案库：查询、定位和管理历史真实排盘。
class CasesPage extends StatefulWidget {
  const CasesPage({super.key, this.repository, this.onOpenCase});
  final CaseRepository? repository;
  final ValueChanged<CaseRecord>? onOpenCase;
  @override State<CasesPage> createState() => _CasesPageState();
}

class _CasesPageState extends State<CasesPage> {
  CaseRepository? _repository;
  final _search = TextEditingController();
  Timer? _timer;
  List<CaseRecord> _items = [];
  final _selected = <String>{};
  String _range = '全部';
  bool _favoritesOnly = false, _deletedOnly = false, _loading = true, _hasMore = false;
  CaseSort _sort = CaseSort.descending;

  @override void initState() { super.initState(); _openRepository(); }
  @override void dispose() { _timer?.cancel(); _search.dispose(); super.dispose(); }

  Future<void> _openRepository() async {
    _repository = widget.repository ?? await JsonCaseRepository.open();
    await _reload();
  }

  Future<void> _reload() async {
    final repository = _repository;
    if (repository == null) return;
    if (mounted) setState(() => _loading = true);
    final result = await repository.list(_query());
    if (!mounted) return;
    setState(() { _items = result.items; _hasMore = result.hasMore; _selected.clear(); _loading = false; });
  }

  Future<void> _loadMore() async {
    final repository = _repository;
    if (repository == null || !_hasMore) return;
    final result = await repository.list(_query(offset: _items.length));
    if (!mounted) return;
    setState(() { _items = [..._items, ...result.items]; _hasMore = result.hasMore; });
  }

  CaseQuery _query({int offset = 0}) {
    final now = DateTime.now();
    DateTime? from;
    if (_range == '今天') from = DateTime(now.year, now.month, now.day);
    if (_range == '近 7 天') from = now.subtract(const Duration(days: 7));
    if (_range == '近 30 天') from = now.subtract(const Duration(days: 30));
    return CaseQuery(
      keyword: _search.text, from: from,
      to: _range == '今天' ? DateTime(now.year, now.month, now.day, 23, 59, 59, 999) : null,
      favoritesOnly: _favoritesOnly, deletedOnly: _deletedOnly, sort: _sort,
      offset: offset, limit: 20,
    );
  }

  void _searchChanged(String _) { _timer?.cancel(); _timer = Timer(const Duration(milliseconds: 500), _reload); }

  Future<void> _deleteSelected() async {
    for (final id in _selected) {
      await _repository?.softDelete(id);
    }
    await _reload();
  }

  Future<void> _permanentlyDelete(CaseRecord record) async {
    final ok = await showDialog<bool>(context: context, builder: (context) => AlertDialog(
      title: const Text('永久删除卦例？'), content: const Text('删除后无法恢复排盘事实、备注和规则记录。'),
      actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('永久删除'))],
    ));
    if (ok == true) { await _repository?.permanentlyDelete(record.id); await _reload(); }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('卦例'), actions: [IconButton(
      tooltip: _deletedOnly ? '返回卦例' : '回收站', icon: Icon(_deletedOnly ? Icons.folder_open_outlined : Icons.delete_outline),
      onPressed: () { setState(() => _deletedOnly = !_deletedOnly); _reload(); },
    )]),
    backgroundColor: const Color(0xFFF5F8F6),
    body: Column(children: [
      Padding(padding: const EdgeInsets.fromLTRB(14, 10, 14, 6), child: TextField(
        controller: _search, onChanged: _searchChanged,
        decoration: const InputDecoration(hintText: '搜索事项 / 卦名', prefixIcon: Icon(Icons.search), border: OutlineInputBorder()),
      )),
      _filters(),
      if (_selected.isNotEmpty && !_deletedOnly) Align(alignment: Alignment.centerRight, child: TextButton.icon(onPressed: _deleteSelected, icon: const Icon(Icons.delete_outline), label: Text('移入回收站（${_selected.length}）'))),
      Expanded(child: _loading ? const Center(child: CircularProgressIndicator()) : _items.isEmpty ? const Center(child: Text('暂无卦例')) : ListView.builder(
        padding: const EdgeInsets.fromLTRB(14, 2, 14, 24), itemCount: _items.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _items.length) return Center(child: TextButton(onPressed: _loadMore, child: const Text('加载更多')));
          final record = _items[index];
          return _CaseTile(record: record, deleted: _deletedOnly, selected: _selected.contains(record.id), onTap: () => widget.onOpenCase?.call(record), onSelect: (v) => setState(() => v ? _selected.add(record.id) : _selected.remove(record.id)), onFavorite: () async { await _repository?.setFavorite(record.id, !record.isFavorite); await _reload(); }, onRestore: () async { await _repository?.restore(record.id); await _reload(); }, onDelete: () => _permanentlyDelete(record));
        },
      )),
    ]),
  );

  Widget _filters() => SingleChildScrollView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2), child: Row(children: [
    for (final value in ['全部', '今天', '近 7 天', '近 30 天']) Padding(padding: const EdgeInsets.only(right: 6), child: ChoiceChip(label: Text(value), selected: _range == value, onSelected: (_) { setState(() => _range = value); _reload(); })),
    FilterChip(label: const Text('收藏'), selected: _favoritesOnly, onSelected: (v) { setState(() => _favoritesOnly = v); _reload(); }),
    const SizedBox(width: 8), DropdownButton<CaseSort>(value: _sort, onChanged: (v) { if (v == null) return; setState(() => _sort = v); _reload(); }, items: const [DropdownMenuItem(value: CaseSort.descending, child: Text('最新 ↓')), DropdownMenuItem(value: CaseSort.ascending, child: Text('最早 ↑'))]),
  ]));
}

class _CaseTile extends StatelessWidget {
  const _CaseTile({required this.record, required this.deleted, required this.selected, required this.onTap, required this.onSelect, required this.onFavorite, required this.onRestore, required this.onDelete});
  final CaseRecord record; final bool deleted, selected; final VoidCallback onTap, onFavorite, onRestore, onDelete; final ValueChanged<bool> onSelect;
  @override Widget build(BuildContext context) => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 4), leading: deleted ? null : Checkbox(value: selected, onChanged: (v) => onSelect(v ?? false)),
    title: Text('${record.isFavorite ? '★' : '☆'}  ${record.subjectDisplay}', maxLines: 1, overflow: TextOverflow.ellipsis),
    subtitle: Text('${_time(record.snapshot.castingTime)}\n${record.snapshot.originalHexagramName}${record.snapshot.changedHexagramName == null ? '' : ' → ${record.snapshot.changedHexagramName}'}'), isThreeLine: true,
    trailing: deleted ? IconButton(icon: const Icon(Icons.restore), onPressed: onRestore) : IconButton(icon: Icon(record.isFavorite ? Icons.star : Icons.star_border), onPressed: onFavorite), onTap: deleted ? null : onTap, onLongPress: deleted ? onDelete : null,
  );
}

String _time(DateTime value) => '${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')} ${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
