import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../utils/app_failure.dart';
part 'startup_view_model.freezed.dart';

@freezed
abstract class StartupState with _$StartupState {
  const factory StartupState({required String message}) = _StartupState;
}

final class StartupViewModel extends ChangeNotifier {
  StartupViewModel(FailureCode reason)
    : state = StartupState(
        message: reason == FailureCode.configuration
            ? 'O serviço ainda não está configurado. Entre em contato com o abrigo.'
            : 'O serviço está temporariamente indisponível. Tente novamente mais tarde.',
      );
  final StartupState state;
}
