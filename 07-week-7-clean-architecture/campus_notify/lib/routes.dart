// <--- TAMBAHAN REFACTORING CHALLENGE
// Semua konstanta route aplikasi disimpan di satu tempat.

class AppRoutes {
  static const login = '/login';
  static const home = '/';
  static const announcement = '/pengumuman/:id';

  // Route untuk navigasi ke pengumuman tertentu.
  static String announcementDetail(String id) {
    return '/pengumuman/$id';
  }
}
/// Fungsi murni parsing payload FCM ke rute GoRouter
  String routeFromMessage(Map<String, dynamic> data) {
    final route = data['route']?.toString() ?? AppRoutes.home;
    if (route.isEmpty) return AppRoutes.home;
    return route.startsWith('/') ? route : '/$route';
  }

