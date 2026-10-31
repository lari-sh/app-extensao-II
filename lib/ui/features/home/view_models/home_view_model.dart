import 'package:flutter/foundation.dart';

class HomeViewModel extends ChangeNotifier {
  String get history => '❤️ Transformando abandono em amor há + de 10 anos';
  String get rescues => '🐶 +750 animais resgatados';
  String get title => 'Abrigo dos Anjos';
  String get headline => 'Um lar muda uma vida.';
  String get body =>
      'Conheça nossos animais e encontre um novo amigo para a sua família.';
  String openCatalog() => '/catalog';
  String openFavorites() => '/favorites';
  String openAbout() => '/about';
  String openVolunteer() => '/volunteer';
}
