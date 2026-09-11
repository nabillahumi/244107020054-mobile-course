|  | Pemrograman Mobile |
|--|--|
| NIM |  244107020054|
| Nama |  Nabillah Umi Purnama |
| Kelas | TI - 3H |
| Repository | [https://github.com/nabillahumi/244107020054-mobile-course] () |

# WEEK 3
## Navigation & State Management

Berikut merupakan hasil running:

### Praktikum 1 - Aplikasi multi-page dengan GoRouter

Tampilan awal week_navigation:

![screenshot](Screenshot/tampilan_awal_navigation.jpeg)

Tampilan setelah diubah:

![screenshot](Screenshot/setelah_diubah_navi.jpeg)

Tampilan per item:

![screenshot](Screenshot/isi_peritem.jpeg)

### Praktikum 2 — Aplikasi ToDo dengan Riverpod

Tampilan awak week_todo

![screenshot](Screenshot/tampilan_awal_todo.jpeg)

![screenshot](Screenshot/hasil_todo.jpeg)

![screenshot](Screenshot/hasil_todo2.jpeg)

![screenshot](Screenshot/hasil_todo3.jpeg)

#### AsyncValue: loading, error, success

![screenshot](Screenshot/kode1.jpeg)

![screenshot](Screenshot/kode2.jpeg)

![screenshot](Screenshot/kode3.jpeg)

![screenshot](Screenshot/kode_main.jpeg)

![screenshot](Screenshot/hasil_asyncvalue.jpeg)

### Praktikum 3 — Uji ketiga state

*1. Salin kode di atas ke project ToDo Anda (atau project terpisah) dan jalankan. Amati tampilan loading selama 2 detik pertama.*

![screenshot](Screenshot/Hasil_AsyncValue.jpeg)

Aplikasi menampilkan loading selama 2 detik, kemudian menampilkan data Keyboard, Mouse, dan Monitor.

*2. Ubah build() sementara untuk melempar error: throw Exception('Gagal terhubung ke server');. Jalankan dan amati UI error beserta tombol Coba lagi.*

![screenshot](Screenshot/kode_gagal.jpeg)

![screenshot](Screenshot/gagal_terhubung.jpeg)

Setelah diberi Exception, aplikasi menampilkan pesan “Gagal terhubung ke server” dan tombol “Coba lagi”.

*3. Tekan tombol Coba lagi, ref.invalidate membuat provider dijalankan ulang. Pulihkan kode, pastikan state success tampil.*

![screenshot](Screenshot/kode_read.jpeg)

![screenshot](Screenshot/load.jpeg)

![screenshot](Screenshot/hasil_asyncvalue.jpeg)

ref.invalidate(productsProvider) menjalankan ulang provider. Setelah error diperbaiki, data produk kembali ditampilkan.

*Refleksikan: mengapa menampilkan ulang data lama (stale data) dengan indikator refresh kadang lebih baik daripada mengosongkan layar? Kapan pola itu penting?*

Stale data lebih baik karena data lama tetap terlihat saat data baru sedang dimuat, sehingga UI tidak kosong dan pengalaman pengguna lebih nyaman.

### AI Challenge

#### 1. AI Prompt Challenge

Buatkan halaman Flutter bernama StatsPage menggunakan flutter_riverpod.
Requirements:
- ConsumerWidget dengan satu AsyncNotifierProvider yang mensimulasikan
  pengambilan data statistik (delay 2 detik, kadang gagal 30%).
- UI harus menangani loading (spinner), error (pesan + tombol retry),
  dan success (ListView 3 item).
- Berikan unit test untuk notifier-nya.
Jelaskan setiap bagian kode dalam komentar.

stats_provider.dart

![screenshot](Screenshot/s_provider.jpeg)

stats_page.dart

![screenshot](Screenshot/s_page1.jpeg)

![screenshot](Screenshot/s_page2.jpeg)

stats_provider_test.dart

![screenshot](Screenshot/s_prov_test1.jpeg)

![screenshot](Screenshot/s_proc_test2.jpeg)

main.dart

![screenshot](Screenshot/main.jpeg)

#### 2. AI Verification Checklist

Sebelum kode AI diterima, verifikasi hal berikut dan catat temuan Anda di README:

*1. Apakah state diubah secara immutable (tidak ada state.add() atau mutasi list langsung)?*

Iya, lolos. Karena pada StatsNotifier, state itu berupa hasil string dengan kode :
return [
  'Total Pengguna: 1.240',
  'Pesanan Hari Ini: 86',
  'Pendapatan: Rp12.500.000',
];

dan juga tidak menggunakan state.add(). Jadi state dikelola secara immutable dan tidak mutasi list secara langsung

*2. Apakah ref.watch hanya dipakai di dalam build, dan ref.read di callback?*

Iya, ref.watch hanya digunakan di dalam method build(), sedangkan ref.invalidate dipanggil di dalam callback onPressed.

*3. Apakah ketiga state AsyncValue benar-benar ditangani (bukan hanya success)?*

Iya, loading, error, dan success ditangani menggunakan when()

*4. Apakah provider dideklarasikan dengan tipe eksplisit dan tidak duplikat dengan provider lain?*

Iya, menggunakan AsyncNotifierProvider<StatsNotifier, List<String>> dan tidak duplikat dengan provider lain.

*5. Apakah kode AI memakai API Riverpod versi lama (StateProvider antipattern, StateNotifierProvider usang, atau Consumer bertingkat yang tidak perlu)? Perbaiki ke pola Notifier/ConsumerWidget.*

Tidak, kode menggunakan pola modern AsyncNotifier dan ConsumerWidget.

*6. Jalankan flutter analyze dan flutter test, apakah hasil AI lolos tanpa warning?*

flutter analyze berhasil tanpa masalah, sedangkan flutter test awal menemukan masalah pada widget test dan asynchronous error test sehingga perlu diperbaiki dan diuji ulang.

![screenshot](Screenshot/flutter_analyze.jpeg)

#### 3. Perbaikan

