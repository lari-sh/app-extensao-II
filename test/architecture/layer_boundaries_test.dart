import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

List<String> violations(String path, String source) {
  final errors = <String>[];
  final imports = RegExp(
    r'''(?:import|export)\s+['"]([^'"]+)['"]''',
  ).allMatches(source).map((m) => m[1]!);
  final isView = path.contains('/views/') || path.startsWith('lib/ui/core/');
  final isVm = path.contains('/view_models/');
  final isDomain = path.startsWith('lib/domain/');
  for (final uri in imports) {
    if (isView &&
        (uri.contains('/data/') ||
            uri.contains('/repositories/') ||
            uri.contains('/services/') ||
            (uri.startsWith('package:') &&
                !uri.startsWith('package:flutter/') &&
                !uri.startsWith('package:provider/') &&
                !uri.startsWith('package:abrigo_dos_anjos/')))) {
      errors.add('$path: infrastructure import in View');
    }
    if ((isVm || isDomain) &&
        (uri.contains('/data/') ||
            uri.contains('supabase') ||
            uri.contains('image_picker') ||
            uri.contains('shared_preferences'))) {
      errors.add('$path: infrastructure dependency in VM/domain');
    }
    if (isDomain && uri.contains('/ui/')) {
      errors.add('$path: UI dependency in domain');
    }
  }
  if (!path.startsWith('lib/data/services/') &&
      RegExp(r'\.(?:from|rpc)\s*\(').hasMatch(source)) {
    errors.add('$path: SDK query outside Services');
  }
  if (isView &&
      RegExp(
        r'\b(?:Supabase|SharedPreferences|ImagePicker|Clipboard|Repository|Service)\s*\.',
      ).hasMatch(source)) {
    errors.add('$path: infrastructure access in View');
  }
  return errors;
}

void main() {
  test('scanner rejects forbidden imports and query access', () {
    expect(
      violations(
        'lib/ui/features/auth/views/login_screen.dart',
        "import 'package:supabase_flutter/supabase_flutter.dart';",
      ),
      isNotEmpty,
    );
    expect(
      violations(
        'lib/ui/features/auth/view_models/login_view_model.dart',
        "import '../../../../data/services/auth_service.dart';",
      ),
      isNotEmpty,
    );
    expect(
      violations(
        'lib/data/repositories/animals_repository_impl.dart',
        "client.from('animals');",
      ),
      isNotEmpty,
    );
    expect(
      violations(
        'lib/ui/features/auth/views/login_screen.dart',
        "import 'package:provider/provider.dart';",
      ),
      isEmpty,
    );
  });
  test('migrated files respect the architectural boundaries', () {
    final paths = [
      'lib/app',
      'lib/config',
      'lib/utils',
      'lib/domain',
      'lib/ui',
      'lib/data/models',
      'lib/data/services',
      'lib/data/repositories',
    ];
    // Legacy is characterized separately until T100 removes it. Final gate checks
    // every remaining Dart file, so old paths cannot become a permanent bypass.
    if (!File('lib/data/animal_store.dart').existsSync()) paths.add('lib');
    final found = <String>{};
    final errors = <String>[];
    for (final root in paths) {
      if (!Directory(root).existsSync()) continue;
      for (final file in Directory(
        root,
      ).listSync(recursive: true).whereType<File>()) {
        final path = file.path.replaceAll('\\', '/');
        if (!path.endsWith('.dart') ||
            path.endsWith('.freezed.dart') ||
            !found.add(path)) {
          continue;
        }
        errors.addAll(violations(path, file.readAsStringSync()));
      }
    }
    expect(errors, isEmpty, reason: errors.join('\n'));
  });
}
