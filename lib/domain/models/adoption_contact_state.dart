import 'package:freezed_annotation/freezed_annotation.dart';
part 'adoption_contact_state.freezed.dart';

@freezed
abstract class AdoptionContactState with _$AdoptionContactState {
  const factory AdoptionContactState({
    @Default(false) bool loading,
    @Default(false) bool opening,
    @Default(false) bool canContact,
    @Default('') String animalName,
    @Default(
      'No WhatsApp, você revisa e envia a mensagem quando quiser. O link público da ficha ainda não está disponível.',
    )
    String linkNotice,
    String? message,
  }) = _AdoptionContactState;
}
