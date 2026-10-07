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

#### Halaman Debug di HP kamu yang menampilkan token terpotong yang baru.

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

|         Notifikasi Pengumuman         |          Notifikasi Pengumuman        |     Tampilan Halaman Pengumuman      |
| :----------------------------------:  | :-----------------------------------: | :----------------------------------: |
| ![screenshot](Screenshot/notif11.png) | ![screenshot](Screenshot/notif22.png) |  ![screenshot](Screenshot/uji12.png) |

| State | Yang Diharapkan | Cara Uji | Status / Hasil |
| :--- | :--- | :--- | :---: |
| **Background** | Banner sistem muncul, klik masuk ke rute yang benar | Tekan tombol Home, kirim dari Console, klik banner | Berhasil (Sesuai) |

Pengujian dilakukan saat aplikasi berada di background dengan menekan tombol Home tanpa menutup aplikasi. Notifikasi muncul pada sistem Android, kemudian ketika notifikasi diklik aplikasi terbuka dan mengarahkan pengguna ke halaman Pengumuman #7 melalui route /pengumuman/7.

|        Notifikasi Pengumuman        |      Tampilan Halaman Pengumuman      |
| :--------------------------------:  | :-----------------------------------: |
| ![screenshot](Screenshot/notif21.png) | ![screenshot](Screenshot/uji22.png) |

| State | Yang Diharapkan | Cara Uji | Status / Hasil |
| :--- | :--- | :--- | :---: |
| **Terminated** | Aplikasi terbuka ke rute yang benar via `getInitialMessage` | Swipe-close aplikasi (kill app), kirim dari Console, klik banner | Berhasil (Sesuai) |

Pengujian dilakukan saat aplikasi sudah ditutup sepenuhnya. Setelah notifikasi dikirim dan diklik, aplikasi terbuka kembali dan menggunakan getInitialMessage() untuk mengambil data notifikasi, kemudian mengarahkan pengguna ke halaman Pengumuman #12 melalui route /pengumuman/12.

|        Notifikasi Pengumuman        |     Tampilan Halaman Pengumuman       |
| :--------------------------------:  | :-----------------------------------: |
| ![screenshot](Screenshot/notif31.png) | ![screenshot](Screenshot/uji32.png) |

### Topic messaging

Aplikasi subscribe ke topic pengumuman-kampus untuk menerima notifikasi broadcast. Pengujian melalui Firebase Console berhasil mengirim notifikasi ke perangkat dan mengarahkan ke halaman pengumuman.

Hasil: Berhasil. Perangkat dapat menerima notifikasi yang dikirim melalui topic pengumuman-kampus.

|             Notifikasi              |             Target Topic             |    Tampilan Halaman Pengumuman 20   |
| :--------------------------------:  | :----------------------------------: |:----------------------------------: |
| ![screenshot](Screenshot/uji41.png) | ![screenshot](Screenshot/uji43.png) | ![screenshot](Screenshot/uji42.png) |

## AI Challenge

### AI Prompt Challenge

Hasil AI Challenge: Implementasi notifikasi berhasil dipertahankan dengan penambahan fungsi unsubscribe topic, penanganan permission Android 13+/iOS, serta dokumentasi bagian yang tidak menggunakan BuildContext. Fitur foreground, background, terminated, dan topic messaging tetap berjalan seperti sebelumnya.

### Kode push_repository.dart

|       Kode push_repository.dart 1     |      Kode push_repository.dart 2      |      Kode push_repository.dart 3      |
| :----------------------------------:  | :-----------------------------------: | :-----------------------------------: |
| ![screenshot](Screenshot/kodeAI1.png) | ![screenshot](Screenshot/kodeAI2.png) | ![screenshot](Screenshot/kodeAI3.png) |

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

### Perbaikan

### Kode auth_repository.dart

![screenshot](Screenshot/uji41.png)

### Kode push_service.dart

|         Kode push_service.dart 1        |         Kode push_service.dart 2         |
| :------------------------------------:  | :--------------------------------------: |
| ![screenshot](Screenshot/kode_push.png) | ![screenshot](Screenshot/kode_push2.png) |

2. onTokenRefresh mengirim token baru ke backend [✓] Terpenuhi

