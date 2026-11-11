import '../../../../core/failures.dart';
import '../entities/announcement.dart';

abstract class AnnouncementRepository {
  Future<({List<Announcement> announcements, Failure? failure})>
  getAnnouncements();

  Future<List<Announcement>> fetchPage(int page, {int pageSize = 6});

  bool get isUsingCachedData;
}
