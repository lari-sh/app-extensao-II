import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abrigo_dos_anjos/ui/features/team/views/team_screen.dart';

Future<void> revealTeamMember(WidgetTester tester, String name) async {
  final scrollable = find.descendant(
    of: find.byType(TeamScreen),
    matching: find.byType(Scrollable),
  );
  expect(scrollable, findsOneWidget);
  await tester.scrollUntilVisible(
    find.text(name),
    200,
    scrollable: scrollable,
    maxScrolls: 40,
  );
  expect(find.text(name), findsOneWidget);
  // The invitation action belongs to the same list, above the member cards.
  await tester.scrollUntilVisible(
    find.text('Convidar pessoa'),
    -200,
    scrollable: scrollable,
    maxScrolls: 40,
  );
}
