import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_vibe_1/main.dart';

void main() {
  testWidgets('home opens the interactive playground', (tester) async {
    await tester.pumpWidget(const VibeLabApp());

    expect(find.text('Your Flutter era\nstarts here.'), findsOneWidget);
    await tester.tap(find.text('Playground'));
    await tester.pumpAndSettle();

    expect(find.text('The playground'), findsOneWidget);
    expect(find.text('Pick a vibe'), findsOneWidget);
  });

  testWidgets('explore can filter and save a widget topic', (tester) async {
    await tester.pumpWidget(const VibeLabApp());
    await tester.tap(find.text('Explore'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('State'));
    await tester.pumpAndSettle();
    expect(find.text('setState'), findsOneWidget);
    expect(find.text('Container'), findsNothing);

    await tester.tap(find.byTooltip('Save topic'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Remove from saved'), findsOneWidget);

    await tester.tap(find.text('setState').first);
    await tester.pumpAndSettle();
    expect(find.text('Give your UI a pulse'), findsOneWidget);
    await tester.tap(find.byTooltip('Remove saved topic'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Save topic'), findsOneWidget);
  });

  testWidgets('quiz explains an answer and shows the result', (tester) async {
    await tester.pumpWidget(const VibeLabApp());
    await tester.tap(find.text('Quiz'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Widgets'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Almost everything you see'), findsOneWidget);
    await tester.ensureVisible(find.text('Next question'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next question'));
    await tester.pumpAndSettle();

    expect(
      find.text('Which widget puts children side by side?'),
      findsOneWidget,
    );
  });
}
