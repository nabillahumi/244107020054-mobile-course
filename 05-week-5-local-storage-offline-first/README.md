|  | Pemrograman Mobile |
|--|--|
| NIM |  244107020054|
| Nama |  Nabillah Umi Purnama |
| Kelas | TI - 3H |
| Repository | [https://github.com/nabillahumi/244107020054-mobile-course] () |

# WEEK 4
## Local Storage & Offline First

Berikut merupakan hasil running:

### Praktikum 1: SharedPreferences

#### Tampilan awal week_navigation:

![screenshot](Screenshot/tampilan_awal.png)

|        Kode Setting_page.dart 1             |          Kode Setting_page.dart 2           |
| :-------------------------------------:     | :-----------------------------------------: |
| ![screenshot](Screenshot/kode_setting1.png) | ![screenshot](Screenshot/kode_setting2.png) |

#### Kode main.dart:

![screenshot](Screenshot/kode_main1.png)

|           Tampilan mode terang            |            Tampilan mode gelap             |
| :-------------------------------------:   | :-----------------------------------------: |
| ![screenshot](Screenshot/mode_terang.png) | ![screenshot](Screenshot/mode_gelap.png) |

### Praktikum 2: SQLite dan repository catatan

##### Kode mode offline

|         Kode note_page.dart 1             |         Kode note_page.dart 2            |
| :-------------------------------------:   | :-----------------------------------------: |
| ![screenshot](Screenshot/kode_not1.png) | ![screenshot](Screenshot/kode_not2.png) |

|         Kode note_page.dart 3             |         Kode note_page.dart 4            |
| :-------------------------------------:   | :-----------------------------------------: |
| ![screenshot](Screenshot/kode_not3.png) | ![screenshot](Screenshot/kode_not4.png) |

#### Kode main.dart:

![screenshot](Screenshot/kode_main2.png)

|            Tampilan Halaman            |             Tampilan Tambah Pesan             |              Tampilan Hasil Pesan         |   
| :-------------------------------------:   | :-----------------------------------------: | :-----------------------------------------: |
| ![screenshot](Screenshot/halaman.png) | ![screenshot](Screenshot/tambah_pesan1.png) |  ![screenshot](Screenshot/hasil_pesan.png) |

#### Mode Offline
 
|     Tambah pesan dalam mode pesawat       |               Badge angka 2                 |
| :-------------------------------------:   | :-----------------------------------------: |
| ![screenshot](Screenshot/tambah_pesan2.png) | ![screenshot](Screenshot/dua_pesan.png) |

Catatan tetap tersimpan dan tidak hilang walau HP dalam mode pesawat.

Badge angka muncul sebagai penanda bahwa ada catatan yang belum tersinkron ke server.

### Praktikum 3 : Cache-first dan antrean sync

#### 1. Cache-first read untuk data API

#### Kode post_repository.dart

|       Kode post_repository.dart 1         |        Kode post_repository.dart 1        |
| :-------------------------------------:   | :-----------------------------------------: |
| ![screenshot](Screenshot/kode_post1.png) | ![screenshot](Screenshot/kode_post2.png) |

#### 2. Sinkronisasi catatan kotor (dirty)

#### Kode note_repository.dart

![screenshot](Screenshot/kode_notrepo.png)

Menghubungkan ke Tombol UI:

#### Kode note_page.dart

![screenshot](Screenshot/kode_note.png)

#### 3. Simulasi offline yang deterministik

Selain mode pesawat sungguhan, sediakan toggle forceOffline pada provider agar demo dan testing tidak bergantung pada kondisi Wi-Fi kelas:

1. Matikan Wi-Fi / aktifkan mode pesawat, buka kembali aplikasi: catatan tetap tampil, badge dirty tetap akurat.

![screenshot](Screenshot/isi_pesan.png)

Aplikasi dijalankan dalam Mode Pesawat. Catatan tersimpan secara lokal di perangkat dengan status dirty (belum tersinkron). Hal ini dibuktikan dengan munculnya badge merah bernilai 2 pada ikon header kanan atas serta ikon awan offline di samping setiap catatan.

2. Nyalakan kembali koneksi, jalankan syncNotes: badge kembali ke 0.

![screenshot](Screenshot/berhasil.png)

Saat tombol Sync ditekan, fungsi syncNotes berhasil dijalankan yang ditandai dengan munculnya pemberitahuan SnackBar "Berhasil menyinkronkan 2 catatan!" dan hilangnya ikon awan offline pada daftar catatan

3. Tuliskan langkah dan hasil observasi Anda (screenshot sebelum/sesudah) ke folder screenshots/.

![screenshot](Screenshot/hilang_merah.png)

Badge angka merah pada header hilang total

#### AI Challenge

##### Peran AI pada codelab ini

##### AI Prompt Challenge



*1. Jalankan aplikasi dengan internet normal, amati loading lalu daftar 100 posts.*

|                Daftar                |                 Daftar 100                 |
| :-------------------------------------: | :-----------------------------------------: |
| ![screenshot](Screenshot/tampilan_01.jpeg) | ![screenshot](Screenshot/tampilan_awal.jpeg) |