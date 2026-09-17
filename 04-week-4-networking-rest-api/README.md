|  | Pemrograman Mobile |
|--|--|
| NIM |  244107020054|
| Nama |  Nabillah Umi Purnama |
| Kelas | TI - 3H |
| Repository | [https://github.com/nabillahumi/244107020054-mobile-course] () |

# WEEK 4
## Networking & REST API

Berikut merupakan hasil running:

### Praktikum 1: Dio dan model data

#### Tampilan awal week_navigation:

![screenshot](Screenshot/tampilan_awal.jpeg)

### Praktikum 2: Provider dan error handling

#### Uji tiga skenario error

*1. Jalankan aplikasi dengan internet normal, amati loading lalu daftar 100 posts.*

|                Daftar                |                 Daftar 100                 |
| :-------------------------------------: | :-----------------------------------------: |
| ![screenshot](Screenshot/tampilan_01.jpeg) | ![screenshot](Screenshot/tampilan_awal.jpeg) |

*2. Matikan internet (mode pesawat), tekan refresh, amati pesan ramah + tombol Coba lagi. Nyalakan kembali internet, tekan Coba lagi.*

![screenshot](Screenshot/tidak_ada_internet.jpeg)

*3. Sementara ubah baseUrl menjadi URL salah, amati pesan error koneksi. Kembalikan setelah uji.*

|                Kode                |                 Hasil                |
| :-------------------------------------: | :-----------------------------------------: |
| ![screenshot](Screenshot/kode_salah.jpeg) | ![screenshot](Screenshot/hasil_salah.jpeg) |

### Praktikum 3: Pagination dasar

|                Kode                |                 Hasil                |
| :-------------------------------------: | :-----------------------------------------: |
| ![screenshot](Screenshot/kode_prak3.jpeg) | ![screenshot](Screenshot/hasil_prak3.jpeg) |

#### AI Challenge

##### AI Prompt Challenge

##### AI Verification Checklist

Sebelum kode AI diterima, verifikasi hal berikut dan catat temuan Anda di README:

*1. [✓] Apakah UI memanggil Dio secara langsung (dilarang) atau lewat repository?*

Jawab : 
Iya, lolos. UI tidak memanggil Dio secara langsung, melainkan menggunakan Riverpod provider (commentListProvider) yang memanggil CommentRepository. Kode di UI hanya memanggil:
final commentsAsync = ref.watch(commentListProvider(1));

*2. [X] Apakah fromJson aman null, atau masih memakai cast langsung yang bisa crash?*

Jawab :
Tidak lolos. Kode Comment.fromJson buatan AI masih menggunakan direct casting seperti json['postId'] as int dan json['name'] as String. Jika server mengembalikan nilai null atau field tidak ditemukan, aplikasi langsung crash dengan error TypeError: null is not a subtype of type int.

*3. [✓] Apakah semua tipe DioExceptionType (timeout, connectionError, badResponse) dipetakan ke pesan pengguna?*

Jawab :
Iya, lolos. Seluruh exception dari Dio dipetakan di fungsi friendlyCommentErrorMessage pada file comment_providers.dart:

switch (error.type) {
  case DioExceptionType.connectionTimeout:
  case DioExceptionType.sendTimeout:
  case DioExceptionType.receiveTimeout:
    return 'Koneksi lambat atau timeout (10s). Periksa internet Anda.';
  case DioExceptionType.connectionError:
    return 'Tidak dapat terhubung ke server. Periksa jaringan Anda.';
  case DioExceptionType.badResponse:
    final code = error.response?.statusCode;
    if (code == 404) return 'Komentar tidak ditemukan (404).';
    if (code == 500) return 'Server internal bermasalah (500).';
    return 'Server bermasalah ($code). Coba lagi nanti.';
  default:
    return 'Terjadi kesalahan jaringan pada komentar.';
}

*4. [✓] Apakah baseUrl/timeout terpusat di satu client, bukan tersebar di tiap method?*

Jawab :
Tidak lolos. Pada file comment_repository.dart, AI menambahkan konfigurasi Options(sendTimeout: Duration(seconds: 10)) secara manual di dalam method fetchComments(). Hal ini melanggar prinsip terpusat karena konfigurasi timeout seharusnya dikelola langsung oleh dioProvider di providers.dart.

*5. [✓] Apakah test AI benar-benar menguji kasus field hilang, atau hanya happy path? Tambahkan minimal 1 edge case sendiri.*

Jaab :
Iya, lolos. File test/comment_model_test.dart telah menguji skenario lengkap:

Happy Path: Deserialisasi JSON lengkap.

Edge Case 1 (Persyaratan Modul): Pengujian JSON saat field penting seperti postId, name, email, dan body hilang/bernilai null.

Edge Case 2 (Tambahan Mandiri): Pengujian JSON saat seluruh field diset bernilai null secara eksplisit.

*6. [✓] Jalankan flutter analyze dan flutter test, apakah hasil AI lolos tanpa warning?*

Jawwab :
Tidak lolos. Untuk flutter analyze berhasil dengan status No issues found!. Namun, flutter test mengalami kegagalan (failed) pada tiga pengujian:

comment_model_test.dart (Edge Case 1 & Edge Case 2) gagal karena melempar exception type 'Null' is not a subtype of type 'int' in type cast pada comment.dart baris 19. Ini membuktikan method Comment.fromJson belum aman terhadap data null.

widget_test.dart gagal karena smoke test counter bawaan Flutter masih mencoba mencari widget teks angka "0", padahal main.dart sudah diganti untuk memuat CommentListPage.

#### Perbaikan
Perbaikan Halusinasi Class Notifier Riverpod
Pada file comment_providers.dart, kelas halusinasi FamilyAsyncNotifier diganti menggunakan FutureProvider.family<List<Comment>, int>. Ini merupakan sintaks resmi Riverpod untuk mengambil data asynchronous berdasarkan parameter tanpa perlu code generator.

2. Perbaikan Deserialisasi Model Null-Safe (lib/data/models/comment.dart)
Penyebab utama error pada unit test adalah penggunaan direct casting as int di baris 19 file comment.dart. Kode diperbaiki menggunakan (json['postId'] as num?)?.toInt() ?? 0 dan (json['id'] as num?)?.toInt() ?? 0 agar ketika field bernilai null atau hilang, sistem secara otomatis memakai nilai pengganti (fallback) 0 tanpa melempar exception.

Pemusatan Konfigurasi Timeout Dio
Menghapus Options(sendTimeout: ...) lokal dari CommentRepository dan menyerahkan pengaturan timeout serta baseUrl sepenuhnya kepada dioProvider terpusat.

