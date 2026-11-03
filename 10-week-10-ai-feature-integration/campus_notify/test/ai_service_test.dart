import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:campus_notify/ai/ai_service.dart';

// Fake Secure Storage untuk pengujian deterministik dalam memori
class FakeSecureStorage extends Fake implements FlutterSecureStorage {
  final Map<String, String> _storage = {};

  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value != null) {
      _storage[key] = value;
    } else {
      _storage.remove(key);
    }
  }

  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return _storage[key];
  }

  @override
  Future<void> delete({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _storage.remove(key);
  }
}

void main() {
  group('AiService - Sanitasi Data & Proteksi Privasi', () {
    late AiService aiService;
    late FakeSecureStorage fakeStorage;

    setUp(() {
      fakeStorage = FakeSecureStorage();
      aiService = AiService(storage: fakeStorage);
    });

    test('Sanitasi NIK 16-digit menjadi [REDACTED_NIK]', () {
      const input =
          'Tolong verifikasi data mahasiswa dengan NIK 3507123456780001 sekarang.';
      final sanitized = aiService.sanitizePrompt(input);

      expect(sanitized, contains('[REDACTED_NIK]'));
      expect(sanitized.contains('3507123456780001'), isFalse);
    });

    test('Sanitasi nomor HP Indonesia (+62 / 08) menjadi [REDACTED_PHONE]', () {
      const input =
          'Hubungi saya di nomor 081234567890 atau +6289876543210 untuk konfirmasi.';
      final sanitized = aiService.sanitizePrompt(input);

      expect(sanitized, contains('[REDACTED_PHONE]'));
      expect(sanitized.contains('081234567890'), isFalse);
      expect(sanitized.contains('+6289876543210'), isFalse);
    });

    test('Sanitasi alamat email menjadi [REDACTED_EMAIL]', () {
      const input =
          'Kirimkan hasil verifikasi ke email mahasiswa.test@polinema.ac.id';
      final sanitized = aiService.sanitizePrompt(input);

      expect(sanitized, contains('[REDACTED_EMAIL]'));
      expect(sanitized.contains('mahasiswa.test@polinema.ac.id'), isFalse);
    });
  });

  group('AiService - HTTP API Calls, Caching, & Error Handling', () {
    late FakeSecureStorage fakeStorage;

    setUp(() {
      fakeStorage = FakeSecureStorage();
    });

    test('Melempar Exception jika API Key belum dikonfigurasi', () async {
      final aiService = AiService(storage: fakeStorage);

      expect(
        () => aiService.ask('Apa jadwal kuliah hari ini?'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('API key tidak tersedia'),
          ),
        ),
      );
    });

    test('ask() berhasil memparsing respons kandidat Gemini 200 OK', () async {
      await fakeStorage.write(key: 'ai_api_key', value: 'fake_key_123');

      final mockClient = MockClient((request) async {
        expect(request.url.queryParameters['key'], equals('fake_key_123'));
        return http.Response(
          jsonEncode({
            'candidates': [
              {
                'content': {
                  'parts': [
                    {
                      'text': 'Jadwal kuliah Anda hari ini adalah Pemrograman Mobile.',
                    },
                  ],
                },
              },
            ],
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final aiService = AiService(storage: fakeStorage, client: mockClient);
      final response = await aiService.ask('Jadwal hari ini apa?');

      expect(
        response,
        equals('Jadwal kuliah Anda hari ini adalah Pemrograman Mobile.'),
      );
    });

    test(
      'Cache lokal aktif: Pemanggilan kedua tidak melakukan request HTTP ulang',
      () async {
        await fakeStorage.write(key: 'ai_api_key', value: 'fake_key_123');

        int requestCount = 0;
        final mockClient = MockClient((request) async {
          requestCount++;
          return http.Response(
            jsonEncode({
              'candidates': [
                {
                  'content': {
                    'parts': [
                      {'text': 'Jawaban tersimpan di cache'},
                    ],
                  },
                },
              ],
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        });

        final aiService = AiService(storage: fakeStorage, client: mockClient);

        final resp1 = await aiService.ask('Pertanyaan berulang');
        final resp2 = await aiService.ask('Pertanyaan berulang');

        expect(resp1, equals('Jawaban tersimpan di cache'));
        expect(resp2, equals('Jawaban tersimpan di cache'));
        expect(
          requestCount,
          equals(1),
        ); // Hanya 1 kali panggil HTTP karena cache hit!
      },
    );

    test(
      'ask() melempar Exception yang ramah ketika rate limit 429 terjadi',
      () async {
        await fakeStorage.write(key: 'ai_api_key', value: 'fake_key_123');

        final mockClient = MockClient((request) async {
          return http.Response('Rate limit exceeded', 429);
        });

        final aiService = AiService(storage: fakeStorage, client: mockClient);

        expect(
          () => aiService.ask('Pertanyaan saat server sibuk'),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Batas rate limit terlampaui'),
            ),
          ),
        );
      },
    );

    test('askStream() mengalirkan potongan kata secara sekuensial', () async {
      await fakeStorage.write(key: 'ai_api_key', value: 'fake_key_123');

      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'candidates': [
              {
                'content': {
                  'parts': [
                    {'text': 'Halo dunia Polinema'},
                  ],
                },
              },
            ],
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final aiService = AiService(storage: fakeStorage, client: mockClient);
      final streamChunks = <String>[];

      await for (final chunk in aiService.askStream('Sapa saya')) {
        streamChunks.add(chunk);
      }

      expect(streamChunks.join(''), equals('Halo dunia Polinema'));
      expect(streamChunks.length, equals(3));
    });
  });

  group('AiService - OCR, Speech-to-Text, & Offline Fallback', () {
    late AiService aiService;
    late FakeSecureStorage fakeStorage;

    setUp(() {
      fakeStorage = FakeSecureStorage();
      aiService = AiService(storage: fakeStorage);
    });

    test(
      'recognizeText() memberikan fallback offline saat API Key belum ada',
      () async {
        final dummyBytes = [1, 2, 3, 4, 5];
        final result = await aiService.recognizeText(dummyBytes);

        expect(result, contains('[OFFLINE OCR]'));
        expect(result, contains('NIM: 244107020054'));
      },
    );

    test('speechToText() menghasilkan teks transkripsi suara', () async {
      final transcribed = await aiService.speechToText(null);

      expect(transcribed, isNotEmpty);
      expect(transcribed, contains('KTM'));
    });

    test('getOfflineFallback() memberikan jawaban spesifik sesuai kata kunci kampus', () {
      final ktmAnswer = aiService.getOfflineFallback(
        'Bagaimana cara buat KTM baru?',
      );
      expect(ktmAnswer, contains('Gedung Pelayanan Akademik'));

      final krsAnswer = aiService.getOfflineFallback('Kapan bimbingan KRS?');
      expect(krsAnswer, contains('SIAKAD'));

      final perpusAnswer = aiService.getOfflineFallback(
        'Berapa lama pinjam buku di perpustakaan?',
      );
      expect(perpusAnswer, contains('Perpustakaan'));

      final beasiswaAnswer = aiService.getOfflineFallback(
        'Info beasiswa KIP ada?',
      );
      expect(beasiswaAnswer, contains('KIP-Kuliah'));
    });
  });
}
