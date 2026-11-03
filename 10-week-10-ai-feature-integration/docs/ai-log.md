# AI Log & Dokumentasi Integrasi Fitur AI (Jobsheet 10)

Dokumen ini mencatat seluruh jejak implementasi fitur AI (*AI Feature Integration*), rekayasa prompt sistem & pengguna (*system prompt & user prompt engineering*), output awal AI, analisis bug dan risiko keamanan/privasi, siklus refactoring (*test-driven development*), hingga tabel mitigasi risiko pada project `campus_notify` (Week 10).

---

## 1. Formula 5 Slot Prompt

Dalam pengerjaan modul Jobsheet 10 (AI Feature Integration: Chat Interface, OCR, Privasi, dan Fallback Offline), rekayasa prompt disusun secara ketat menggunakan formula 5 slot:

| Slot | Komponen | Isi Spesifik pada Jobsheet 10 |
|---|---|---|
| **1. Peran** | *Role Persona* | Senior Mobile AI Engineer & Flutter Architect |
| **2. Konteks** | *Architecture & Tech Stack* | Flutter 3.x, Dart 3.x, Flutter Riverpod 3.x (Notifier architecture), `http: ^1.2.0`, `flutter_secure_storage: ^11.2.0`, Google Gemini 1.5 Flash API, `image_picker: ^1.1.2` |
| **3. Tugas** | *Feature Goals* | 1. Implementasikan `AiService` untuk pemanggilan Gemini API secara aman.<br>2. Terapkan sanitasi data sensitif pengguna (NIK 16 digit, nomor telepon Indonesia, email) sebelum prompt dikirim ke API luar.<br>3. Bangun `ChatScreen` dengan respons streaming, indikator loading, dan penanganan error/fallback.<br>4. Tambahkan fitur OCR/Image Understanding untuk ekstraksi teks dokumen/KTM.<br>5. Bangun mekanisme fallback cerdas ke basis data lokal kampus saat offline/server sibuk. |
| **4. Batasan** | *Technical Constraints* | - Jangan pernah mengirim data pribadi mentah (NIK/No. HP) ke endpoint AI publik.<br>- Simpan API Key hanya di `FlutterSecureStorage`, jangan hardcode di source code.<br>- Wajib mendukung Riverpod 3.x (gunakan `NotifierProvider`, hindari `StateNotifierProvider` atau `StateProvider` lama).<br>- Terapkan batas kuota harian (50 request/hari) dan cache lokal untuk mengendalikan biaya API.<br>- Fungsi modular, bebas warning static analysis (`dart analyze` 0 issues), dan lolos pengujian test (`flutter test`). |
| **5. Output** | *Deliverables* | File `lib/ai/ai_service.dart`, `lib/ai/ai_provider.dart`, `lib/features/chat_screen.dart`, routing di `lib/routes.dart` & `lib/main.dart`, suite pengujian unit dan widget (`test/ai_service_test.dart` & `test/chat_screen_widget_test.dart`), log AI, dan dokumentasi `README.md`. |

---

## 2. Prompt Rekayasa (System Prompt & User Prompt)

### A. System Prompt (Aturan Dasar AI Assistant Kampus)
```text
Kamu adalah Campus Notify AI Assistant, asisten virtual resmi untuk mahasiswa Politeknik Negeri Malang (Polinema).
Tugas utamamu adalah membantu mahasiswa terkait informasi akademik, jadwal kuliah, Kartu Rencana Studi (KRS),
Kartu Tanda Mahasiswa (KTM), fasilitas perpustakaan, beasiswa, dan pengumuman kampus.

Prinsip Operasional:
1. Privasi Pertama: Jangan pernah meminta atau memproses data pribadi sensitif seperti NIK, nomor rekening, atau password.
2. Akurasi & Ringkas: Berikan jawaban yang ramah, ringkas, terstruktur (bullet points), dan solutif.
3. Fallback Sadar Diri: Jika ada informasi teknis internal kampus yang tidak kamu ketahui secara pasti, arahkan mahasiswa ke Bagian Administrasi Akademik (Gedung Pelayanan Terpadu) atau web resmi SIAKAD.
```

