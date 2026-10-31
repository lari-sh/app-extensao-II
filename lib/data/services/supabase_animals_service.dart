import 'dart:convert';
import '../../utils/app_failure.dart';
import 'service_result.dart';
import '../../utils/result.dart';
import '../models/animal_dto.dart';
import 'animals_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAnimalsService implements AnimalsService {
  SupabaseAnimalsService(this.client);
  final SupabaseClient client;

  PostgrestFilterBuilder<PostgrestList> _query(Map<String, String> filters) {
    var query = client
        .from('animals')
        .select()
        .eq('is_published', true)
        .neq('status', 'adopted');
    for (final field in ['species', 'sex', 'size']) {
      final value = filters[field];
      if (value != null && value.isNotEmpty) query = query.eq(field, value);
    }
    final name = filters['name']?.trim();
    if (name != null && name.isNotEmpty) {
      final literal = name
          .replaceAll(r'\', r'\\')
          .replaceAll('%', r'\%')
          .replaceAll('_', r'\_');
      query = query.ilike('name', '%$literal%');
    }
    return query;
  }

  @override
  Future<Result<AnimalsPageDto>> listPublic({
    required Map<String, String> filters,
    String? cursor,
  }) => serviceResult(() async {
    List<dynamic>? after;
    if (cursor != null) {
      if (cursor.length > 2048) {
        throw const ServiceFailure(FailureCode.validation);
      }
      final decoded = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(cursor))),
      );
      if (decoded is! List<dynamic>) {
        throw const ServiceFailure(FailureCode.validation);
      }
      after = decoded;
      if (after.length != 2 ||
          after[0] is! String ||
          after[1] is! String ||
          !RegExp(
            r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
          ).hasMatch(after[1] as String)) {
        throw const ServiceFailure(FailureCode.validation);
      }
    }
    final count = await _query(filters).limit(1).count(CountOption.exact);
    var query = _query(filters);
    if (after != null) {
      final name = jsonEncode(after[0]);
      query = query.or('name.gt.$name,and(name.eq.$name,id.gt.${after[1]})');
    }
    final rows = await query
        .order('name', ascending: true)
        .order('id', ascending: true)
        .limit(50);
    final items = rows.map(AnimalDto.fromJson).toList(growable: false);
    final next = items.length == 50
        ? base64Url.encode(
            utf8.encode(
              jsonEncode([items.last.values['name'], items.last.values['id']]),
            ),
          )
        : null;
    return AnimalsPageDto(items: items, total: count.count, cursor: next);
  });
  @override
  Future<Result<AnimalDto>> getPublic(String id) => serviceResult(() async {
    final row = await _query({}).eq('id', id).maybeSingle();
    if (row == null) throw const ServiceFailure(FailureCode.notFound);
    return AnimalDto.fromJson(row);
  });
  @override
  Future<Result<List<AnimalDto>>> getVisibleByIds(Set<String> ids) =>
      serviceResult(() async {
        if (ids.isEmpty) return <AnimalDto>[];
        final rows = await _query({})
            .inFilter('id', ids.toList())
            .order('name', ascending: true)
            .order('id', ascending: true);
        return rows.map(AnimalDto.fromJson).toList(growable: false);
      });
  @override
  Future<Result<ManagedAnimalsPageDto>> listManagement({
    String? status,
    String? cursor,
  }) async => Failure(AppFailure(FailureCode.configuration));
  @override
  Future<Result<ManagedAnimalDto>> getManagement(String id) async =>
      Failure(AppFailure(FailureCode.configuration));
  @override
  Future<Result<Map<String, int>>> getStatusCounts() async =>
      Failure(AppFailure(FailureCode.configuration));
  @override
  Future<Result<ManagedAnimalDto>> saveAnimal(
    Map<String, Object?> payload,
    String operationKey,
  ) async => Failure(AppFailure(FailureCode.configuration));
  @override
  Future<Result<AnimalDto>> setStatus(
    String id,
    String status,
    String operationKey,
  ) async => Failure(AppFailure(FailureCode.configuration));
  @override
  Future<Result<AnimalDto>> setPublication(
    String id,
    bool published,
    String operationKey,
  ) async => Failure(AppFailure(FailureCode.configuration));
  @override
  Future<Result<Map<String, dynamic>?>> getOperation(
    String operationKey,
  ) async => Failure(AppFailure(FailureCode.configuration));
}
