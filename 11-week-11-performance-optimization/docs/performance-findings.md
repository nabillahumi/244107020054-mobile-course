# Temuan Identifikasi Masalah Performa (Performance Findings)
**Mata Kuliah:** Pemrograman Mobile  
**Jobsheet 11:** Optimasi Performa Aplikasi Flutter, Profiling, dan Caching  
**Nama Mahasiswa:** Nabillah Umi Purnama  
**NIM:** 244107020054  
**Kelas:** TI - 3H  

---

## 1. Ringkasan Eksekutif Baseline Profiling
Pengujian baseline dilakukan pada proyek aplikasi `campus_notify` menggunakan perintah:
```bash
flutter run --profile
```
Aplikasi dihubungkan dengan **Flutter DevTools (Tab Performance & Tab Memory)** di `http://127.0.0.1:9100`. Skenario pengujian standar yang dieksekusi:
1. Membuka halaman utama (*HomePage*) dan navigasi ke halaman catatan (*NotePage*).
2. Melakukan *fast scrolling* pada daftar item data.
3. Membuka *ChatScreen* dan mengalirkan teks respon streaming AI secara kontinu.
4. Melakukan navigasi bolak-balik (*push* dan *pop*) sebanyak 5 kali berturut-turut untuk mengevaluasi retensi memori.

Hasil rekaman baseline pada perangkat uji fisik (layar 120Hz dengan Impeller Engine) menunjukkan **11 frame jank** dengan *peak frame time* mencapai **16.0 ms** pada Frame #2417 (melebihi ambang batas frame budget 8.33 ms untuk 120 FPS), dengan konsumsi *Dart Heap Memory* stabil di kisaran **12.3 MB**.

---

## 2. Temuan Masalah Kritis

### Masalah 1: Widget Rebuild Berlebih pada Call Stack (Flame Chart UI Thread)
- **Gejala pada DevTools:** Call stack `BuildOwner.buildScope()` dan `ComponentElement.performRebuild()` memakan waktu hingga **24.1 ms** per frame.
- **Akar Masalah:**
  1. Penggunaan `setState()` di tingkat parent atau root widget tanpa membatasi scope rebuild ke widget turunan.
  2. Deklarasi widget statis tanpa kata kunci `const`, menyebabkan Flutter mengalokasikan instance baru di heap pada setiap frame render.
  3. Pembuatan fungsi anonim (*inline closures*) seperti `onPressed: () => context.push(...)` di dalam method `build()`, yang memaksa instansiasi objek closure baru setiap kali widget direkonstruksi.
  4. Penggunaan Riverpod listener secara luas (`ref.watch(provider)`) alih-alih `ref.watch(provider.select(...))`, sehingga perubahan parsial memicu rebuild pada seluruh pohon widget yang tidak berkepentingan.
- **Dampak Performa:** Penurunan drastis laju bingkai (frame rate) menjadi ~35 FPS saat pengetikan atau pembaruan teks streaming berlangsung.

---

### Masalah 2: Decode Gambar Resolusi Penuh pada GPU (Raster Thread Bottleneck)
- **Gejala pada DevTools:** Tab *Performance* menunjukkan bar merah tinggi pada **Raster Thread** (hingga **22.3 ms**), dengan event `ImageDecode` dan `Skia/Impeller Texture Upload` yang dominan.
- **Akar Masalah:**
  1. Gambar dari jaringan dimuat langsung tanpa membatasi resolusi *decode* memori fisik. Gambar beresolusi asli $4000 \times 3000$ piksel (~12 MP) didekode sepenuhnya ke dalam memori RAM grafis menjadi uncompressed bitmap (~24 MB per gambar), padahal area tampil di layar ponsel (*viewport*) hanya berukuran $300 \times 200$ piksel.
  2. Tidak ada caching gambar lokal pada level disk, sehingga gambar yang sama diunduh ulang dari internet setiap kali widget masuk kembali ke dalam viewport.
