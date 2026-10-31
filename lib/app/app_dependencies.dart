import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

/// Registrations are explicit and constructors remain independently testable.
/// Feature factories must start VM work before mounting, not in lazy providers.
final class AppDependencies {
  const AppDependencies();
  Widget provide({
    required List<SingleChildWidget> registrations,
    required Widget child,
  }) => MultiProvider(providers: registrations, child: child);
}
