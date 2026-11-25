import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/location_model.dart';

/// Service penyimpanan lokal berbasis `SharedPreferences` untuk mengelola:
/// 1. Daftar lokasi favorit pengguna
/// 2. Lokasi kota terakhir yang dipilih (aktif saat aplikasi dibuka kembali)
/// 3. Riwayat lokasi hasil pencarian terakhir
class LocalStorageService {
  static const String _favoritesKey = 'favorite_locations_v1';
  static const String _lastLocationKey = 'last_selected_location_v1';
  static const String _recentLocationsKey = 'recent_selected_locations_v1';

  /// Memuat daftar kota favorit yang tersimpan di penyimpanan lokal.
  Future<List<LocationModel>> getFavoriteLocations() async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList(_favoritesKey) ?? const [];
    return _decodeLocationList(rawList);
  }

  /// Menyimpan daftar kota favorit ke dalam SharedPreferences.
  Future<void> saveFavoriteLocations(List<LocationModel> locations) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = locations
        .map((location) => jsonEncode(location.toJson()))
        .toList();
    await prefs.setStringList(_favoritesKey, encoded);
  }

  /// Mengambil lokasi kota terakhir yang dipilih oleh pengguna.
  Future<LocationModel?> getLastSelectedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final rawJson = prefs.getString(_lastLocationKey);
    if (rawJson == null || rawJson.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(rawJson) as Map<String, dynamic>;
      return LocationModel.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  /// Menyimpan lokasi kota aktif terakhir agar dimuat otomatis saat app dibuka ulang.
  Future<void> saveLastSelectedLocation(LocationModel location) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastLocationKey, jsonEncode(location.toJson()));
  }

  /// Memuat riwayat lokasi pencarian yang pernah dipilih pengguna.
  Future<List<LocationModel>> getRecentLocations() async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList(_recentLocationsKey) ?? const [];
    return _decodeLocationList(rawList);
  }

  /// Menyimpan daftar riwayat lokasi pencarian terakhir.
  Future<void> saveRecentLocations(List<LocationModel> locations) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = locations
        .map((location) => jsonEncode(location.toJson()))
        .toList();
    await prefs.setStringList(_recentLocationsKey, encoded);
  }

  /// Menghapus seluruh daftar riwayat pencarian lokasi.
  Future<void> clearRecentLocations() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_recentLocationsKey);
  }

  /// Helper aman untuk mendecode list JSON string menjadi `List<LocationModel>`.
  List<LocationModel> _decodeLocationList(List<String> rawList) {
    final locations = <LocationModel>[];
    for (final rawItem in rawList) {
      try {
        final decoded = jsonDecode(rawItem) as Map<String, dynamic>;
        locations.add(LocationModel.fromJson(decoded));
      } catch (_) {
        // Lewati entri yang rusak agar aplikasi tetap berjalan stabil
      }
    }
    return locations;
  }
}
