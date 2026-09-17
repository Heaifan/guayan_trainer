import '../../domain/cases/case_record.dart';
import 'case_query.dart';

abstract class CaseRepository {
  Future<void> create(CaseRecord record);
  Future<CaseRecord?> read(String id);
  Future<CasePage> list(CaseQuery query);
  Future<void> update(CaseRecord record);
  Future<void> softDelete(String id);
  Future<void> restore(String id);
  Future<void> permanentlyDelete(String id);
  Future<void> setFavorite(String id, bool value);
  Future<String> metadataJsonForTest(String id);
}
