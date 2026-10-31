import 'package:flutter_test/flutter_test.dart';
import 'package:abrigo_dos_anjos/ui/features/home/view_models/home_view_model.dart';

void main() {
  test('home commands expose public routes and Portuguese content', () {
    final vm = HomeViewModel();
    expect(vm.openCatalog(), '/catalog');
    expect(vm.openFavorites(), '/favorites');
    expect(vm.openAbout(), '/about');
    expect(vm.title, 'Abrigo dos Anjos');
    vm.dispose();
  });
}
