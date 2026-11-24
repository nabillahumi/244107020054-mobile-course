import 'package:flutter_test/flutter_test.dart';
import 'package:campus_notify/is_valid_task_title.dart';

void main() {
  group('isValidTaskTitle - Pola AAA & Kasus Tepi', () {
    test('menerima judul yang berisi teks', () {
      // Arrange: siapkan data input tugas
      const title = 'Belajar Flutter';

      // Act: panggil fungsi validasi yang diuji
      final result = isValidTaskTitle(title);

      // Assert: periksa ekspektasi hasil
      expect(result, isTrue);
    });

    test('menolak teks kosong atau hanya spasi', () {
      // Arrange: siapkan string kosong dan spasi saja
      const emptyInput = '';
      const spaceOnlyInput = '   ';

      // Act: jalankan fungsi validasi
      final emptyResult = isValidTaskTitle(emptyInput);
      final spaceResult = isValidTaskTitle(spaceOnlyInput);

      // Assert: pastikan ditolak (isFalse)
      expect(emptyResult, isFalse);
      expect(spaceResult, isFalse);
    });

    test(
      'kasus tepi: menolak whitespace berupa gabungan tab, newline, dan spasi',
      () {
        // Arrange
        const whitespaceInput = '\t\n   \r\n';

        // Act
        final result = isValidTaskTitle(whitespaceInput);

        // Assert
        expect(result, isFalse);
      },
    );

    test('kasus tepi: menerima judul tugas dengan spasi berlebih di awal dan akhir', () {
      // Arrange
      const paddedInput = '   Praktikum Pengujian Kualitas Perangkat Lunak   ';

      // Act
      final result = isValidTaskTitle(paddedInput);

      // Assert
      expect(result, isTrue);
    });

    test(
      'kasus tepi: menerima teks dengan simbol, emoji, dan karakter numerik',
      () {
        // Arrange
        const unicodeInput = 'Tugas #12: Testing & QA 🚀 [PENTING] 100%';

        // Act
        final result = isValidTaskTitle(unicodeInput);

        // Assert
        expect(result, isTrue);
      },
    );
  });

  group('isValidTaskTitleWithLimits - Batas Panjang Karakter', () {
    test('menerima teks yang berada di dalam rentang batas panjang normal', () {
      // Arrange
      const validTitle = 'Kerjakan Modul Jobsheet 12';

      // Act
      final result = isValidTaskTitleWithLimits(
        validTitle,
        minLength: 3,
        maxLength: 50,
      );

      // Assert
      expect(result, isTrue);
    });

    test(
      'kasus tepi: menolak teks yang kurang dari batas minimum (minLength: 3)',
      () {
        // Arrange
        const tooShortTitle = 'IT';

        // Act
        final result = isValidTaskTitleWithLimits(
          tooShortTitle,
          minLength: 3,
          maxLength: 50,
        );

        // Assert
        expect(result, isFalse);
      },
    );

    test(
      'kasus tepi: menolak teks yang melebihi batas maksimum (maxLength: 50)',
      () {
        // Arrange: string 51 karakter
        final tooLongTitle = 'A' * 51;

        // Act
        final result = isValidTaskTitleWithLimits(
          tooLongTitle,
          minLength: 3,
          maxLength: 50,
        );

        // Assert
        expect(result, isFalse);
      },
    );

    test('kasus batas: menerima teks yang tepat berada di batas batas minimum dan maksimum', () {
      // Arrange: 3 karakter dan 50 karakter
      final boundaryMin = 'ABC';
      final boundaryMax = 'A' * 50;

      // Act & Assert
      expect(
        isValidTaskTitleWithLimits(boundaryMin, minLength: 3, maxLength: 50),
        isTrue,
      );
      expect(
        isValidTaskTitleWithLimits(boundaryMax, minLength: 3, maxLength: 50),
        isTrue,
      );
    });
  });
}