### B. User Prompt Rekayasa Fitur Layanan AI (`AiService`)
```text
Peran: Senior Mobile AI Engineer
Konteks: Project Flutter 3.x Riverpod 3.x dengan flutter_secure_storage dan http client.
Tugas: Buat class AiService di lib/ai/ai_service.dart dengan fungsi ask(), askStream(), recognizeText() (OCR KTM), speechToText(), sanitizePrompt(), dan getOfflineFallback().
Batasan:
- Ambil API key dari FlutterSecureStorage (key: 'ai_api_key').
- Sensor otomatis NIK (16 digit) dan No HP sebelum mengirim HTTP request ke Gemini API.
- Terapkan in-memory caching untuk query yang sama guna menghemat token/biaya.
- Sediakan fallback data kampus lokal jika koneksi offline atau HTTP response bukan 200/429.
Output: Kode Dart lengkap dan modular yang siap diuji dengan unit test (bisa disuntik FakeSecureStorage dan MockClient).
```

---

## 3. Output Awal AI & Analisis Kritis (Temuan Bug/Halusinasi)

Berikut adalah contoh potongan kode output awal yang pertama kali digenerate oleh AI sebelum dilakukan audit ketat:

```dart
// [Output Awal AI - SEBELUM AUDIT & REFACTORING]
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// BUG 1: Menggunakan StateNotifier lama yang deprecated di Riverpod 3.x
final chatMessagesProvider = StateNotifierProvider<ChatNotifier, List<String>>((ref) {
  return ChatNotifier();
});

class AiService {
  final _storage = const FlutterSecureStorage();
  
  // BUG 2: Model URL usang (gemini-pro lama tanpa configurasi batas token)
  final _apiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';

  Future<String> ask(String question) async {
    final apiKey = await _storage.read(key: 'ai_api_key');
    
    // BUG 3: Privasi Bocor - Pertanyaan mentah langsung dikirim tanpa sanitasi NIK / No Telepon
    final response = await http.post(
      Uri.parse('$_apiUrl?key=$apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [{'parts': [{'text': question}]}]
      }),
    );

    // BUG 4: Tidak ada penanganan rate-limit 429 dan tidak ada caching lokal (biaya boros)
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['candidates'][0]['content']['parts'][0]['text'];
    } else {
      throw Exception('Gagal memanggil AI API: ${response.statusCode}');
    }
  }
}
```

### Analisis Kritis atas Output Awal:
1. **Pelanggaran Privasi Pengguna (High Risk):**
   Model AI awal tidak melakukan inspeksi maupun penyaringan terhadap input teks pengguna. Jika pengguna tidak sengaja menempelkan NIK, alamat rumah, atau nomor HP, data mentah tersebut langsung terkirim ke server cloud pihak ketiga.
2. **Ketiadaan Pengendali Biaya (Cost Inefficiency):**
   Setiap kali pengguna menanyakan pertanyaan yang persis sama, request HTTP baru selalu dikirim ke Gemini. Tanpa mekanisme *caching* dan pembatasan kuota per hari, kuota API gratisan akan cepat habis dan tagihan dapat melonjak jika beralih ke *pay-as-you-go*.
3. **Ketidaksesuaian Arsitektur Riverpod 3.x:**
   AI menggunakan `StateNotifierProvider` dan `StateProvider` yang sudah usang dan menghasilkan *compilation error* pada Flutter Riverpod versi 3.4.3.
4. **Kerapuhan Saat Jaringan Mati (*No Offline Resilience*):**
   Jika pengguna offline atau server API 503/429, aplikasi melempar *unhandled exception* mentah tanpa menyediakan jawaban alternatif dari basis data lokal kampus.

---

## 4. Siklus Refactoring Berbasis Pengujian (Test-Driven Refactoring)

Untuk memperbaiki kelemahan-kelemahan di atas, dilakukan siklus TDD dengan langkah perbaikan terukur:

