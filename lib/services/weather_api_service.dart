import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/location_model.dart';
import '../models/weather_model.dart';

/// Exception khusus untuk merepresentasikan kegagalan komunikasi dengan API
/// dalam pesan yang ramah pengguna.
class WeatherApiException implements Exception {
  final String message;

  const WeatherApiException(this.message);

  @override
  String toString() => message;
}

/// Service HTTP REST API untuk berinteraksi secara real-time dengan Open-Meteo:
/// 1. Geocoding API (`https://geocoding-api.open-meteo.com/v1/search`)
/// 2. Weather Forecast API (`https://api.open-meteo.com/v1/forecast`)
class WeatherApiService {
  static const String _geocodingHost = 'geocoding-api.open-meteo.com';
  static const String _forecastHost = 'api.open-meteo.com';
  static const Duration _requestTimeout = Duration(seconds: 12);

  /// Fields wajib parameter `current` sesuai spesifikasi Open-Meteo.
  static const String _currentFields =
      'temperature_2m,relative_humidity_2m,apparent_temperature,'
      'precipitation,weather_code,wind_speed_10m';

  /// Fields wajib parameter `daily` sesuai spesifikasi Open-Meteo.
  static const String _dailyFields =
      'weather_code,temperature_2m_max,temperature_2m_min,'
      'precipitation_probability_max';

  final http.Client _client;

  WeatherApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Mencari daftar lokasi kota berdasarkan nama menggunakan metode HTTP GET
  /// ke endpoint Geocoding API Open-Meteo.
  Future<List<LocationModel>> searchCities(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return const [];
    }

    final uri = Uri.https(_geocodingHost, '/v1/search', {
      'name': trimmed,
      'count': '15',
      'language': 'id',
      'format': 'json',
    });

    try {
      final response = await _client.get(uri).timeout(_requestTimeout);

      if (response.statusCode != 200) {
        throw WeatherApiException(
          'Gagal memuat daftar kota (HTTP ${response.statusCode}).',
        );
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final rawResults = decoded['results'] as List<dynamic>?;

      // Open-Meteo tidak menyertakan key `results` apabila kota tidak ditemukan
      if (rawResults == null || rawResults.isEmpty) {
        return const [];
      }

      return rawResults
          .whereType<Map<String, dynamic>>()
          .map(LocationModel.fromJson)
          .toList();
    } on WeatherApiException {
      rethrow;
    } on SocketException {
      throw const WeatherApiException(
        'Tidak dapat terhubung ke internet. Periksa koneksi jaringan Anda.',
      );
    } on TimeoutException {
      throw const WeatherApiException(
        'Waktu permintaan ke server habis. Silakan coba beberapa saat lagi.',
      );
    } on FormatException {
      throw const WeatherApiException(
        'Format data respons lokasi dari server tidak valid.',
      );
    } on http.ClientException {
      throw const WeatherApiException(
        'Gagal menghubungi layanan pencarian lokasi. Periksa jaringan Anda.',
      );
    } catch (_) {
      throw const WeatherApiException(
        'Terjadi kesalahan tak terduga saat mencari lokasi kota.',
      );
    }
  }

  /// Mengambil data cuaca terkini (`current`) dan perkiraan harian (`daily`)
  /// secara real-time menggunakan metode HTTP GET berdasarkan koordinat lokasi.
  Future<WeatherData> fetchWeatherForecast({
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.https(_forecastHost, '/v1/forecast', {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'current': _currentFields,
      'daily': _dailyFields,
      'timezone': 'auto',
      'forecast_days': '7',
    });

    try {
      final response = await _client.get(uri).timeout(_requestTimeout);

      if (response.statusCode != 200) {
        throw WeatherApiException(
          'Gagal mengambil data cuaca (HTTP ${response.statusCode}).',
        );
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      if (!decoded.containsKey('current') || !decoded.containsKey('daily')) {
        throw const WeatherApiException(
          'Data cuaca dari server tidak lengkap untuk lokasi ini.',
        );
      }

      return WeatherData.fromJson(decoded);
    } on WeatherApiException {
      rethrow;
    } on SocketException {
      throw const WeatherApiException(
        'Koneksi internet terputus. Pastikan perangkat terhubung ke jaringan.',
      );
    } on TimeoutException {
      throw const WeatherApiException(
        'Permintaan data cuaca melewati batas waktu (timeout).',
      );
    } on FormatException {
      throw const WeatherApiException(
        'Gagal mengolah format data cuaca dari server.',
      );
    } on http.ClientException {
      throw const WeatherApiException(
        'Tidak dapat menjangkau server cuaca Open-Meteo.',
      );
    } catch (_) {
      throw const WeatherApiException(
        'Terjadi kendala saat memuat informasi cuaca terkini.',
      );
    }
  }
}
