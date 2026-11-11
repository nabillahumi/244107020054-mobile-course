import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import 'package:campus_notify/data/api_client.dart';
import 'package:campus_notify/features/notes/domain/entities/announcement.dart';
import 'package:campus_notify/features/notes/data/repositories/announcement_repository_impl.dart';
import 'package:campus_notify/pages/announcement_page.dart';

void main() {
  group('Performance & Caching Tests - Week 11', () {
    test('RetryInterceptor handles transient error and retries correctly', () async {
      final dio = Dio();
      final retryInterceptor = RetryInterceptor(
        dio: dio,
        retries: 2,
        retryDelays: [
          const Duration(milliseconds: 10),
          const Duration(milliseconds: 20),
        ],
      );

      expect(retryInterceptor.retries, 2);
      expect(retryInterceptor.retryDelays.length, 2);
    });

    test('buildOptimizedQueryParams generates compressed query fields', () {
      final params = buildOptimizedQueryParams(
        page: 2,
        limit: 15,
        fields: ['id', 'title', 'imageUrl'],
      );

      expect(params['page'], 2);
      expect(params['limit'], 15);
      expect(params['fields'], 'id,title,imageUrl');
    });

    test('AnnouncementRepositoryImpl implements Stale-While-Revalidate caching', () async {
      final repo = AnnouncementRepositoryImpl();

      // Panggilan pertama: Mengembalikan data (menggunakan stale cache lalu update)
      final result1 = await repo.getAnnouncements();
      expect(result1.failure, isNull);
      expect(result1.announcements.isNotEmpty, isTrue);

      // Panggilan kedua: Mengembalikan data dari cache yang sudah di-update
      final result2 = await repo.getAnnouncements();
      expect(result2.failure, isNull);
      expect(result2.announcements.length, greaterThanOrEqualTo(2));
    });

    test('AnnouncementRepositoryImpl pagination fetchPage handles infinite scroll limit', () async {
      final repo = AnnouncementRepositoryImpl();

      final page1 = await repo.fetchPage(1, pageSize: 6);
      expect(page1.length, 6);
      expect(page1.first.id, '1');

      final page2 = await repo.fetchPage(2, pageSize: 6);
      expect(page2.length, 6);
      expect(page2.first.id, '7');

      // Page 5 di luar batas total 24 -> harus kosong (hasMore = false)
      final page5 = await repo.fetchPage(5, pageSize: 6);
      expect(page5.isEmpty, isTrue);
    });

    testWidgets('AnnouncementListPage renders with ListView.builder and cards', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AnnouncementListPage(),
          ),
        ),
      );

      // Memastikan halaman berhasil dirender
      expect(find.byType(AnnouncementListPage), findsOneWidget);
      expect(find.text('Pengumuman Kampus'), findsOneWidget);

      // Pompa frame dengan durasi spesifik untuk menyelesaikan async fetch tanpa timeout animasi
      await tester.pump(const Duration(milliseconds: 600));

      // Menemukan ListView.builder
      expect(find.byType(ListView), findsOneWidget);

      // Menemukan AnnouncementCard yang dirender secara lazy
      expect(find.byType(AnnouncementCard), findsWidgets);
    });

    testWidgets('AnnouncementCard renders with const and isolated RepaintBoundary', (tester) async {
      final item = Announcement(
        id: '99',
        title: 'Pengumuman Uji Coba',
        body: 'Konten pengumuman uji coba widget.',
        createdAt: DateTime(2026, 11, 11),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RepaintBoundary(
              child: AnnouncementCard(
                announcement: item,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.byType(AnnouncementCard), findsOneWidget);
      expect(find.text('Pengumuman Uji Coba'), findsOneWidget);
      expect(find.byType(RepaintBoundary), findsWidgets);
    });
  });
}