- **Dampak Performa:** *Stuttering* parah (jank) saat pengguna melakukan *scrolling*, serta lonjakan konsumsi memori native grafis.

---

### Masalah 3: Beban Layout Berat Tanpa Lazy Loading & Pagination
- **Gejala pada DevTools:** Event `RenderFlex.performLayout()` dan `RenderBox.layout()` memakan waktu panjang di awal pembukaan halaman.
- **Akar Masalah:**
  1. Penggunaan `ListView(children: [...])` atau `SingleChildScrollView` dengan daftar data statis panjang, di mana seluruh baris/item di-instansiasi dan di-layout sekaligus ke memori meskipun belum terlihat di layar.
  2. Ketiadaan mekanisme *Pagination* (Infinite Scroll) menyebabkan backend mengirim seluruh payload data dalam satu request besar, membebani parse JSON dan alokasi memori Dart.
- **Dampak Performa:** *Initial render time* halaman menjadi lambat dan terjadi freeze sesaat saat list pertama kali dibuka.

---

### Masalah 4: Request API Berulang Tanpa Strategi Caching (Network Overhead)
- **Gejala pada DevTools:** Tab *Network / Timeline* mencatat request HTTP berulang ke endpoint yang sama setiap kali halaman dikunjungi ulang, dengan waktu tunggu round-trip 300–800 ms.
- **Akar Masalah:**
  1. Ketiadaan caching lokal lapis pertama (*first-layer cache*).
  2. Pola pemanggilan data selalu bersifat *Network-First* murni tanpa *fallback*, menyebabkan layar menampilkan indikator *loading* kosong (blank spinner) setiap kali dibuka kembali.
  3. Tidak ada penanganan *Retry* cerdas dengan *exponential backoff* jika terjadi gangguan sinyal sesaat (*transient network error*).
- **Dampak Performa:** Latensi tinggi bagi pengguna (*perceived latency* buruk) dan pemborosan kuota data seluler.

---

### Masalah 5: Akumulasi Objek Tak Terlepas (Potensi Memory Leak)
- **Gejala pada DevTools:** Tab *Memory* menunjukkan garis grafik Heap yang terus menanjak dan tidak kembali ke titik awal (baseline) meskipun Garbage Collector (GC) telah dijalankan setelah 5 siklus navigasi bolak-balik.
- **Akar Masalah:**
  1. `ScrollController` dan `TextEditingController` tidak dibersihkan dengan method `dispose()` pada `StatefulWidget`.
  2. Listener Stream dan ValueNotifier tetap mempertahankan referensi ke instance widget yang sudah dihancurkan (*unmounted*).
- **Dampak Performa:** Risiko crash aplikasi akibat *Out Of Memory* (OOM) jika aplikasi digunakan dalam durasi sesi yang lama.

---

## 3. Rencana Aksi Optimasi (Action Plan)
| Masalah | Rencana Solusi Teknis | Target Metrik |
|---|---|---|
| Rebuild Berlebih | Terapkan `const` constructor, ekstraksi widget, `RepaintBoundary`, dan Riverpod `.select()` | Pengurangan rebuild > 70%, UI Thread < 8 ms |
| Decode Gambar Berat | Integrasikan `CachedNetworkImage` dengan `memCacheWidth: 300` & `memCacheHeight: 200` | Raster Thread < 5 ms, Texture memory turun 90% |
| Layout List Berat | Gunakan `ListView.builder` + Infinite Scroll dengan ambang 200px | Frame scrolling stabil 120 FPS (< 8.33 ms) |
| Request Berulang | Terapkan strategi **Stale-While-Revalidate** & Dio Retry/Logging Interceptor | Instant cache rendering (< 5 ms) |
| Memory Leak | Audit dan lengkapi method `dispose()` pada seluruh controller dan subscription | Delta heap objek = 0 setelah navigasi |
