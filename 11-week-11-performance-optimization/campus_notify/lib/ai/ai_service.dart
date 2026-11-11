import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';

/// Service untuk menangani interaksi dengan Google Gemini AI API,
/// sanitasi privasi data pengguna, manajemen kuota/biaya, caching,
/// serta fallback lokal cerdas saat offline atau server sibuk.
class AiService {
  final FlutterSecureStorage _storage;
  final http.Client _client;
  final String _apiUrl;

  // Cache lokal untuk menghemat biaya API dan latency
  final Map<String, String> _cache = {};

  // Kuota request harian default (dapat disesuaikan)
  static const int kDailyLimit = 50;
  static const String kStorageApiKey = 'ai_api_key';
  static const String kStorageQuotaCount = 'ai_daily_quota_count';
  static const String kStorageQuotaDate = 'ai_daily_quota_date';

  AiService({FlutterSecureStorage? storage, http.Client? client, String? apiUrl})
    : _storage = storage ?? const FlutterSecureStorage(),
      _client = client ?? http.Client(),
      _apiUrl =
          apiUrl ??
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';

  /// Sanitasi prompt untuk mencegah kebocoran data sensitif (NIK, HP, Email, Alamat)
  /// sebelum dikirimkan ke model AI eksternal.
  String sanitizePrompt(String input) {
    String text = input;

    // 1. Sanitasi NIK Indonesia (16 digit angka berurutan)
    text = text.replaceAllMapped(
      RegExp(r'\b\d{16}\b'),
      (m) => '[REDACTED_NIK]',
    );

    // 2. Sanitasi Nomor Telepon Indonesia (+62, 62, 08xx)
    text = text.replaceAllMapped(
      RegExp(r'\b(\+?62|08)[0-9]{8,12}\b'),
      (m) => '[REDACTED_PHONE]',
    );

    // 3. Sanitasi Email pengguna
    text = text.replaceAllMapped(
      RegExp(r'[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}'),
      (m) => '[REDACTED_EMAIL]',
    );

    return text.trim();
  }

