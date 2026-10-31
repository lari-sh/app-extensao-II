import 'package:flutter/foundation.dart';

class AboutViewModel extends ChangeNotifier {
  String get title => 'Sobre o abrigo';
  String get body =>
      'O Abrigo dos Anjos acolhe animais e ajuda a encontrar lares responsáveis. Cada adoção é uma nova chance de carinho e cuidado.';
  String close() => '/';
}
