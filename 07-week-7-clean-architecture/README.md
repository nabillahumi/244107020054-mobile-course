|  | Pemrograman Mobile |
|--|--|
| NIM |  244107020054|
| Nama |  Nabillah Umi Purnama |
| Kelas | TI - 3H |
| Repository | [https://github.com/nabillahumi/244107020054-mobile-course] () |

# WEEK 7
## Clean Architecture

Berikut merupakan hasil running:

## Praktikum 1: Audit layer project lama

## 1. Audit Layer Project Lama

| File | Layer saat ini | Masalah / Pelanggaran Clean Architecture |
| :--- | :--- | :--- |
| `lib/pages/home_page.dart` (mis. halaman utama/auth) | `presentation` | Memanggil Dio/database secara langsung, serta melakukan formatting tanggal atau parsing JSON di dalam widget. |
| `lib/data/api_client.dart` | `data` | Sudah tepat jika hanya dipakai oleh repository, namun tidak boleh dipanggil langsung dari widget/presentation. |
| `lib/providers/auth_provider.dart` (mis. auth_provider) | `presentation` (state) | Seharusnya hanya memanggil repository/use case, bukan mengeksekusi logika data mentah. |
| `lib/data/auth_repository.dart` | `data` (tercampur) | Interface (kontrak) dan implementasi masih digabung dalam satu kelas yang sama (melanggar prinsip *Interface Segregation* & *Dependency Inversion*)

## Tandai tiga pelanggaran klasik

1. Widget dan akses data: Tidak ditemukan pemanggilan database, jaringan, atau penyimpanan langsung di folder lib/pages dan lib/widgets. Artinya, akses data tidak dilakukan langsung oleh widget.

2. Logika bisnis di build(): Tidak ditemukan proses pengolahan tanggal atau JSON di dalam fungsi build(). Artinya, kode antarmuka lebih terpisah dari logika pengolahan data.

3. Pembuatan objek repository: Tidak ditemukan pembuatan objek repository secara manual di folder lib/pages dan lib/providers. Artinya, pengelolaan objek repository sudah lebih terpisah dari kode antarmuka.

## Gambar struktur target

![screenshot](Screenshot/tampilan_awal.png)

|        Kode Setting_page.dart 1             |          Kode Setting_page.dart 2           |
| :-------------------------------------:     | :-----------------------------------------: |
| ![screenshot](Screenshot/kode_setting1.png) | ![screenshot](Screenshot/kode_setting2.png) |
