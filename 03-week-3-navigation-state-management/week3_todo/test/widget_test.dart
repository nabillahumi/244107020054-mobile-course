import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

import 'package:week3_todo/main.dart';
import 'package:week3_todo/providers/stats_provider.dart';

void main() {
  testWidgets('StatsPage menampilkan data setelah loading', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          statsProvider.overrideWith(
            () => StatsNotifier(forceFailure: false),
          ),
        ],
        child: const MyApp(),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pump();

    expect(find.text('Total Pengguna: 1.240'), findsOneWidget);
    expect(find.text('Pesanan Hari Ini: 86'), findsOneWidget);
    expect(find.text('Pendapatan: Rp12.500.000'), findsOneWidget);
  });
}