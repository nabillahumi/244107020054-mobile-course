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

1. Buka Firebase Console -> Messaging -> buat campaign notifikasi percobaan.

![screenshot](Screenshot/uji1.png)

2. Masukkan title dan body, targetkan aplikasi Android Anda.

![screenshot](Screenshot/uji2.png)

3. Kirim saat aplikasi dalam state background: banner sistem harus muncul. Klik banner: aplikasi terbuka.

![screenshot](Screenshot/hasil_uji.png)

setelah mengklik notifikasi tersebut langsung aplikasi terbuka