import 'package:freezed_annotation/freezed_annotation.dart';
part 'photo_content.freezed.dart';

@freezed
abstract class PhotoContent with _$PhotoContent {
  const factory PhotoContent({required List<int> bytes, required String mime}) =
      _PhotoContent;
}
