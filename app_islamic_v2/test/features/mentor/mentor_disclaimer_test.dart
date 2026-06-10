import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_islamic_v2/features/mentor/ui/mentor_screen.dart';

void main() {
  testWidgets('M10 disclaimer always visible in mentor screen', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: MentorScreen()),
      ),
    );

    expect(find.textContaining('Disclaimer: Saran AI ini tidak menggantikan fatwa ulama'), findsOneWidget);
  });
}
