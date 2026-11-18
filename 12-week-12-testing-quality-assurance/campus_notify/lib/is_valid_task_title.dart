/// Fungsi validasi judul tugas sesuai modul Jobsheet 12 (Langkah 3).
/// Mengembalikan true jika judul berisi teks setelah spasi di awal dan akhir diabaikan.
bool isValidTaskTitle(String value) {
  return value.trim().isNotEmpty;
}

/// Fungsi validasi judul tugas dengan batasan karakter untuk pengujian kasus tepi (edge cases).
/// Memeriksa teks tidak kosong, minimal panjang karakter (default 3), dan batas maksimum (default 50).
bool isValidTaskTitleWithLimits(
  String value, {
  int minLength = 3,
  int maxLength = 50,
}) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return false;
  if (trimmed.length < minLength) return false;
  if (trimmed.length > maxLength) return false;
  return true;
}
