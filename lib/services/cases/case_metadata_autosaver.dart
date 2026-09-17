import 'dart:async';

import 'case_repository.dart';

/// Case 元数据的 500ms 防抖保存器；Snapshot 与 RuleRun 永不被改写。
class CaseMetadataAutosaver {
  CaseMetadataAutosaver(this._repository, this._caseId);

  final CaseRepository _repository;
  final String _caseId;
  Timer? _timer;
  String? _subject;
  String? _note;

  void setSubject(String value) {
    _subject = value;
    _schedule();
  }

  void setNote(String value) {
    _note = value;
    _schedule();
  }

  Future<void> flush() async {
    _timer?.cancel();
    _timer = null;
    if (_subject == null && _note == null) return;
    final record = await _repository.read(_caseId);
    if (record == null) return;
    final updated = record.copyWith(subject: _subject, note: _note, updatedAt: DateTime.now());
    _subject = null;
    _note = null;
    await _repository.update(updated);
  }

  void _schedule() {
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 500), flush);
  }

  Future<void> disposeAsync() async => flush();
}