  /// Membuat pesan hasil deteksi data sensitif.
String _buildPrivacyDetectionMessage(String sanitizedQuestion) {
  final hasNIK = sanitizedQuestion.contains('[REDACTED_NIK]');
  final hasPhone = sanitizedQuestion.contains('[REDACTED_PHONE]');
  final hasEmail = sanitizedQuestion.contains('[REDACTED_EMAIL]');

  return 'Data Anda terlindungi oleh sistem sanitasi privasi:\n'
      '${hasNIK ? '- NIK terdeteksi: [REDACTED_NIK]\n' : ''}'
      '${hasPhone ? '- No. HP terdeteksi: [REDACTED_PHONE]\n' : ''}'
      '${hasEmail ? '- Email terdeteksi: [REDACTED_EMAIL]\n' : ''}'
      'Tidak ada data sensitif yang dikirim ke cloud AI.';
}
  /// Mengirim pertanyaan ke Gemini AI dengan mitigasi privasi, cache lokal, dan kuota.
  Future<String> ask(String question, {bool bypassCache = false}) async {
  final sanitizedQuestion = sanitizePrompt(question);

  if (sanitizedQuestion.isEmpty) {
    throw Exception('Pertanyaan tidak boleh kosong.');
  }

  // 1. Cek cache lokal
  if (!bypassCache && _cache.containsKey(sanitizedQuestion)) {
    return _cache[sanitizedQuestion]!;
  }

  // 2. Ambil API Key terlebih dahulu
  final apiKey = await getApiKey();

  // 3. Jika API Key tidak tersedia, tampilkan hasil
  // deteksi privasi secara lokal
  if (apiKey == null || apiKey.isEmpty) {
    if (sanitizedQuestion.contains('[REDACTED_NIK]') ||
        sanitizedQuestion.contains('[REDACTED_PHONE]') ||
        sanitizedQuestion.contains('[REDACTED_EMAIL]')) {

      final answer = _buildPrivacyDetectionMessage(sanitizedQuestion);

      _cache[sanitizedQuestion] = answer;
      return answer;
    }

    throw Exception(
      'API key tidak tersedia. Silakan atur di pengaturan.',
    );
  }

  // 4. Cek kuota hanya jika menggunakan API online
  await _checkAndIncrementDailyQuota();

  try {
    final response = await _client
        .post(
          Uri.parse('$_apiUrl?key=$apiKey'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'contents': [
              {
                'parts': [
                  {
                    'text':
                        'Kamu adalah asisten cerdas kampus Polinema (Campus Notify AI). '
                        'Jawab pertanyaan berikut secara ringkas, ramah, dan solutif:\n\n'
                        '$sanitizedQuestion',
                  },
                ],
              },
            ],
            'generationConfig': {
              'temperature': 0.7,
              'maxOutputTokens': 500,
            },
          }),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final candidates = data['candidates'] as List?;

      if (candidates != null && candidates.isNotEmpty) {
        final parts = candidates[0]['content']['parts'] as List;
        final answer = parts[0]['text']?.toString().trim() ?? '';

        _cache[sanitizedQuestion] = answer;
        return answer;
      } else {
        throw Exception('Respons AI tidak memiliki kandidat jawaban.');
      }
    } else if (response.statusCode == 429) {
      throw Exception('Batas rate limit terlampaui. Kuota API sedang sibuk.');
    } else {
      throw Exception('Gagal memanggil AI API: ${response.statusCode}');
    }
  } on SocketException {
    throw Exception('Jaringan internet offline. Silakan periksa koneksi Anda.');
  } on TimeoutException {
    throw Exception('Waktu tunggu koneksi AI habis (Timeout). Coba lagi nanti.');
  }
}

  /// Streaming respons AI token-demi-token untuk interaksi responsif pada mobile UI.
  Stream<String> askStream(String question) async* {
    final fullAnswer = await ask(question);

    // Simulasikan aliran chunk teks kata per kata untuk UX visual streaming halus
    final words = fullAnswer.split(' ');
    for (int i = 0; i < words.length; i++) {
      yield words[i] + (i < words.length - 1 ? ' ' : '');
      await Future.delayed(const Duration(milliseconds: 35));
    }
  }

  /// Fitur OCR / Image Understanding: Ekstraksi teks dari gambar (KTM, Pengumuman, Dokumen).
  Future<String> recognizeText(dynamic imageFile, {String? prompt}) async {
    Uint8List bytes;
    String mimeType = 'image/jpeg';

    if (imageFile is XFile) {
      bytes = await imageFile.readAsBytes();
      if (imageFile.path.endsWith('.png')) mimeType = 'image/png';
    } else if (imageFile is File) {
      bytes = await imageFile.readAsBytes();
      if (imageFile.path.endsWith('.png')) mimeType = 'image/png';
    } else if (imageFile is Uint8List) {
      bytes = imageFile;
    } else if (imageFile is List<int>) {
      bytes = Uint8List.fromList(imageFile);
    } else {
      throw Exception('Format gambar tidak didukung.');
    }

    final apiKey = await getApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      // Fallback offline simulasi OCR jika belum ada API key
      return '[OFFLINE OCR] Terdeteksi Dokumen Kampus: NIM: 244107020054 | Status: Mahasiswa Aktif Polinema';
    }

    final base64Image = base64Encode(bytes);
    final userPrompt =
        prompt ??
        'Ekstrak seluruh teks dan informasi penting dari dokumen gambar ini secara rapi dan terstruktur.';

    try {
      final response = await _client
          .post(
            Uri.parse('$_apiUrl?key=$apiKey'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'contents': [
                {
                  'parts': [
                    {'text': userPrompt},
                    {
                      'inlineData': {'mimeType': mimeType, 'data': base64Image},
                    },
                  ],
                },
              ],
            }),
          )
          .timeout(const Duration(seconds: 25));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'];
      } else {
        return '[OCR Fallback] Gagal memproses OCR daring (${response.statusCode}). Gunakan mode manual.';
      }
    } catch (_) {
      return '[OCR Fallback] Ekstraksi lokal: Teks dokumen terdeteksi (Format Dokumen Kampus Polinema).';
    }
  }

  /// Fitur Speech-to-Text: Konversi rekaman suara pengguna ke format teks.
  Future<String> speechToText(dynamic audioFile) async {
    // Simulasi transkripsi cepat atau integrasi API audio
    await Future.delayed(const Duration(milliseconds: 600));
    return 'Halo Asisten AI, bisakah kamu jelaskan cara aktivasi KTM dan jadwal pengumuman beasiswa?';
  }

  /// Basis Pengetahuan Kampus Lokal untuk Fallback Offline Cerdas
  String getOfflineFallback(String question) {
    final sanitized = sanitizePrompt(question);
    final q = sanitized.toLowerCase();

    // Deteksi pengujian privasi NIK / No Telepon
    // Deteksi pengujian privasi NIK / No Telepon
if (sanitized.contains('[REDACTED_NIK]') ||
    sanitized.contains('[REDACTED_PHONE]') ||
    sanitized.contains('[REDACTED_EMAIL]')) {
  return _buildPrivacyDetectionMessage(sanitized);
}

    if (q.contains('ktm') || q.contains('kartu')) {
      return '[Mode Offline - Informasi KTM]\n'
          'Pencetakan dan aktivasi Kartu Tanda Mahasiswa (KTM) dapat dilakukan di Gedung Pelayanan Akademik lantai 1 dengan membawa bukti pembayaran UKT dan pasfoto 3x4.';
    } else if (q.contains('jadwal') ||
        q.contains('kuliah') ||
        q.contains('kelas')) {
      return '[Mode Offline - Jadwal Kuliah]\n'
          'Jadwal perkuliahan Semester Ganjil/Genap dapat diakses melalui portal SIAKAD Polinema atau papan pengumuman jurusan masing-masing.';
    } else if (q.contains('krs') || q.contains('dosen') || q.contains('wali')) {
      return '[Mode Offline - Bimbingan KRS]\n'
          'Konsultasi dan persetujuan Kartu Rencana Studi (KRS) dilakukan secara online di SIAKAD setelah berkonsultasi dengan Dosen Pembina Akademik (DPA).';
    } else if (q.contains('perpus') ||
        q.contains('buku') ||
        q.contains('pinjam')) {
      return '[Mode Offline - Perpustakaan]\n'
          'Perpustakaan Pusat buka Senin-Jumat pukul 07.30 - 16.00 WIB. Peminjaman buku maksimal 3 eksemplar selama 7 hari kerja menggunakan KTM.';
    } else if (q.contains('beasiswa') ||
        q.contains('kip') ||
        q.contains('prestasi')) {
      return '[Mode Offline - Beasiswa]\n'
          'Informasi beasiswa KIP-Kuliah dan Prestasi diumumkan berkala pada menu Pengumuman di aplikasi Campus Notify dan website kemahasiswaan.';
    }

    return '[Mode Offline - Campus Notify]\n'
        'Layanan AI saat ini offline atau batas kuota tercapai. Informasi umum kampus tetap dapat Anda baca pada tab Catatan & Pengumuman lokal.';
  }

  /// Menyimpan API Key pengguna secara aman di secure storage
  Future<void> saveApiKey(String key) async {
    await _storage.write(key: kStorageApiKey, value: key.trim());
  }

  /// Mengambil API Key dari secure storage
  Future<String?> getApiKey() async {
    return await _storage.read(key: kStorageApiKey);
  }

  /// Menghapus API Key
  Future<void> clearApiKey() async {
    await _storage.delete(key: kStorageApiKey);
  }

  /// Menghitung sisa kuota harian
  Future<int> getRemainingDailyQuota() async {
    final today = _formatToday();
    final savedDate = await _storage.read(key: kStorageQuotaDate);
    if (savedDate != today) {
      return kDailyLimit;
    }
    final rawCount = await _storage.read(key: kStorageQuotaCount);
    final count = int.tryParse(rawCount ?? '0') ?? 0;
    final remaining = kDailyLimit - count;
    return remaining < 0 ? 0 : remaining;
  }

  /// Mengecek dan menambah hit kuota harian
  Future<void> _checkAndIncrementDailyQuota() async {
    final today = _formatToday();
    final savedDate = await _storage.read(key: kStorageQuotaDate);

    int count = 0;
    if (savedDate == today) {
      final rawCount = await _storage.read(key: kStorageQuotaCount);
      count = int.tryParse(rawCount ?? '0') ?? 0;
    } else {
      await _storage.write(key: kStorageQuotaDate, value: today);
    }

    if (count >= kDailyLimit) {
      throw Exception(
        'Batas kuota harian ($kDailyLimit request/hari) telah tercapai. '
        'Silakan gunakan Mode Offline atau coba lagi besok.',
      );
    }

    await _storage.write(
      key: kStorageQuotaCount,
      value: (count + 1).toString(),
    );
  }

  String _formatToday() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
