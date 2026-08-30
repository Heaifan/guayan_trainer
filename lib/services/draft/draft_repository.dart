/// 草稿持久化接口边界（任务书 §15：草稿自动保存，不要求每改一爻都点保存）。
///
/// Widget 不允许直接触碰存储；排卦页只依赖本接口，
/// 后续以本地存储实现替换 [InMemoryDraftRepository] 即可，页面代码不变。
library;

import 'casting_draft.dart';

/// 排卦草稿仓库接口。
abstract class DraftRepository {
  Future<void> save(CastingDraft draft);

  Future<CastingDraft?> load();

  Future<void> clear();
}

/// 内存实现：本轮打通接口边界，不做真实持久化。
class InMemoryDraftRepository implements DraftRepository {
  CastingDraft? _draft;

  @override
  Future<void> save(CastingDraft draft) async {
    _draft = draft;
  }

  @override
  Future<CastingDraft?> load() async => _draft;

  @override
  Future<void> clear() async {
    _draft = null;
  }
}