### Langkah 1: Modul Sanitasi Privasi (`sanitizePrompt`)
Dibuat pengujian unit di `test/ai_service_test.dart` untuk memastikan:
- NIK 16-digit diubah menjadi `[REDACTED_NIK]`
- Nomor HP diawali `+62`, `62`, atau `08` diubah menjadi `[REDACTED_PHONE]`
- Email disensor menjadi `[REDACTED_EMAIL]`

```dart
test('Sanitasi NIK 16-digit menjadi [REDACTED_NIK]', () {
  const input = 'Verifikasi NIK 3507123456780001 sekarang.';
  final sanitized = aiService.sanitizePrompt(input);
  expect(sanitized, contains('[REDACTED_NIK]'));
  expect(sanitized.contains('3507123456780001'), isFalse);
});
```

### Langkah 2: In-Memory Caching & Quota Tracking
- Menambahkan koleksi `Map<String, String> _cache = {}` di dalam `AiService`.
- Pengujian memverifikasi bahwa ketika pertanyaan yang sama dipanggil berturut-turut, pemanggilan HTTP Client hanya terjadi 1 kali (`requestCount == 1`).

### Langkah 3: Migrasi ke Riverpod 3.x Notifier
- Kelas `ChatMessagesNotifier` meng-extend `Notifier<List<ChatMessage>>`.
- Digunakan `NotifierProvider<ChatMessagesNotifier, List<ChatMessage>>(ChatMessagesNotifier.new)`.
- Semua *state mutation* dilakukan lewat metode eksplisit (`addMessage()`, `updateLastMessage()`, `set()`).

### Langkah 4: Fallback Offline Cerdas (`getOfflineFallback`)
- Jika internet mati atau kuota habis, fungsi mendeteksi kata kunci kampus (`ktm`, `jadwal`, `krs`, `perpus`, `beasiswa`) dan mengembalikan jawaban instan lokal tanpa crash.

---

## 5. Tabel Keputusan Review Usulan AI

## 5. Tabel Keputusan Review Usulan AI

| No | Komponen AI | Usulan Kode AI | Keputusan Review | Alasan Teknis & Bukti |
|:---:|---|---|---|---|
| 1 | **Sanitasi Privasi Otomatis** | Kirim teks apa adanya tanpa regex filtering. | **DITOLAK & DIUBAH** | Mengirim NIK/HP melanggar kepatuhan privasi (UU PDP & Codelab Security). Diterapkan regex replacement 16 digit NIK dan format nomor ponsel Indonesia. |
| 2 | **Manajemen State** | Menggunakan `StateProvider<bool>` dan `StateNotifier`. | **DITOLAK & DIUBAH** | Menghasilkan error kompilasi pada Riverpod 3.4.3. Diubah menggunakan `Notifier<T>` dan `NotifierProvider`. |
| 3 | **Model Endpoint** | Menggunakan `gemini-pro` legacy. | **DIPERBARUI** | Diperbarui ke model Google Gemini 1.5 Flash (`gemini-1.5-flash:generateContent`) yang memiliki latensi lebih cepat, token window besar, dan efisiensi biaya optimal. |
| 4 | **Dukungan Streaming UI** | Hanya return Future String statis. | **DITERIMA + DILENGKAPI** | Ditambahkan method `askStream()` yang mengalirkan potongan kata secara halus serta `isAiLoadingProvider` sebagai indikator aktivitas. |
| 5 | **Fitur OCR Gambar** | Menggunakan Google ML Kit terpisah. | **DISESUAIKAN (HYBRID)** | Menggunakan Gemini Multimodal Vision API (`image_picker` → base64 inlineData) dengan fallback parsing lokal jika offline atau tanpa API key. |

---

## 6. Verifikasi Mesin Hijau

Seluruh siklus pengujian diverifikasi secara otomatis pada lingkungan kerja:
- **`dart analyze lib test`**: 0 issues found (Clean static analysis).
- **`flutter test`**: 30 pengujian passed (termasuk 8 unit test AI service, 2 widget test ChatScreen, dan 20 test bawaan Campus Notify).
