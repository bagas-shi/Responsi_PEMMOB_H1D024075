import 'package:flutter/foundation.dart';

import '../models/location_model.dart';
import '../services/local_storage_service.dart';
import '../services/weather_api_service.dart';

/// Status state proses pencarian lokasi kota pada Search Screen.
enum SearchLoadState {
  idle,
  loading,
  loaded,
  empty,
  error,
}

/// ViewModel untuk mengelola pencarian kota (Geocoding API), daftar lokasi
/// favorit, serta riwayat lokasi terakhir yang tersimpan di Local Storage.
class LocationViewModel extends ChangeNotifier {
  static const int _maxRecentLocations = 8;

  final WeatherApiService _apiService;
  final LocalStorageService _storageService;

  SearchLoadState _searchState = SearchLoadState.idle;
  String _lastQuery = '';
  List<LocationModel> _searchResults = const [];
  List<LocationModel> _favorites = [];
  List<LocationModel> _recentLocations = [];
  String? _errorMessage;
  bool _disposed = false;

  LocationViewModel({
    WeatherApiService? apiService,
    LocalStorageService? storageService,
  })  : _apiService = apiService ?? WeatherApiService(),
        _storageService = storageService ?? LocalStorageService();

  // ================= GETTERS UNTUK VIEW =================
  SearchLoadState get searchState => _searchState;
  String get lastQuery => _lastQuery;
  List<LocationModel> get searchResults => List.unmodifiable(_searchResults);
  List<LocationModel> get favorites => List.unmodifiable(_favorites);
  List<LocationModel> get recentLocations =>
      List.unmodifiable(_recentLocations);
  String? get errorMessage => _errorMessage;

  /// Memuat daftar kota favorit dan riwayat pencarian dari SharedPreferences
  /// ketika aplikasi pertama kali dijalankan.
  Future<void> loadSavedData() async {
    _favorites = await _storageService.getFavoriteLocations();
    _recentLocations = await _storageService.getRecentLocations();
    _safeNotify();
  }

  /// Melakukan pencarian kota secara real-time melalui HTTP GET Geocoding API.
  Future<void> searchCity(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      clearSearch();
      return;
    }

    _lastQuery = trimmed;
    _searchState = SearchLoadState.loading;
    _errorMessage = null;
    _safeNotify();

    try {
      final results = await _apiService.searchCities(trimmed);
      _searchResults = results;
      _searchState =
          results.isEmpty ? SearchLoadState.empty : SearchLoadState.loaded;
      _safeNotify();
    } on WeatherApiException catch (e) {
      _errorMessage = e.message;
      _searchState = SearchLoadState.error;
      _safeNotify();
    } catch (_) {
      _errorMessage = 'Gagal mencari lokasi kota. Silakan coba kembali.';
      _searchState = SearchLoadState.error;
      _safeNotify();
    }
  }

  /// Mengulangi pencarian terakhir apabila sebelumnya terjadi error jaringan.
  Future<void> retryLastSearch() async {
    if (_lastQuery.isNotEmpty) {
      await searchCity(_lastQuery);
    }
  }

  /// Mereset hasil dan status pencarian kembali ke kondisi awal (idle).
  void clearSearch() {
    _lastQuery = '';
    _searchResults = const [];
    _errorMessage = null;
    _searchState = SearchLoadState.idle;
    _safeNotify();
  }

  /// Mengecek apakah suatu lokasi sudah termasuk dalam daftar Favorit.
  bool isFavorite(LocationModel location) {
    return _favorites.any((item) => item.uniqueKey == location.uniqueKey);
  }

  /// Menambah atau menghapus lokasi dari daftar Favorit dan menyimpannya ke
  /// Local Storage. Mengembalikan `true` jika ditambahkan, `false` jika dihapus.
  Future<bool> toggleFavorite(LocationModel location) async {
    final existingIndex =
        _favorites.indexWhere((item) => item.uniqueKey == location.uniqueKey);

    final bool added;
    if (existingIndex >= 0) {
      _favorites.removeAt(existingIndex);
      added = false;
    } else {
      _favorites.insert(0, location);
      added = true;
    }

    await _storageService.saveFavoriteLocations(_favorites);
    _safeNotify();
    return added;
  }

  /// Mencatat kota yang dipilih ke dalam riwayat pencarian terbaru (maks 8 kota).
  Future<void> recordSelectedLocation(LocationModel location) async {
    _recentLocations.removeWhere(
      (item) => item.uniqueKey == location.uniqueKey,
    );
    _recentLocations.insert(0, location);
    if (_recentLocations.length > _maxRecentLocations) {
      _recentLocations = _recentLocations.sublist(0, _maxRecentLocations);
    }

    await _storageService.saveRecentLocations(_recentLocations);
    _safeNotify();
  }

  /// Menghapus seluruh riwayat pencarian kota dari penyimpanan lokal.
  Future<void> clearRecentHistory() async {
    _recentLocations = [];
    await _storageService.clearRecentLocations();
    _safeNotify();
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
