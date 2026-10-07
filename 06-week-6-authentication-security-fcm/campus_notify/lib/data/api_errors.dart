import 'package:dio/dio.dart';

String mapDioErrorToMessage(DioException error) {
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return 'Koneksi ke server terputus (timeout). Silakan coba lagi.';
    case DioExceptionType.connectionError:
      return 'Tidak ada koneksi internet. Periksa perangkat Anda.';
    case DioExceptionType.badResponse:
      final statusCode = error.response?.statusCode;
      if (statusCode == 401) {
        return 'Sesi Anda telah berakhir. Silakan login kembali.';
      } else if (statusCode == 403) {
        return 'Anda tidak memiliki hak akses untuk melakukan aksi ini.';
      } else if (statusCode == 404) {
        return 'Data yang Anda cari tidak ditemukan.';
      } else if (statusCode != null && statusCode >= 500) {
        return 'Terjadi gangguan pada server. Silakan coba beberapa saat lagi.';
      }
      return 'Gagal memproses permintaan ($statusCode).';
    case DioExceptionType.cancel:
      return 'Permintaan dibatalkan.';
    default:
      return 'Terjadi kesalahan tidak terduga. Silakan coba lagi.';
  }
}