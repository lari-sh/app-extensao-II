import 'package:flutter_test/flutter_test.dart';
import 'package:abrigo_dos_anjos/ui/features/home/view_models/about_view_model.dart';

void main() {
  test('about exposes return action and shelter content', () {
    final vm = AboutViewModel();
    expect(vm.close(), '/');
    expect(vm.body, contains('lares responsáveis'));
    vm.dispose();
  });
}
