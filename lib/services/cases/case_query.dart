import '../../domain/cases/case_record.dart';

enum CaseSort { descending, ascending }

class CaseQuery {
  const CaseQuery({
    this.keyword = '',
    this.from,
    this.to,
    this.favoritesOnly = false,
    this.deletedOnly = false,
    this.sort = CaseSort.descending,
    this.offset = 0,
    this.limit = 20,
  });

  final String keyword;
  final DateTime? from;
  final DateTime? to;
  final bool favoritesOnly;
  final bool deletedOnly;
  final CaseSort sort;
  final int offset;
  final int limit;
}

class CasePage {
  const CasePage({required this.items, required this.hasMore});

  final List<CaseRecord> items;
  final bool hasMore;
}
