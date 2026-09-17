import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:week4_api/data/comment_providers.dart';
import 'package:week4_api/data/models/comment.dart';
import 'package:week4_api/main.dart';

void main() {
  testWidgets('Render MyApp Smoke Test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // Override provider agar tidak memanggil Dio/Internet asli saat testing
          commentListProvider(1).overrideWith(
            (ref) async => [
              const Comment(
                postId: 1,
                id: 1,
                name: 'Test Name',
                email: 'test@mail.com',
                body: 'Test Body',
              ),
            ],
          ),
        ],
        child: const MyApp(),
      ),
    );

    // Selesaikan animasi & rendering
    await tester.pumpAndSettle();

    expect(find.byType(MyApp), findsOneWidget);
  });
}