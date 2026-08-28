|  | Pemrograman Mobile |
|--|--|
| NIM |  244107020054|
| Nama |  Nabillah Umi Purnama |
| Kelas | TI - 3H |
| Repository | [link] () |

# WEEK 1
## Mobile Development Ecosystem & Flutter Refresh

berikut merupakan hasil running:

Tampilan awal:

![screenshot](/screenshot/tampilan-awal.jpeg)

Tampilan setelah diubah:

![screenshot](/screenshot/belum-diubah.jpeg)


*Tujuan*

Memahami kembali dasar pengembangan aplikasi menggunakan Flutter, mulai dari menjalankan project hingga menggunakan widget dasar untuk membuat tampilan aplikasi.

*Fitur Utama*

- Menampilkan halaman *Profil Mahasiswa*.
- Menampilkan ikon pendidikan.
- Menampilkan nama mahasiswa.
- Menampilkan informasi mata kuliah.
- Menggunakan widget dasar seperti `Scaffold`, `AppBar`, `Column`, `Icon`, dan `Text`.

*Stack Teknologi*

- Flutter
- Dart
- Android Studio
- Android Emulator
- Git dan GitHub


*Mini Assignment*

Pada mini assignment, saya menambahkan informasi NIM dan nama kampus pada aplikasi Profil Mahasiswa.

- NIM: **244107020054**
- Kampus: **Politeknik Negeri Malang**

Berikut hasil akhir dari mini assignment:

![screenshot](/screenshot/mini-assigment.jpeg)


*Hasil yang Dicapai*

Aplikasi berhasil dijalankan dan diubah dari tampilan bawaan Flutter menjadi aplikasi Profil Mahasiswa. Aplikasi dapat menampilkan nama, NIM, mata kuliah, dan nama kampus.

*Kendala Setup*

Kendala yang saya temui adalah memastikan perangkat atau emulator terdeteksi oleh Flutter. Untuk mengecek perangkat yang tersedia dapat menggunakan perintah:

```bash
flutter devices
```

Setelah perangkat terdeteksi, aplikasi dapat dijalankan menggunakan:

```bash
flutter run
```

*Refleksi*

### 1. Kapan native lebih tepat dipilih daripada cross-platform?

Native lebih tepat digunakan jika aplikasi membutuhkan performa tinggi atau akses khusus ke fitur perangkat. Cross-platform seperti Flutter lebih cocok jika ingin membuat aplikasi untuk beberapa platform dengan satu kode.

### 2. Bagaimana perubahan state berhubungan dengan widget tree dan UI deklaratif?

Ketika state berubah, Flutter akan memperbarui widget yang berkaitan sehingga tampilan UI juga berubah sesuai dengan state terbaru.

### 3. Mengapa commit kecil dengan pesan jelas bermanfaat?

Commit kecil memudahkan melihat setiap perubahan, mencari kesalahan, dan memahami perkembangan project. Pesan commit yang jelas juga membuat repository lebih rapi dan mudah dipahami.