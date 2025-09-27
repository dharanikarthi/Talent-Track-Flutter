import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:talent_track/screens/discover/discover_screen.dart';

void main() {
  testWidgets('Discover loads categories and shows section headers', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: DiscoverScreen())));
    // First frame may be loading
    await tester.pumpAndSettle();
    // Verify at least one category header renders from assets
    expect(find.text('Full Body'), findsOneWidget);
  });
}