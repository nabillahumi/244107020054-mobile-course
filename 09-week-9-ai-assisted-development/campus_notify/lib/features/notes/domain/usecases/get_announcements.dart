import '../../../../core/failures.dart';
import '../entities/announcement.dart';
import '../repositories/announcement_repository.dart';

class GetAnnouncements {
  final AnnouncementRepository repository;

  GetAnnouncements(this.repository);

  Future<({List<Announcement> announcements, Failure? failure})> call() async {
    return await repository.getAnnouncements();
  }
}
