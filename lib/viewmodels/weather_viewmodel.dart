import 'package:flutter/foundation.dart';

import '../models/location_model.dart';
import '../models/weather_model.dart';
import '../services/local_storage_service.dart';
import '../services/weather_api_service.dart';

/// Status state pemuatan data cuaca untuk dikonsumsi secara reaktif oleh View.
enum WeatherLoadState {
  initial,
  loading,
  loaded,
  empty,
  error,
}

/// ViewModel utama untuk mengelola state cuaca terkini dan perkiraan mingguan
/// menggunakan pola MVVM dengan `ChangeNotifier` (Provider).
class WeatherViewModel extends ChangeNotifier {
  static const String _defaultInitialCityQuery = 'Yogyakarta';

  final WeatherApiService _apiService;
  final LocalStorageService _storageService;

  WeatherLoadState _state = WeatherLoadState.initial;
  LocationModel? _selectedLocation;
  WeatherData? _weatherData;
  String? _errorMessage;
  bool _isRefreshing = false;
  bool _disposed = false;

  WeatherViewModel({
    WeatherApiService? apiService,
    LocalStorageService? storageService,
  })  : _apiService = apiService ?? WeatherApiService(),
        _storageService = storageService ?? LocalStorageService();

  // ================= GETTERS UNTUK VIEW =================
  WeatherLoadState get state => _state;
  LocationModel? get selectedLocation => _selectedLocation;
  WeatherData? get weatherData => _weatherData;
  String? get errorMessage => _errorMessage;
  bool get isRefreshing => _isRefreshing;

  /// Inisialisasi awal saat aplikasi dijalankan:
  /// Memeriksa lokasi terakhir di Local Storage, atau mencari kota awal secara
  /// real-time melalui Geocoding API bila aplikasi baru pertama kali dibuka.
  Future<void> initialize() async {
    _state = WeatherLoadState.loading;
    _errorMessage = null;
    _safeNotify();

    try {
      LocationModel? initialLocation =
          await _storageService.getLastSelectedLocation();

      if (initialLocation == null) {
        final geocodedCities =
            await _apiService.searchCities(_defaultInitialCityQuery);
        if (geocodedCities.isNotEmpty) {
          initialLocation = geocodedCities.first;
          await _storageService.saveLastSelectedLocation(initialLocation);
        }
      }

      if (initialLocation == null) {
        _state = WeatherLoadState.empty;
        _safeNotify();
        return;
      }

      _selectedLocation = initialLocation;
      await _fetchForecastFor(initialLocation);
    } on WeatherApiException catch (e) {
      _errorMessage = e.message;
      _state = WeatherLoadState.error;
      _safeNotify();
    } catch (_) {
      _errorMessage = 'Gagal menyiapkan data cuaca awal. Silakan coba lagi.';
      _state = WeatherLoadState.error;
      _safeNotify();
    }
  }

  /// Memilih kota baru (dari Search Screen atau Daftar Favorit), menyimpannya
  /// sebagai lokasi terakhir di Local Storage, lalu memuat data cuacanya.
  Future<void> selectLocation(LocationModel location) async {
    _selectedLocation = location;
    _state = WeatherLoadState.loading;
    _errorMessage = null;
    _safeNotify();

    await _storageService.saveLastSelectedLocation(location);
    await _fetchForecastFor(location);
  }

  /// Memuat ulang (refresh) data cuaca lokasi yang sedang aktif secara real-time.
  Future<void> refreshWeather() async {
    final targetLocation = _selectedLocation;
    if (targetLocation == null) {
      await initialize();
      return;
    }

    // Bila sudah ada data sebelumnya, tampilkan indikator refresh halus
    if (_weatherData != null && _state == WeatherLoadState.loaded) {
      _isRefreshing = true;
      _errorMessage = null;
      _safeNotify();
    } else {
      _state = WeatherLoadState.loading;
      _errorMessage = null;
      _safeNotify();
    }

    await _fetchForecastFor(targetLocation);
  }

  /// Helper internal pemanggil Weather Forecast API beserta transisi state.
  Future<void> _fetchForecastFor(LocationModel location) async {
    try {
      final forecast = await _apiService.fetchWeatherForecast(
        latitude: location.latitude,
        longitude: location.longitude,
      );

      _weatherData = forecast;
      _isRefreshing = false;
      _errorMessage = null;
      _state =
          forecast.daily.isEmpty ? WeatherLoadState.empty : WeatherLoadState.loaded;
      _safeNotify();
    } on WeatherApiException catch (e) {
      _isRefreshing = false;
      _errorMessage = e.message;
      _state = WeatherLoadState.error;
      _safeNotify();
    } catch (_) {
      _isRefreshing = false;
      _errorMessage = 'Terjadi kesalahan saat mengambil data cuaca terbaru.';
      _state = WeatherLoadState.error;
      _safeNotify();
    }
  }

  void _safeNotify() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
