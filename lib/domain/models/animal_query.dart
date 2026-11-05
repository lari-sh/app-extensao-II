import 'package:freezed_annotation/freezed_annotation.dart';
import 'animal.dart';
part 'animal_query.freezed.dart';

@freezed
abstract class AnimalQuery with _$AnimalQuery {
  const factory AnimalQuery({
    @Default('') String name,
    AnimalSpecies? species,
    AnimalSex? sex,
    AnimalSize? size,
  }) = _AnimalQuery;
}
