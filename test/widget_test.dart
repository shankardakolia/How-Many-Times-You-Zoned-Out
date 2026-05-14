import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:zone_out/providers/zone_out_provider.dart';
import 'package:zone_out/providers/stats_provider.dart';
import 'package:zone_out/screens/tracker_screen.dart';

void main() {
  testWidgets('Tracker screen renders correctly', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ZoneOutProvider()),
          ChangeNotifierProvider(create: (_) => StatsProvider()),
        ],
        child: const MaterialApp(
          home: TrackerScreen(),
        ),
      ),
    );

    expect(find.text('Today\'s Zone Outs'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);
    expect(find.text('Zoned Out'), findsOneWidget);
  });

  testWidgets('Tracker screen tap increments', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ZoneOutProvider()),
          ChangeNotifierProvider(create: (_) => StatsProvider()),
        ],
        child: const MaterialApp(
          home: TrackerScreen(),
        ),
      ),
    );

    await tester.tap(find.text('Zoned Out'));
    await tester.pumpAndSettle();
  });
}
