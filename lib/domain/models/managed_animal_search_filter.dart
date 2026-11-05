import 'package:freezed_annotation/freezed_annotation.dart';
import 'animal.dart';
part 'managed_animal_search_filter.freezed.dart';

@freezed
abstract class ManagedAnimalSearchFilter with _$ManagedAnimalSearchFilter {
  const ManagedAnimalSearchFilter._();
  const factory ManagedAnimalSearchFilter({
    @Default('') String query,
    @Default('') String color,
    AnimalSpecies? species,
    AnimalSex? sex,
    AnimalSize? size,
    AnimalStatus? status,
  }) = _ManagedAnimalSearchFilter;
  ManagedAnimalSearchFilter get normalized =>
      copyWith(query: query.trim(), color: color.trim());
  bool get hasCriteria =>
      query.trim().isNotEmpty ||
      color.trim().isNotEmpty ||
      species != null ||
      sex != null ||
      size != null ||
      status != null;
  Map<String, String> validate() => {
    if (query.trim().runes.length > 80) 'query': 'length',
    if (color.trim().runes.length > 80) 'color': 'length',
  };
}
