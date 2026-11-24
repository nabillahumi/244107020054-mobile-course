class AppFormat {
  // Fungsi murni formatting tanggal tanpa package intl
  static String formatDate(DateTime? date) {
    if (date == null) return '';

    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];

    final day = date.day.toString().padLeft(2, '0');
    final month = months[date.month];
    final year = date.year;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day $month $year, $hour:$minute';
  }

  // Fungsi murni parsing query parameters dari rute/URI
  static Map<String, String> parseRouteParams(String uriString) {
    final uri = Uri.parse(uriString);
    return uri.queryParameters;
  }
}