onTokenRefresh telah diperbaiki agar token FCM yang baru diterima dikirim melalui registerDeviceToken(). Pengujian menunjukkan token berhasil diteruskan ke backend mock dan hanya ditampilkan dalam bentuk terpotong pada log. Backend pada project ini masih berupa simulasi karena belum tersedia server API sungguhan.

## Refactoring, testing, dan error umum

### Refactoring Challenge

1. Pindahkan semua string rute (/login, /pengumuman/:id) ke satu file lib/routes.dart agar deep link dari FCM dan GoRouter memakai konstanta yang sama.

### Kode routes.dart

![screenshot](Screenshot/kode_routes.png)

### Kode main.dart
|           Kode main.dart 1   -           |            kode main.dart                |
| :-------------------------------------:  | :--------------------------------------: |
| ![screenshot](Screenshot/kode_main1.png) | ![screenshot](Screenshot/kode_main2.png) |

2. Ekstrak parsing RemoteMessage -> route ke fungsi murni routeFromMessage(Map<String, dynamic> data) agar bisa diunit-test tanpa Firebase.

### Kode routes.dart

![screenshot](Screenshot/kode_routes2.png)

### Kode push_service.dart

|        Kode push_service.dart 1      |        Kode push_service.dart 2       |
| :---------------------------------:  | :-----------------------------------: |
| ![screenshot](Screenshot/push1.png)  | ![screenshot](Screenshot/push2.png)   |

3. Pindahkan pemetaan DioException -> pesan ramah pengguna (401, timeout, offline) ke lib/data/api_errors.dart agar UI hanya menerima pesan, bukan exception mentah.

### Kode api_errors.dart

![screenshot](Screenshot/kode_api.png)

### Kode push_service.dart

|        Kode push_service.dart 1      |        Kode push_service.dart 2       |
| :---------------------------------:  | :-----------------------------------: |
| ![screenshot](Screenshot/push3.png)  | ![screenshot](Screenshot/push4.png)   |

### Flutter Analyze

![screenshot](Screenshot/flutter_analyze.png)

### Flutter Test

![screenshot](Screenshot/flutter_test.png)

### Checklist verifikasi mandiri

1. [✓] Token hanya di flutter_secure_storage, tidak di SharedPreferences/log/screenshot penuh.

### Kode token_store.dart

![screenshot](Screenshot/nomer1.png)

Token autentikasi disimpan menggunakan flutter_secure_storage, sehingga access_token dan refresh_token tidak disimpan di SharedPreferences. Token yang ditampilkan pada log juga sudah dipotong untuk menjaga keamanan.

2. [✓] 401 memicu refresh sekali lalu retry; refresh mati memaksa login ulang.

### Kode api_client.dart

![screenshot](Screenshot/nomer2.png)

Mekanisme penanganan 401 sudah diterapkan melalui interceptor, yaitu melakukan refresh access token dan mencoba kembali request. Jika proses refresh gagal, token akan dihapus sehingga pengguna dapat login kembali.

3. [✓] Ketiga app state teruji dengan tabel bukti; klik masuk ke rute yang benar.

Foreground, Background, dan Terminated sudah diuji dan klik notifikasi berhasil menuju route pengumuman.

4. [✓] Topik untuk broadcast, token untuk pesan personal.

Topic pengumuman-kampus digunakan untuk broadcast; token FCM digunakan untuk identifikasi perangkat/pesan personal.

5. [✓] flutter analyze bersih dan semua test lulus.

No issues found! dan All tests passed!.

## Tugas, refleksi, dan referensi

### Mini project / Industry Challenge
Bangun Campus Notification App (kembangkan project codelab atau buat baru):

1. Login (mock/Firebase Auth) dengan guard route: belum login selalu diarahkan ke /login.

2. Token disimpan di secure storage; Dio otomatis refresh sekali saat 401 dan logout bila refresh mati.

3. FCM terintegrasi: permission, getToken + onTokenRefresh terkirim ke backend (atau didokumentasikan endpoint POST /devices), dan subscribe topik pengumuman-kampus.

4. Notifikasi gabungan notification + data; klik membuka /pengumuman/:id pada ketiga app state. Isi tabel pengujian foreground/background/terminated di README.

5. Screenshot bukti (token terpotong, banner tiap state, halaman tujuan deep link) di folder screenshots/.

6. Sertakan minimal 2 test yang lulus (parsing route + logika sesi/refresh).

7. Kerjakan AI Challenge dan dokumentasikan prompt, output awal AI, perbaikan manual, dan alasan teknis di docs/.

