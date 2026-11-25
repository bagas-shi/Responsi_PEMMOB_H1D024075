/// Kategori visual kondisi cuaca untuk menentukan komposisi ikon Soft UI.
enum WeatherVisualType {
  clearSunny,
  partlyCloudy,
  cloudy,
  foggy,
  drizzle,
  rain,
  snow,
  thunderstorm,
}

/// Representasi kondisi cuaca berdasarkan standar WMO Weather Interpretation Codes
/// yang dikembalikan oleh field `weather_code` dari Open-Meteo API.
class WeatherConditionInfo {
  final int code;
  final String label;
  final String description;
  final WeatherVisualType visualType;

  const WeatherConditionInfo({
    required this.code,
    required this.label,
    required this.description,
    required this.visualType,
  });

  /// Mapping kode WMO (0 - 99) menjadi deskripsi kondisi cuaca dan tipe ikon.
  factory WeatherConditionInfo.fromWmoCode(int code) {
    switch (code) {
      case 0:
        return WeatherConditionInfo(
          code: code,
          label: 'Cerah',
          description: 'Langit cerah tanpa awan',
          visualType: WeatherVisualType.clearSunny,
        );
      case 1:
        return WeatherConditionInfo(
          code: code,
          label: 'Dominan Cerah',
          description: 'Sebagian besar langit cerah',
          visualType: WeatherVisualType.clearSunny,
        );
      case 2:
        return WeatherConditionInfo(
          code: code,
          label: 'Cerah Berawan',
          description: 'Matahari bersinar diselingi awan lembut',
          visualType: WeatherVisualType.partlyCloudy,
        );
      case 3:
        return WeatherConditionInfo(
          code: code,
          label: 'Berawan',
          description: 'Langit tertutup awan merata',
          visualType: WeatherVisualType.cloudy,
        );
      case 45:
      case 48:
        return WeatherConditionInfo(
          code: code,
          label: 'Berkabut',
          description: 'Kabut lembut menyelimuti udara',
          visualType: WeatherVisualType.foggy,
        );
      case 51:
      case 53:
      case 55:
      case 56:
      case 57:
        return WeatherConditionInfo(
          code: code,
          label: 'Gerimis',
          description: 'Rintik hujan ringan di udara',
          visualType: WeatherVisualType.drizzle,
        );
      case 61:
      case 80:
        return WeatherConditionInfo(
          code: code,
          label: 'Hujan Ringan',
          description: 'Turun hujan berintensitas ringan',
          visualType: WeatherVisualType.rain,
        );
      case 63:
      case 81:
        return WeatherConditionInfo(
          code: code,
          label: 'Hujan Sedang',
          description: 'Curah hujan intensitas sedang',
          visualType: WeatherVisualType.rain,
        );
      case 65:
      case 66:
      case 67:
      case 82:
        return WeatherConditionInfo(
          code: code,
          label: 'Hujan Lebat',
          description: 'Guyuran hujan deras, siapkan payung',
          visualType: WeatherVisualType.rain,
        );
      case 71:
      case 73:
      case 75:
      case 77:
      case 85:
      case 86:
        return WeatherConditionInfo(
          code: code,
          label: 'Bersalju',
          description: 'Butiran salju turun di wilayah ini',
          visualType: WeatherVisualType.snow,
        );
      case 95:
      case 96:
      case 99:
        return WeatherConditionInfo(
          code: code,
          label: 'Badai Petir',
          description: 'Hujan disertai kilat dan gemuruh petir',
          visualType: WeatherVisualType.thunderstorm,
        );
      default:
        return WeatherConditionInfo(
          code: code,
          label: 'Berawan',
          description: 'Kondisi atmosfer berubah-ubah',
          visualType: WeatherVisualType.partlyCloudy,
        );
    }
  }
}
