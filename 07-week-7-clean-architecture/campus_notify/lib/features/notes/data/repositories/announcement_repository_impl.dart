import '../../../../core/failures.dart';
import '../../domain/entities/announcement.dart';
import '../../domain/repositories/announcement_repository.dart';
import '../models/announcement_model.dart';

class AnnouncementRepositoryImpl implements AnnouncementRepository {
  // Simulasi pemanggilan data (misal dari Dio/API)
  @override
  Future<({List<Announcement> announcements, Failure? failure})> getAnnouncements() async {
    try {
      // Contoh data dummy / eksekusi network client
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Simulasi hasil JSON dari server
      final List<Map<String, dynamic>> jsonList = [
        {
          'id': '1',
          'title': 'Libur Akademik',
          'body': 'Kampus libur memperingati hari besar.',
          'created_at': '2026-10-14T08:00:00Z',
        }
      ];

      final announcements = jsonList.map((json) => AnnouncementModel.fromJson(json)).toList();
      return (announcements: announcements, failure: null);
    } catch (e) {
      return (
        announcements: const <Announcement>[], // Berikan tipe eksplisit di sini
        failure: NetworkFailure('Gagal memuat pengumuman dari server. Periksa koneksi Anda.'),
      );
    }
  }
}