8. Push ke repository portfolio pada folder 06-week-6-authentication-security-fcm/ dengan struktur lib/, test/, docs/, README.md, dan screenshots/. README menjelaskan tujuan, fitur utama, stack teknologi, cara menjalankan, dan hasil yang dicapai.

#### Halaman login

|                 Halaman login               |            Password Salah             |
| :-------------------------------------:     | :-----------------------------------: |
| ![screenshot](Screenshot/halaman_login.jpeg) | ![screenshot](Screenshot/login_salah.jpeg) |

#### Halaman Debug di HP yang menampilkan token terpotong yang baru.

|           Hasil token awal          |          Hasil token baru            |
| :--------------------------------:  | :----------------------------------: |
| ![screenshot](Screenshot/prak2.png) | ![screenshot](Screenshot/prak22.png) |

#### Foreground
 
|         Notifikasi Pengumuman         |          Notifikasi Pengumuman        |     Tampilan Halaman Pengumuman      |
| :----------------------------------:  | :-----------------------------------: | :----------------------------------: |
| ![screenshot](Screenshot/notif11.png) | ![screenshot](Screenshot/notif22.png) |  ![screenshot](Screenshot/uji12.png) |

#### Background

|        Notifikasi Pengumuman        |      Tampilan Halaman Pengumuman      |
| :--------------------------------:  | :-----------------------------------: |
| ![screenshot](Screenshot/notif21.png) | ![screenshot](Screenshot/uji22.png) |

#### Terminated

|        Notifikasi Pengumuman        |     Tampilan Halaman Pengumuman       |
| :--------------------------------:  | :-----------------------------------: |
| ![screenshot](Screenshot/notif31.png) | ![screenshot](Screenshot/uji32.png) |

### Flutter Analyze

![screenshot](Screenshot/flutter_analyze.png)

#### Flutter test

![screenshot](Screenshot/flutter_test.png)

### Refleksi

*1. Mengapa refresh token tidak boleh disimpan di SharedPreferences? Apa risikonya bila bocor?*

Jawab : Refresh token digunakan untuk mendapatkan access token baru ketika access token sudah tidak berlaku. Jika refresh token disimpan di SharedPreferences dan berhasil diakses pihak lain, token tersebut dapat digunakan untuk membuat sesi baru tanpa harus login kembali. Karena itu, refresh token lebih aman disimpan menggunakan flutter_secure_storage.

*2. Apa yang rusak bila onTokenRefresh diabaikan selama satu semester perkuliahan?*

Jawab : FCM Token perangkat dapat diperbarui sewaktu-waktu oleh sistem. Jika token baru tidak dikirim ke server, backend akan menyimpan token lama yang tidak valid (stale). Akibatnya, notifikasi personal penting (seperti tagihan UKT atau jadwal ujian) akan gagal terkirim (undelivered).

*3. Kapan memakai topik dan kapan memakai token perangkat? Beri contoh pesan kampus untuk masing-masing.*

Jawab : Topic digunakan untuk pesan yang sifatnya broadcast kepada banyak pengguna, misalnya pengumuman untuk seluruh mahasiswa atau satu kelas. Contohnya, notifikasi "Jadwal kuliah besok berubah" dapat dikirim ke topic pengumuman-kampus.

Token perangkat digunakan untuk pesan yang hanya ditujukan kepada perangkat atau pengguna tertentu. Contohnya, "Nilai praktikum Anda sudah tersedia" sebaiknya dikirim menggunakan token perangkat, bukan topic, karena bersifat personal.

*4. Bagian mana dari draf AI yang Anda tolak atau perbaiki, dan mengapa?*

Jawab : Gunakan QueuedInterceptorsWrapper: Mengganti wrapper standar AI agar request diantrekan secara aman saat refresh token, mencegah race condition.

Penyesuaian Method TokenStore: Menyesuaikan panggilan fungsi dari AI agar selaras dengan method yang sudah ada (readAccess, readRefresh, save, clear).

Ganti print ke debugPrint: Memperbaiki log bawaan AI untuk menghilangkan warning avoid_print demi kelulusan flutter analyze.

Setup Mock Firebase di Testing: Menambahkan setupFirebaseCoreMocks dan ProviderScope pada widget_test.dart agar unit test lulus tanpa harus menghapus filenya.