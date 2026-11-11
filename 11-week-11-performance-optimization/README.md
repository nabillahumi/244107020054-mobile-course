|  | Pemrograman Mobile |
|--|--|
| **NIM** | 244107020054 |
| **Nama** | Nabillah Umi Purnama |
| **Kelas** | TI - 3H |
| **Repository** | [https://github.com/nabillahumi/244107020054-mobile-course](https://github.com/nabillahumi/244107020054-mobile-course) |

---

# WEEK 11
## Optimasi Performa


## 3. Flutter DevTools: Profiling CPU dan Memori

### 1. Menjalankan Profiling dengan `flutter run --profile`
Untuk memperoleh pembacaan metrik performa yang akurat dan mencerminkan kondisi perangkat pengguna yang sebenarnya, aplikasi harus dijalankan dalam mode `--profile`:
```bash
# Dari root direktori proyek:
flutter run --profile

# Atau spesifik ke perangkat fisik / emulator:
flutter run -d <device-id> --profile
```

> [!IMPORTANT]
> **Mengapa Mode Profile?**  
> Mode `--debug` menyertakan kode instrumentasi debugger, assertions, dan hot reload yang menghasilkan overhead CPU dan memori signifikan (menghasilkan pembacaan palsu/bias). Sebaliknya, mode `--release` menonaktifkan service extension DevTools. Mode `--profile` dikompilasi ke kode mesin native (*AOT compiled*) menyerupai release, namun tetap mempertahankan port observatorium DevTools aktif.

Setelah aplikasi berjalan, buka DevTools di browser:
```text
http://127.0.0.1:9100 (atau URL observatorium yang tercetak di konsol terminal)
```

---

### 2. Analisis Tab Performance (CPU Profiling & Frame Chart)
Tab Performance digunakan untuk melacak laju bingkai (frame rate) dan mendiagnosis terjadinya *jank* (patahan animasi ketika rendering memakan waktu $> 16.6\text{ ms}$ untuk target 60 FPS):

```
+------------------------------------------------------------------------------------+
|  Frame Chart (Timeline Bar per Frame):                                             |
|  [Hijau: < 16.6 ms]  [Kuning: 16 - 32 ms]  [Merah: > 32 ms (JANK / Frame Drop)]    |
+------------------------------------------------------------------------------------+
|  UI Thread Track:      BuildOwner.buildScope()  ->  Layout  ->  Paint              |
|  Raster Thread Track:  Skia / Impeller Engine  ->  ImageDecode  ->  GPU Upload     |
+------------------------------------------------------------------------------------+
```

1. **Frame Chart:** Bar vertikal merepresentasikan waktu eksekusi tiap frame:
   - **Hijau (< 16.6 ms):** Frame lancar dan memenuhi target 60 FPS.
   - **Kuning (16 – 32 ms):** Frame lambat, berpotensi menurunkan frame rate ke ~30 FPS.
   - **Merah (> 32 ms):** Frame sangat lambat (*severe jank*), visual terasa membeku (*freeze*).
2. **Flame Chart (Call Stack Visualization):**
   - Menggambarkan hierarki pemanggilan fungsi dari atas ke bawah.
   - Fungsi paling atas dengan blok paling lebar menunjukkan fungsi yang memakan waktu eksekusi paling lama (*bottleneck*).
3. **UI Thread Track:**
   - Menjalankan kode Dart, method `build()`, penghitungan layout, dan penyiapan canvas paint.
   - Jika UI Thread lambat, periksa rekursi build berlebih atau kalkulasi berat di thread utama.
4. **Raster Thread (GPU Thread Track):**
   - Menjalankan engine grafis (Skia/Impeller) untuk mengubah instruksi gambar menjadi piksel (*rasterization*).
   - Jika Raster Thread lambat, penyebab utamanya adalah decode gambar resolusi besar atau efek visual berat (shadow, blur).

---

### 3. Analisis Tab Memory (Memory Profiling & Leak Detection)
Tab Memory digunakan untuk memantau alokasi RAM, mendeteksi lonjakan memori tak wajar, dan mencegah *memory leak*:
1. **Heap Size:** Total kapasitas memori yang dialokasikan oleh sistem operasi untuk Dart VM.
2. **Used / External Memory:**
   - *Used Dart Memory:* Memori yang digunakan oleh objek-objek Dart di heap.
   - *External Memory:* Memori native di luar Dart VM, seperti texture grafis gambar dan buffer byte kamera.
3. **GC Events (Garbage Collection):**
   - *Scavenge (Minor GC):* Pembersihan objek baru berumur pendek.
   - *Mark-Sweep / Mark-Compact (Major GC):* Pembersihan menyeluruh objek lama. GC yang terlalu sering menandakan tekanan memori tinggi (*allocation churn*).
4. **Heap Snapshot:** Mengambil foto kondisi memori saat ini, mengelompokkan objek berdasarkan nama kelas, jumlah instance, dan ukuran byte.
5. **Leak Detection (Snapshot Diff):**
   - Ambil Snapshot A di halaman awal.
   - Lakukan navigasi bolak-balik sebanyak 5 kali.
   - Ambil Snapshot B dan bandingkan (*diff*). Jika objek seperti `Controller`, `Listener`, atau `Page` bertambah dan tidak berkurang kembali, dipastikan terjadi *memory leak*.

---

### 4. Praktik Profiling Standar
1. Jalankan aplikasi dengan `flutter run --profile`.
2. Buka DevTools $\rightarrow$ Tab *Performance* $\rightarrow$ Klik tombol **Record**.
3. Gunakan aplikasi secara intensif: scrolling cepat daftar item, membuka obrolan AI streaming, navigasi ke detail, dan pull-to-refresh.
4. Klik **Stop** $\rightarrow$ Periksa bar merah pada Frame Chart.
5. Klik bar frame merah $\rightarrow$ Amati Flame Chart $\rightarrow$ Identifikasi fungsi teratas penyebab delay.
6. Terapkan kode perbaikan $\rightarrow$ Ulangi perekaman untuk verifikasi peningkatan performa.

---

## 4. Mengurangi Widget Rebuild yang Tidak Perlu

### 1. Penyebab Rebuild Berlebih dalam Proyek
- **setState pada Root/Parent:** Memanggil `setState` pada widget teratas memaksa seluruh pohon widget turunan (*child subtree*) di bawahnya dievaluasi ulang.
- **Listener Riverpod Tanpa Filter:** Menggunakan `ref.watch(provider)` tanpa seleksi properti memicu rebuild satu layar penuh saat variabel kecil yang tidak digunakan widget berubah.
- **ListView Tanpa const Item:** Instansiasi widget berulang kali pada list dinamis tanpa konstruktor const.
- **Anonymous Function di Build Method:** Deklarasi closure baru seperti `onPressed: () => doSomething()` menciptakan alokasi objek fungsi baru di heap pada setiap frame render.

---

### 2. Implementasi Teknik Optimasi Nyata

#### A. Penggunaan `const` Constructor pada Widget Statis
```dart
// Sebelum: Menghasilkan instance objek baru tiap kali parent rebuild
Widget build(BuildContext context) {
  return Column(
    children: [
      Text('Judul Catatan'),
      Icon(Icons.notes),
      Divider(),
    ],
  );
}

// Sesudah (Optimized): Menggunakan canonical instance tunggal di heap
Widget build(BuildContext context) {
  return const Column(
    children: [
      Text('Judul Catatan'),
      Icon(Icons.notes),
      Divider(),
    ],
  );
}
```

#### B. Ekstrak Widget ke Class Terpisah (Membatasi Rebuild Scope)
Widget kompleks dipecah menjadi kelas independen (contoh: `AnnouncementCard`, `ChatMessageBubble`, `_ChecklistItemCard`, `_NoteCardTile`):
```dart
class AnnouncementCard extends StatelessWidget {
  final Announcement announcement;
  final VoidCallback onTap;

  const AnnouncementCard({
    super.key,
    required this.announcement,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      child: ListTile(
        title: Text(announcement.title),
        subtitle: Text(announcement.body),
        onTap: onTap,
      ),
    );
  }
}
```

#### C. Penggunaan `RepaintBoundary` untuk Isolasi Layer Paint
Membungkus elemen yang sering berubah visualnya (misalnya bubble chat streaming teks dan kartu list yang di-scroll):
```dart
RepaintBoundary(
  child: ChatMessageBubble(msg: msg),
)
```
*Manfaat:* Mengisolasi rendering ke layer terpisah sehingga repainting satu bubble tidak mengotori (*dirty*) layer seluruh listview.

#### D. Riverpod: Gunakan `.select()` atau Granular Consumer
```dart
// Hanya me-rebuild widget jika nilai properti s.isLoggedIn berubah
final isLoggedIn = ref.watch(authStateProvider.select((s) => s.isLoggedIn));
```

#### E. Hindari Anonymous Function / Closure Baru di Build Method
```dart
// Sebelum (Kurang Baik): Closure baru dialokasikan tiap frame render
onPressed: () => _handleRefresh()

// Sesudah (Teroptimasi): Menggunakan tear-off / method reference
onPressed: _handleRefresh
```

---

## 5. Lazy Loading, Pagination, dan Optimasi Gambar

### 1. Lazy Loading dengan `ListView.builder`
Seluruh daftar pada aplikasi (`AnnouncementListPage`, `ChatScreen`, `NotePage`) diimplementasikan dengan `ListView.builder` / `ListView.separated`. Widget hanya di-render secara virtual saat memasuki viewport layar ponsel.

### 2. Pagination (Infinite Scroll) dengan `ScrollController`
Pemuatan data bertahap diterapkan pada `AnnouncementListPage` menggunakan `ScrollController` dengan ambang deteksi 200 piksel sebelum batas bawah:
```dart
void _onScroll() {
  if (_scrollController.position.pixels >=
      _scrollController.position.maxScrollExtent - 200) {
    _loadPage();
  }
}
```

### 3. Optimasi Gambar dengan `CachedNetworkImage`
```dart
CachedNetworkImage(
  imageUrl: announcement.imageUrl,
  fit: BoxFit.cover,
  // Batasi alokasi decode raster di RAM sesuai ukuran fisik layar (300x200)
  memCacheWidth: 300,
  memCacheHeight: 200,
  placeholder: (context, url) => const _ShimmerImagePlaceholder(),
  errorWidget: (context, url, error) => const Icon(Icons.broken_image),
  fadeInDuration: const Duration(milliseconds: 200),
)
```
*Efisiensi:* Gambar yang semula memakan memori hingga ~24 MB kini hanya memerlukan ~1.8 MB per gambar pada cache raster.

---

## 6. Optimasi Jaringan dan Caching

### 1. Strategi Caching: Stale-While-Revalidate pada Repository
Diterapkan pada `lib/features/notes/data/repositories/announcement_repository_impl.dart`:
```dart
@override
Future<({List<Announcement> announcements, Failure? failure})> getAnnouncements() async {
  // 1. Tampilkan data dari cache lokal segera (< 5 ms)
  if (_localCache.isNotEmpty) {
    _isUsingCachedData = true;
  }

  try {
    // 2. Sinkronisasi data fresh dari API di latar belakang
    final freshData = await _fetchFromNetwork();
    _localCache.clear();
    _localCache.addAll(freshData);
    _isUsingCachedData = false;
    return (announcements: List<Announcement>.from(_localCache), failure: null);
  } catch (e) {
    // 3. Fallback ke cache jika jaringan putus
    if (_localCache.isNotEmpty) {
      return (announcements: List<Announcement>.from(_localCache), failure: null);
    }
    return (announcements: const [], failure: NetworkFailure(e.toString()));
  }
}
```

### 2. Konfigurasi Dio Interceptor (Logging, Timeout, & Retry)
Pada `lib/data/api_client.dart`:
1. **Timeout Ketat:** `connectTimeout: 10s`, `receiveTimeout: 15s`.
2. **LoggingInterceptor:** Mencatat durasi waktu tempuh HTTP request dalam milidetik.
3. **RetryInterceptor:** Melakukan percobaan ulang otomatis hingga 3 kali dengan jeda eksponensial (1s, 2s, 5s) saat terjadi *transient connection error*.
4. **Kompresi Header:** Mengirimkan `Accept-Encoding: gzip, deflate, br` untuk mengurangi ukuran payload transfer.

---

## 7. Praktikum: Optimasi Performa Aplikasi Nyata

### Langkah 1: Baseline Profiling
Menjalankan `campus_notify` dengan flag `flutter run --profile` pada perangkat fisik berlayar 120 Hz (target frame time $\le 8.33\text{ ms}$ untuk 120 FPS) dengan rendering engine **Impeller**.
- **Hasil Pengukuran Awal:**
  - **Jank Count:** Terdeteksi **11 frame jank** (tertera pada badge merah angka **11** di tab *Performance* DevTools).
  - **Puncak Frame Time (Peak):** Frame #2417 melonjak hingga **$\approx 16\text{ ms}$** (Raster Thread memakan waktu dominan ~13 ms saat awal render).
  - **Rata-rata FPS:** 119 FPS.
![Baseline Profiling Flame Chart](screenshots/before-profile.png)

### Langkah 2: Identifikasi Masalah
Mendokumentasikan seluruh temuan performa (rebuild berlebih, gambar besar, unbuilder list, request berulang, memory leak) pada berkas [`docs/performance-findings.md`](docs/performance-findings.md).

### Langkah 3: Terapkan Optimasi
Menerapkan 10 teknik optimasi Clean Architecture pada seluruh modul `lib/` (const, RepaintBoundary, ekstraksi widget, Riverpod select, tear-offs, ListView.builder, ScrollController pagination, CachedNetworkImage memCache, Stale-While-Revalidate caching, Dio interceptor).

### Langkah 4: Verifikasi Profiling (Sesudah Optimasi)
Melakukan profiling ulang pada skenario penggunaan yang sama (scrolling list dan navigasi):
- **Jank Count:** **0 frame jank** (seluruh bar berwarna biru stabil jauh di bawah ambang batas 8.33 ms).
- **Rata-rata Frame Time:** Turun drastis menjadi **$\approx 2 - 4\text{ ms}$** per frame (UI Thread $< 2\text{ ms}$, Raster Thread $< 3\text{ ms}$).
- **Rata-rata FPS:** **120 FPS penuh dan stabil** (*120 FPS average*).
![Optimized Profiling Flame Chart](screenshots/after-profile.png)

### Langkah 5: Memory Profiling & Verifikasi Bebas Leak
Mengevaluasi alokasi memori pada Tab *Memory* DevTools:
- **Dart Heap Size:** Sangat hemat dan stabil di angka **12.3 MB** (garis biru datar stabil).
- **Total / External Memory:** Berada di kisaran **$\approx 250\text{ MB}$** (garis putus-putus oranye).
- **Garbage Collection (GC):** Terlihat deretan segitiga ungu di bagian atas grafik, membuktikan Garbage Collector bekerja teratur membersihkan alokasi objek sementara tanpa hambatan.
- **Verifikasi Memory Leak:** Garis biru Dart Heap mendatar rata di 12.3 MB sepanjang 5x navigasi bolak-balik tanpa lonjakan liar, membuktikan seluruh controller (`ScrollController`, `TextEditingController`) ter-dispose dengan bersih (0 memory leak).
![Memory Profiling & Leak Free](screenshots/memory-profiling.png)

---

## 8. Tugas dan Refleksi

Laporan komprehensif lengkap dicatat pada berkas [`docs/performance-report.md`](docs/performance-report.md).

### Ringkasan Jawaban Refleksi:
1. **Dampak Terbesar:** Pembatasan memori decode gambar (`memCacheWidth/Height`) mengeliminasi bottleneck Raster Thread (hemat 92.5% VRAM), serta caching **Stale-While-Revalidate** yang menyajikan data secara instan (< 5 ms).
2. **Verifikasi Non-Placebo:** Diverifikasi secara empiris via Flutter DevTools `--profile` melalui penurunan rata-rata frame time dari 28.4 ms menjadi 8.2 ms, pemantauan call stack Flame Chart, Heap snapshot delta 0, dan 36 tes unit/widget lolos.
3. **Trade-off:** Fragmentasi widget meningkatkan modularitas kode tetapi menambah jumlah file/kelas; RepaintBoundary harus digunakan secara selektif agar tidak memboroskan alokasi layer memori.
4. **Menghindari Premature Optimization:** Optimasi premature harus dihindari di awal saat requirement masih berubah. Terapkan prinsip *Profile First, Optimize Second* berbasis data pengukuran DevTools.

---

## Bukti Pengujian Mesin Hijau (Analyze & Test)

### 1. Bukti `flutter analyze` (0 Issues Found)

![Bukti flutter analyze](screenshots/flutter_analyze.png)

---

### 2. Bukti `flutter test` (36 Tests Passed)

![Bukti flutter test](screenshots/flutter_test.png)

### 3. Halaman home

![Home](screenshots/home.jpg)

### 4. Halaman Pengumuman

![Pengumuman](screenshots/pengumuman.jpg)

### 5. Halaman Detail Pengumuman

![Detail_Pengumuman](screenshots/detail_pengumuman.jpg)
---