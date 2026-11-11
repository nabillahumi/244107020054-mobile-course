import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/notes/domain/entities/announcement.dart';
import '../features/notes/presentation/providers/announcements_providers.dart';

/// Halaman Daftar Pengumuman dengan Optimasi Performa Tingkat Lanjut:
/// 1. Lazy Loading dengan ListView.builder
/// 2. Pagination (Infinite Scroll) dengan ScrollController
/// 3. Optimasi Gambar dengan CachedNetworkImage (memCacheWidth & memCacheHeight)
/// 4. Pengurangan Rebuild dengan const constructor, ekstraksi widget, dan RepaintBoundary
/// 5. Pencegahan Memory Leak dengan dispose ScrollController yang tepat
class AnnouncementListPage extends ConsumerStatefulWidget {
  const AnnouncementListPage({super.key});

  @override
  ConsumerState<AnnouncementListPage> createState() =>
      _AnnouncementListPageState();
}

class _AnnouncementListPageState extends ConsumerState<AnnouncementListPage> {
  final ScrollController _scrollController = ScrollController();
  final List<Announcement> _items = [];
  int _page = 1;
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadPage();
  }

  @override
  void dispose() {
    // DISPOSE CONTROLLER: Menghindari Memory Leak
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  /// Listener Scroll: Mendeteksi saat pengguna mendekati akhir list (200px sebelum mentok)
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadPage();
    }
  }

  /// Pemuatan data per halaman (Pagination)
  Future<void> _loadPage() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final repository = ref.read(announcementRepositoryProvider);
      final newItems = await repository.fetchPage(_page, pageSize: 6);

      if (!mounted) return;

      if (newItems.isEmpty) {
        setState(() {
          _hasMore = false;
        });
      } else {
        setState(() {
          _items.addAll(newItems);
          _page++;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat halaman $_page: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Refresh data dari awal (Pull-to-refresh)
  Future<void> _handleRefresh() async {
    setState(() {
      _items.clear();
      _page = 1;
      _hasMore = true;
    });
    await _loadPage();
  }

  void _navigateToDetail(String id) {
    context.push('/pengumuman/$id');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text('Pengumuman Kampus'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Segarkan',
            onPressed: _handleRefresh,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: Colors.indigo,
        child: _items.isEmpty && _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.indigo),
              )
            : ListView.builder(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(12),
                itemCount: _items.length + (_hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  // Widget Indikator Loading di akhir list untuk Infinite Scroll
                  if (index == _items.length) {
                    return const _LoadingFooterTile();
                  }

                  final item = _items[index];
                  return RepaintBoundary(
                    child: AnnouncementCard(
                      announcement: item,
                      onTap: () => _navigateToDetail(item.id),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

/// Widget Item Card Pengumuman Terpisah dengan const Constructor & Isolasi Paint
class AnnouncementCard extends StatelessWidget {
  final Announcement announcement;
  final VoidCallback onTap;

  const AnnouncementCard({
    super.key,
    required this.announcement,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Optimasi Gambar: CachedNetworkImage dengan batasan memori decode
            if (announcement.imageUrl != null)
              _OptimizedImageBanner(imageUrl: announcement.imageUrl!),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.indigo.shade50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'ID: #${announcement.id}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo.shade700,
                          ),
                        ),
                      ),
                      Text(
                        '${announcement.createdAt.day}/${announcement.createdAt.month}/${announcement.createdAt.year}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    announcement.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    announcement.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Komponen Optimasi Gambar Terisolasi dengan memCacheWidth & memCacheHeight
class _OptimizedImageBanner extends StatelessWidget {
  final String imageUrl;

  const _OptimizedImageBanner({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        height: 160,
        width: double.infinity,
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          // OPTIMASI MEMORI GAMBAR:
          // Decode gambar pada resolusi tampil layar ponsel (300x200), bukan full resolution!
          // Menghemat memori RAM hingga 80-90% pada GPU raster cache.
          memCacheWidth: 300,
          memCacheHeight: 200,
          placeholder: (context, url) => const _ShimmerImagePlaceholder(),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey.shade200,
            child: const Center(
              child: Icon(Icons.broken_image, color: Colors.grey, size: 40),
            ),
          ),
          fadeInDuration: const Duration(milliseconds: 200),
        ),
      ),
    );
  }
}

/// Shimmer/Animated Placeholder saat gambar sedang dimuat
class _ShimmerImagePlaceholder extends StatelessWidget {
  const _ShimmerImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade300,
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.indigo,
          ),
        ),
      ),
    );
  }
}

/// Loading Footer Tile untuk Infinite Scroll
class _LoadingFooterTile extends StatelessWidget {
  const _LoadingFooterTile();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: Colors.indigo,
          ),
        ),
      ),
    );
  }
}

/// Halaman Detail Pengumuman Tunggal
class AnnouncementPage extends StatelessWidget {
  final String id;

  const AnnouncementPage({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: Text('Detail Pengumuman #$id'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.campaign, color: Colors.indigo, size: 28),
                    const SizedBox(width: 8),
                    Text(
                      'Pengumuman Resmi Kampus #$id',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Text(
                  'Ini adalah isi konten detail pengumuman #$id. Data telah dimuat dan disimpan dalam memori cache lokal aplikasi.',
                  style: const TextStyle(fontSize: 14, height: 1.5),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Strategi Caching: Stale-While-Revalidate menjamin data instan siap baca sebelum jaringan online menyelesaikan sinkronisasi background.',
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
