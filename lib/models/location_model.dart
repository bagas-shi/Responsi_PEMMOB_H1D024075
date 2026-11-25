/// Model data lokasi kota hasil pencarian dari Open-Meteo Geocoding API
/// sekaligus model yang disimpan ke dalam Local Storage (SharedPreferences).
class LocationModel {
  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final String country;
  final String? countryCode;
  final String? admin1;
  final String? timezone;

  const LocationModel({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.country,
    this.countryCode,
    this.admin1,
    this.timezone,
  });

  /// Kunci unik untuk membandingkan lokasi favorit dan mencegah duplikasi data.
  String get uniqueKey => id != 0
      ? 'id_$id'
      : '${latitude.toStringAsFixed(4)}_${longitude.toStringAsFixed(4)}';

  /// Subtitle rapi yang menggabungkan wilayah/provinsi (admin1) dan negara.
  String get subtitle {
    final parts = <String>[];
    if (admin1 != null &&
        admin1!.trim().isNotEmpty &&
        admin1!.trim().toLowerCase() != name.trim().toLowerCase()) {
      parts.add(admin1!.trim());
    }
    if (country.trim().isNotEmpty) {
      parts.add(country.trim());
    }
    return parts.isEmpty ? 'Koordinat ${latitude.toStringAsFixed(2)}, ${longitude.toStringAsFixed(2)}' : parts.join(', ');
  }

  /// Label singkat untuk ditampilkan pada header Home Screen (Kota, Negara).
  String get headerLabel =>
      country.trim().isNotEmpty ? '$name, $country' : name;

  /// Parsing JSON dari respons Open-Meteo Geocoding API maupun Local Storage.
  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] as String?)?.trim() ?? 'Unknown',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      country: (json['country'] as String?)?.trim() ?? '',
      countryCode: json['country_code'] as String?,
      admin1: json['admin1'] as String?,
      timezone: json['timezone'] as String?,
    );
  }

  /// Konversi objek menjadi Map JSON untuk disimpan di SharedPreferences.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'country': country,
      'country_code': countryCode,
      'admin1': admin1,
      'timezone': timezone,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationModel &&
          runtimeType == other.runtimeType &&
          uniqueKey == other.uniqueKey;

  @override
  int get hashCode => uniqueKey.hashCode;
}
