|  | Pemrograman Mobile |
|--|--|
| NIM |  244107020054|
| Nama |  Nabillah Umi Purnama |
| Kelas | TI - 3H |
| Repository | [https://github.com/nabillahumi/244107020054-mobile-course] () |

# WEEK 6
## Authentication, Security & FCM

Berikut merupakan hasil running:

## Praktikum 1: Login + secure storage + token refresh

### Tampilan awal week_navigation:

![screenshot](Screenshot/tampilan_awal.png)

|                 Halaman login               |            Password Salah             |
| :-------------------------------------:     | :-----------------------------------: |
| ![screenshot](Screenshot/halaman_login.jpeg) | ![screenshot](Screenshot/login_salah.jpeg) |

|          Halaman Utama              |            Halaman Pengumuman             |
| :--------------------------------:  | :---------------------------------------: |
| ![screenshot](Screenshot/home.jpeg) | ![screenshot](Screenshot/pengumuman.jpeg) |

### Tambahan kode:

### Kode push_service.dart :

![screenshot](Screenshot/push_service.png)

### Kode announcement_page.dart :

![screenshot](Screenshot/announ.png)

### Kode home_page.dart :

![screenshot](Screenshot/home_page.png)

### Kode login_page.dart :

|               kode login 1               |                Kode login 2                |
| :-------------------------------------:  | :-----------------------------------------: |
| ![screenshot](Screenshot/login_page.png) | ![screenshot](Screenshot/login_page2.png) |

## Praktikum 2: FCM, permission, dan token lifecycle

### Daftarkan aplikasi ke Firebase

1. Buat project di Firebase Console, tambahkan aplikasi Android dengan package name sesuai applicationId Anda.

![screenshot](Screenshot/fire.png)

2. Unduh google-services.json ke android/app/ dan ikuti panduan FCM Flutter client (terapkan plugin google-services dan dependensi). Untuk iOS tambahkan GoogleService-Info.plist.

![screenshot](Screenshot/masukkan_google.png)

![screenshot](Screenshot/google.png)

### Kode Google Service 

|     kode android/app/build.gradle.kts      |       kode android/build.gradle.kts         |
| :---------------------------------------:  | :-----------------------------------------: |
| ![screenshot](Screenshot/kode_google1.png) | ![screenshot](Screenshot/kode_google2.png) |

![screenshot](Screenshot/berhasil.png)

3. Pastikan firebase_core diinisialisasi sebelum runApp: await Firebase.initializeApp().

![screenshot](Screenshot/izin.png)

## Hasil Praktikum 2

![screenshot](Screenshot/prak2.png)

### Uji kirim pertama dari Firebase Console

Halaman Debug di HP kamu yang menampilkan token terpotong yang baru.

|           Hasil token awal          |          Hasil token baru            |
| :--------------------------------:  | :----------------------------------: |
| ![screenshot](Screenshot/prak2.png) | ![screenshot](Screenshot/prak22.png) |

1. Buka Firebase Console -> Messaging -> buat campaign notifikasi percobaan.

![screenshot](Screenshot/uji1.png)

2. Masukkan title dan body, targetkan aplikasi Android Anda.

![screenshot](Screenshot/uji2.png)

3. Kirim saat aplikasi dalam state background: banner sistem harus muncul. Klik banner: aplikasi terbuka.

![screenshot](Screenshot/hasil_uji.png)

setelah mengklik notifikasi tersebut langsung aplikasi terbuka

## Praktikum 3: Payload, tiga app state, klik dan topik

| State | Yang Diharapkan | Cara Uji | Status / Hasil |
| :--- | :--- | :--- | :---: |
| **Foreground** | Banner lokal muncul, klik masuk ke `/pengumuman/3` | Aplikasi terbuka di layar, kirim dari Firebase Console | Berhasil (Sesuai) |

Pengujian dilakukan saat aplikasi sedang terbuka (foreground). Notifikasi ditampilkan melalui local notification, kemudian ketika notifikasi diklik aplikasi mengarahkan pengguna ke halaman Pengumuman #3 melalui route /pengumuman/3.

|             Notifikasi              |    Tampilan Halaman Pengumuman 3     |
| :--------------------------------:  | :----------------------------------: |
| ![screenshot](Screenshot/uji11.png) | ![screenshot](Screenshot/uji12.png) |

| State | Yang Diharapkan | Cara Uji | Status / Hasil |
| :--- | :--- | :--- | :---: |
| **Background** | Banner sistem muncul, klik masuk ke rute yang benar | Tekan tombol Home, kirim dari Console, klik banner | Berhasil (Sesuai) |

Pengujian dilakukan saat aplikasi berada di background dengan menekan tombol Home tanpa menutup aplikasi. Notifikasi muncul pada sistem Android, kemudian ketika notifikasi diklik aplikasi terbuka dan mengarahkan pengguna ke halaman Pengumuman #7 melalui route /pengumuman/7.

|             Notifikasi              |    Tampilan Halaman Pengumuman 7     |
| :--------------------------------:  | :----------------------------------: |
| ![screenshot](Screenshot/uji21.png) | ![screenshot](Screenshot/uji22.png) |

| State | Yang Diharapkan | Cara Uji | Status / Hasil |
| :--- | :--- | :--- | :---: |
| **Terminated** | Aplikasi terbuka ke rute yang benar via `getInitialMessage` | Swipe-close aplikasi (kill app), kirim dari Console, klik banner | Berhasil (Sesuai) |

Pengujian dilakukan saat aplikasi sudah ditutup sepenuhnya. Setelah notifikasi dikirim dan diklik, aplikasi terbuka kembali dan menggunakan getInitialMessage() untuk mengambil data notifikasi, kemudian mengarahkan pengguna ke halaman Pengumuman #12 melalui route /pengumuman/12.

|             Notifikasi              |    Tampilan Halaman Pengumuman 12     |
| :--------------------------------:  | :----------------------------------: |
| ![screenshot](Screenshot/uji31.png) | ![screenshot](Screenshot/uji32.png) |

### Topic messaging

Aplikasi subscribe ke topic pengumuman-kampus untuk menerima notifikasi broadcast. Pengujian melalui Firebase Console berhasil mengirim notifikasi ke perangkat dan mengarahkan ke halaman pengumuman.

Hasil: Berhasil. Perangkat dapat menerima notifikasi yang dikirim melalui topic pengumuman-kampus.

|             Notifikasi              |             Target Topic             |    Tampilan Halaman Pengumuman 20   |
| :--------------------------------:  | :----------------------------------: |:----------------------------------: |
| ![screenshot](Screenshot/uji41.png) | ![screenshot](Screenshot/uji43.png) | ![screenshot](Screenshot/uji42.png) |

## AI Challenge

### AI Prompt Challenge

Hasil AI Challenge: Implementasi notifikasi berhasil dipertahankan dengan penambahan fungsi unsubscribe topic, penanganan permission Android 13+/iOS, serta dokumentasi bagian yang tidak menggunakan BuildContext. Fitur foreground, background, terminated, dan topic messaging tetap berjalan seperti sebelumnya.

### AI Verification Cheklist

Sebelum draf AI diterima, verifikasi dan catat temuan di README/docs:

1. [✓] Apakah background handler berupa fungsi top-level dengan @pragma('vm:entry-point')? (tolak jika berupa method kelas).

firebaseMessagingBackgroundHandler() berada di luar class dan menggunakan @pragma('vm:entry-point'), sehingga dapat dijalankan oleh Firebase pada isolate background.

2. [-] Apakah onTokenRefresh benar-benar mengirim token baru ke backend, bukan hanya dicetak ke log?

Kode saat ini sudah memiliki onTokenRefresh dan memperbarui token di aplikasi, tetapi belum mengirim token baru ke backend karena project kamu belum memiliki endpoint backend /devices. 

3. [✓] Apakah foreground memakai local notification manual? (tanpa ini banner tidak muncul saat aplikasi terbuka).

Saat aplikasi terbuka, FirebaseMessaging.onMessage menerima pesan lalu _local.show() digunakan untuk menampilkan notifikasi secara manual.

4. [✓] Apakah klik dari ketiga state (foreground/background/terminated) masuk ke rute yang benar? Buktikan dengan tabel pengujian.

Foreground menggunakan callback local notification, background menggunakan onMessageOpenedApp, dan terminated menggunakan getInitialMessage(). Ketiganya sudah diuji dan berhasil mengarah ke halaman pengumuman.

5. [✓] Apakah token/secret tidak di-hardcode dan tidak di-log penuh? Perbaiki bila AI melanggarnya.

Token tidak ditulis secara hardcode. Saat ditampilkan di log, token hanya menggunakan 12 karakter pertama lalu dipotong dengan ..., sehingga token lengkap tidak terekspos.

6. [✓] Keputusan final dan alasan teknis Anda, boleh berbeda dari saran AI selama berargumen.

Kode AI tidak digunakan seluruhnya. Beberapa bagian dipertahankan karena sudah sesuai, sedangkan bagian yang tidak sesuai kebutuhan project diperbaiki secara manual tanpa mengubah fitur yang sudah berhasil.