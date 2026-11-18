import 'dart:async';
import 'package:dio/dio.dart';

import '../../../../core/failures.dart';
import '../../domain/entities/announcement.dart';
import '../../domain/repositories/announcement_repository.dart';
import '../models/announcement_model.dart';

/// Implementasi AnnouncementRepository dengan strategi caching Stale-While-Revalidate
/// dan dukungan Pagination (Infinite Scroll) untuk optimasi memori dan jaringan.
class AnnouncementRepositoryImpl implements AnnouncementRepository {
  final Dio? dio;

  // Local in-memory cache storage (mensimulasikan local storage/Hive/Box)
  final List<Announcement> _localCache = [];
  bool _isUsingCachedData = false;

  @override
  bool get isUsingCachedData => _isUsingCachedData;

  AnnouncementRepositoryImpl({this.dio}) {
    // Inisialisasi data cache awal (Stale cache)
    _initLocalCache();
  }

  void _initLocalCache() {
    _localCache.addAll([
      Announcement(
        id: '1',
        title: 'Pengumuman Libur Akademik Nasional',
        body:
            'Seluruh kegiatan perkuliahan ditiadakan menyambut hari libur nasional.',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        imageUrl: 'https://picsum.photos/seed/announcement1/300/200',
      ),
      Announcement(
        id: '2',
        title: 'Pendaftaran Beasiswa Unggulan Polinema',
        body:
            'Pendaftaran beasiswa prestasi dibuka hingga akhir bulan di gedung rektorat.',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        imageUrl: 'https://picsum.photos/seed/announcement2/300/200',
      ),
    ]);
  }

  /// Strategi Caching: Stale-While-Revalidate
  /// 1. Sajikan data dari cache lokal secara instan ke UI
  /// 2. Jalankan request ke API/jaringan di background untuk revalidasi
  /// 3. Perbarui cache lokal dengan data fresh
  /// 4. Fallback ke cache jika jaringan gagal
  @override
  Future<({List<Announcement> announcements, Failure? failure})>
  getAnnouncements() async {
    // 1. Sajikan cache lokal segera jika tersedia
    if (_localCache.isNotEmpty) {
      _isUsingCachedData = true;
    }

    try {
      // 2. Revalidasi data fresh dari server di latar belakang
      final freshData = await _fetchFromNetwork();

      // 3. Update cache lokal
      _localCache.clear();
      _localCache.addAll(freshData);
      _isUsingCachedData = false;

      return (
        announcements: List<Announcement>.from(_localCache),
        failure: null,
      );
    } catch (e) {
      // 4. Jika error jaringan tetapi cache ada, kembalikan cache sebagai fallback
      if (_localCache.isNotEmpty) {
        _isUsingCachedData = true;
        return (
          announcements: List<Announcement>.from(_localCache),
          failure: null,
        );
      }

      return (
        announcements: const <Announcement>[],
        failure: NetworkFailure(
          'Gagal memuat pengumuman dari server: ${e.toString()}',
        ),
      );
    }
  }

  Future<List<Announcement>> _fetchFromNetwork() async {
    // Gunakan konfigurasi client jika tersedia
    if (dio != null) {
      // Simulasi request jika dio terinjeksi
    }

    // Simulasi delay jaringan API
    await Future.delayed(const Duration(milliseconds: 350));

    // Data fresh dari API server kampus
    final List<Map<String, dynamic>> jsonList = [
      {
        'id': '1',
        'title': 'Pengumuman Libur Akademik Nasional (Terbaru)',
        'body':
            'Kegiatan perkuliahan ditiadakan, layanan administrasi online tetap buka.',
        'created_at': DateTime.now().toIso8601String(),
        'image_url': 'https://picsum.photos/seed/announcement1/300/200',
      },
      {
        'id': '2',
        'title': 'Pendaftaran Beasiswa Unggulan Polinema',
        'body':
            'Pendaftaran beasiswa prestasi resmi diperpanjang 7 hari ke depan.',
        'created_at': DateTime.now().toIso8601String(),
        'image_url': 'https://picsum.photos/seed/announcement2/300/200',
      },
      {
        'id': '3',
        'title': 'Workshop Optimasi Performa Flutter & Profiling',
        'body':
            'Pelatihan komprehensif DevTools, Flame Chart, dan Caching Mobile App.',
        'created_at': DateTime.now().toIso8601String(),
        'image_url': 'https://picsum.photos/seed/announcement3/300/200',
      },
    ];

    return jsonList.map((j) => AnnouncementModel.fromJson(j)).toList();
  }

  /// Mengambil data per halaman (Pagination / Infinite Scroll)
  /// Membatasi pemuatan data besar ke memori sekaligus
  @override
  Future<List<Announcement>> fetchPage(int page, {int pageSize = 6}) async {
    // Simulasi latensi pagination
    await Future.delayed(const Duration(milliseconds: 300));

    const int totalAvailable = 24;
    final int startIndex = (page - 1) * pageSize;

    if (startIndex >= totalAvailable) {
      return []; // Habis / no more data
    }

    final int endIndex = (startIndex + pageSize) > totalAvailable
        ? totalAvailable
        : startIndex + pageSize;

    final List<Announcement> pageItems = [];
    for (int i = startIndex; i < endIndex; i++) {
      final index = i + 1;
      pageItems.add(
        Announcement(
          id: '$index',
          title: 'Pengumuman Kampus Polinema #$index',
          body:
              'Detail edaran resmi kampus ke-$index terkait kegiatan akademik dan kemahasiswaan TI-3H.',
          createdAt: DateTime.now().subtract(Duration(hours: index * 3)),
          imageUrl: 'https://picsum.photos/seed/campus_$index/300/200',
        ),
      );
    }

    return pageItems;
  }
}
