import 'dart:convert';

import 'package:cuaca/main.dart';
import 'package:cuaca/models/location_model.dart';
import 'package:cuaca/models/weather_model.dart';
import 'package:cuaca/services/local_storage_service.dart';
import 'package:cuaca/services/weather_api_service.dart';
import 'package:cuaca/viewmodels/location_viewmodel.dart';
import 'package:cuaca/viewmodels/weather_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Fake HTTP Client untuk mensimulasikan respons JSON Open-Meteo secara
/// deterministik pada pengujian unit & widget.
class _FakeOpenMeteoClient extends http.BaseClient {
  final bool shouldFail;

  _FakeOpenMeteoClient({this.shouldFail = false});

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (shouldFail) {
      return http.StreamedResponse(
        Stream.value(utf8.encode('Server Error')),
        500,
      );
    }

    final url = request.url;
    if (url.host.contains('geocoding-api.open-meteo.com')) {
      final query = (url.queryParameters['name'] ?? '').toLowerCase();
      if (query.contains('tidakada')) {
        return http.StreamedResponse(
          Stream.value(utf8.encode(jsonEncode({'generationtime_ms': 0.5}))),
          200,
        );
      }

      final payload = {
        'results': [
          {
            'id': 1621177,
            'name': 'Yogyakarta',
            'latitude': -7.7971,
            'longitude': 110.3705,
            'country': 'Indonesia',
            'country_code': 'ID',
            'admin1': 'Daerah Istimewa Yogyakarta',
            'timezone': 'Asia/Jakarta',
          },
          {
            'id': 1642911,
            'name': 'Jakarta',
            'latitude': -6.2146,
            'longitude': 106.8451,
            'country': 'Indonesia',
            'country_code': 'ID',
            'admin1': 'DKI Jakarta',
            'timezone': 'Asia/Jakarta',
          },
        ],
      };
      return http.StreamedResponse(
        Stream.value(utf8.encode(jsonEncode(payload))),
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    }

    // Simulasi respons Weather Forecast API Open-Meteo
    final forecastPayload = {
      'latitude': -7.7971,
      'longitude': 110.3705,
      'timezone': 'Asia/Jakarta',
      'timezone_abbreviation': 'WIB',
      'current': {
        'time': '2026-11-26T09:00',
        'temperature_2m': 29.4,
        'relative_humidity_2m': 68,
        'apparent_temperature': 32.1,
        'precipitation': 0.2,
        'weather_code': 2,
        'wind_speed_10m': 11.5,
      },
      'daily': {
        'time': [
          '2026-11-26',
          '2026-11-27',
          '2026-11-28',
          '2026-11-29',
          '2026-11-30',
        ],
        'weather_code': [2, 61, 1, 80, 95],
        'temperature_2m_max': [32.0, 30.5, 31.8, 29.9, 29.0],
        'temperature_2m_min': [24.2, 23.8, 24.0, 23.5, 23.1],
        'precipitation_probability_max': [65, 80, 30, 75, 90],
      },
    };

    return http.StreamedResponse(
      Stream.value(utf8.encode(jsonEncode(forecastPayload))),
      200,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  group('Model & LocalStorage Unit Tests', () {
    test('WeatherData.fromJson memparsing seluruh field wajib Open-Meteo', () {
      final sampleJson = {
        'latitude': -7.79,
        'longitude': 110.37,
        'timezone': 'Asia/Jakarta',
        'current': {
          'time': '2026-11-26T10:00',
          'temperature_2m': 28.5,
          'relative_humidity_2m': 63,
          'apparent_temperature': 31.0,
          'precipitation': 1.4,
          'weather_code': 61,
          'wind_speed_10m': 14.2,
        },
        'daily': {
          'time': ['2026-11-26', '2026-11-27'],
          'weather_code': [61, 1],
          'temperature_2m_max': [31.2, 32.4],
          'temperature_2m_min': [24.0, 23.6],
          'precipitation_probability_max': [70, 25],
        },
      };

      final data = WeatherData.fromJson(sampleJson);
      expect(data.current.temperature2m, 28.5);
      expect(data.current.relativeHumidity2m, 63);
      expect(data.current.apparentTemperature, 31.0);
      expect(data.current.precipitation, 1.4);
      expect(data.current.weatherCode, 61);
      expect(data.current.condition.label, 'Hujan Ringan');
      expect(data.current.windSpeed10m, 14.2);
      expect(data.daily.length, 2);
      expect(data.daily.first.temperatureMax, 31.2);
      expect(data.daily.first.temperatureMin, 24.0);
      expect(data.todayPrecipitationProbability, 70);
    });

    test('LocalStorageService menyimpan lokasi favorit dan lokasi terakhir',
        () async {
      SharedPreferences.setMockInitialValues({});
      final storage = LocalStorageService();

      const yogya = LocationModel(
        id: 1621177,
        name: 'Yogyakarta',
        latitude: -7.7971,
        longitude: 110.3705,
        country: 'Indonesia',
        admin1: 'DI Yogyakarta',
      );

      await storage.saveLastSelectedLocation(yogya);
      await storage.saveFavoriteLocations([yogya]);

      final loadedLast = await storage.getLastSelectedLocation();
      final loadedFavorites = await storage.getFavoriteLocations();

      expect(loadedLast?.name, 'Yogyakarta');
      expect(loadedFavorites.length, 1);
      expect(loadedFavorites.first.uniqueKey, yogya.uniqueKey);
    });
  });

  group('Home & Search Screen Widget Tests (MVVM + Provider)', () {
    testWidgets(
        'Menampilkan cuaca terkini di Home Screen dan navigasi ke Search Screen',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final api = WeatherApiService(client: _FakeOpenMeteoClient());
      final storage = LocalStorageService();

      final weatherVM =
          WeatherViewModel(apiService: api, storageService: storage);
      final locationVM =
          LocationViewModel(apiService: api, storageService: storage);

      await weatherVM.initialize();
      await locationVM.loadSavedData();

      await tester.pumpWidget(
        WeatherApp(
          weatherViewModel: weatherVM,
          locationViewModel: locationVM,
        ),
      );
      await tester.pumpAndSettle();

      // Verifikasi Home Screen merender lokasi, kondisi cuaca, dan metrik utama
      expect(find.text('Yogyakarta'), findsOneWidget);
      expect(find.text('29.4'), findsOneWidget);
      expect(find.text('Cerah Berawan'), findsOneWidget);
      expect(find.text('Kelembapan'), findsOneWidget);
      expect(find.text('Kecepatan Angin'), findsOneWidget);
      expect(find.text('Curah Hujan'), findsOneWidget);
      expect(find.text('Peluang Hujan'), findsOneWidget);
      expect(find.text('Perkiraan Mingguan'), findsOneWidget);

      // Navigasi ke Search Screen melalui tombol pencarian
      await tester.tap(find.byTooltip('Cari Kota & Favorit'));
      await tester.pumpAndSettle();

      expect(find.text('Lokasi & Pencarian Kota'), findsOneWidget);
      expect(find.text('SEARCH'), findsOneWidget);
      expect(find.text('CANCEL'), findsOneWidget);
    });

    testWidgets(
        'Menampilkan Error State beserta tombol COBA LAGI ketika request gagal',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final failingApi =
          WeatherApiService(client: _FakeOpenMeteoClient(shouldFail: true));
      final storage = LocalStorageService();

      final weatherVM = WeatherViewModel(
        apiService: failingApi,
        storageService: storage,
      );
      final locationVM = LocationViewModel(
        apiService: failingApi,
        storageService: storage,
      );

      await weatherVM.initialize();
      await locationVM.loadSavedData();

      await tester.pumpWidget(
        WeatherApp(
          weatherViewModel: weatherVM,
          locationViewModel: locationVM,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Gagal Memuat Cuaca'), findsOneWidget);
      expect(find.text('COBA LAGI'), findsOneWidget);
    });
  });
}
