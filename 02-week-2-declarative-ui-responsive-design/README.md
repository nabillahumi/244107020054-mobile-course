|  | Pemrograman Mobile |
|--|--|
| NIM |  244107020054|
| Nama |  Nabillah Umi Purnama |
| Kelas | TI - 3H |
| Repository | [link] () |

# WEEK 1
## Declarative UI & Responsive Design

berikut merupakan hasil running:

### Halaman 3 (DEMO)

*1. Jalankan aplikasi hasil akhir pada emulator ukuran ponsel (misal 5"), lalu tablet (misal 10"); bandingkan jumlah kolomnya.*

![screenshot](Screenshot/phone.jpeg)

![screenshot](Screenshot/tablet.jpeg)

Pada layar ponsel, tampilan dashboard menggunakan satu kolom, sedangkan pada layar tablet menggunakan dua kolom. Perbedaan tersebut menunjukkan bahwa layout aplikasi dapat menyesuaikan ukuran layar secara responsif.

*2. Aktifkan dark mode pada emulator/perangkat dan amati perubahan tema secara otomatis.*

![screenshot](Screenshot/dark.jpeg)

![screenshot](Screenshot/kode.jpeg)

Ketika dark mode diaktifkan, tampilan aplikasi secara otomatis berubah menjadi tema gelap. Hal ini terjadi karena aplikasi menggunakan darkTheme dan ThemeMode.system, sehingga tema mengikuti pengaturan sistem perangkat.

*3. Perhatikan pola declarative: UI tidak diubah satu per satu, hanya state yang diperbarui dan Flutter membangun ulang tampilan.*

Flutter menggunakan konsep Declarative UI ($UI = f(state)$). Artinya, kita tidak perlu mengedit properti elemen UI satu per satu secara manual saat terjadi perubahan kondisi. Cukup perbarui kondisi/konfigurasinya (seperti tema sistem), maka Flutter akan otomatis membangun ulang (rebuild) seluruh tampilan sesuai kondisi terbaru.

### Halaman 4 (Praktikum: layout sederhana (warm-up))
