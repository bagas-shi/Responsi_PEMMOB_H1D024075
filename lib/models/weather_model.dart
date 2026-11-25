import 'weather_condition.dart';

/// Model data cuaca saat ini (`current`) dari Open-Meteo Weather Forecast API.
/// Memuat seluruh field wajib: suhu saat ini, kelembapan, suhu dirasakan,
/// curah hujan, kode kondisi cuaca, dan kecepatan angin.
class CurrentWeather {
  final DateTime time;
  final double temperature2m;
  final int relativeHumidity2m;
  final double apparentTemperature;
  final double precipitation;
  final int weatherCode;
  final double windSpeed10m;

  const CurrentWeather({
    required this.time,
    required this.temperature2m,
    required this.relativeHumidity2m,
    required this.apparentTemperature,
    required this.precipitation,
    required this.weatherCode,
    required this.windSpeed10m,
  });

  /// Informasi deskripsi dan tipe ikon hasil konversi `weather_code`.
  WeatherConditionInfo get condition =>
      WeatherConditionInfo.fromWmoCode(weatherCode);

  /// Parsing objek `current` dari JSON respons Open-Meteo.
  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    final rawTime = json['time'] as String?;
    return CurrentWeather(
      time: rawTime != null
          ? (DateTime.tryParse(rawTime) ?? DateTime.now())
          : DateTime.now(),
      temperature2m: (json['temperature_2m'] as num?)?.toDouble() ?? 0.0,
      relativeHumidity2m:
          (json['relative_humidity_2m'] as num?)?.toInt() ?? 0,
      apparentTemperature:
          (json['apparent_temperature'] as num?)?.toDouble() ?? 0.0,
      precipitation: (json['precipitation'] as num?)?.toDouble() ?? 0.0,
      weatherCode: (json['weather_code'] as num?)?.toInt() ?? 0,
      windSpeed10m: (json['wind_speed_10m'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// Model perkiraan cuaca harian (`daily`) dari Open-Meteo Weather Forecast API.
/// Memuat tanggal, kode cuaca harian, suhu maks, suhu min, dan peluang hujan maks.
class DailyForecast {
  final DateTime date;
  final int weatherCode;
  final double temperatureMax;
  final double temperatureMin;
  final int precipitationProbabilityMax;

  const DailyForecast({
    required this.date,
    required this.weatherCode,
    required this.temperatureMax,
    required this.temperatureMin,
    required this.precipitationProbabilityMax,
  });

  WeatherConditionInfo get condition =>
      WeatherConditionInfo.fromWmoCode(weatherCode);

  /// Singkatan hari 2 huruf (`Su`, `Mo`, `Tu`, `We`, `Th`, `Fr`, `Sa`)
  /// untuk tampilan Weekly Forecast Card yang minimalis.
  String get shortDayCode {
    const codes = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
    return codes[date.weekday - 1];
  }

  /// Nama hari dalam Bahasa Indonesia untuk konteks tambahan.
  String get dayNameIndo {
    const names = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    return names[date.weekday - 1];
  }
}

/// Model agregat respons utama Open-Meteo Weather Forecast API (`current` + `daily`).
class WeatherData {
  final double latitude;
  final double longitude;
  final String timezone;
  final String timezoneAbbreviation;
  final CurrentWeather current;
  final List<DailyForecast> daily;
  final DateTime fetchedAt;

  const WeatherData({
    required this.latitude,
    required this.longitude,
    required this.timezone,
    required this.timezoneAbbreviation,
    required this.current,
    required this.daily,
    required this.fetchedAt,
  });

  /// Peluang hujan maksimum hari ini (diambil dari elemen pertama `daily`).
  int get todayPrecipitationProbability =>
      daily.isNotEmpty ? daily.first.precipitationProbabilityMax : 0;

  double? get todayMaxTemp =>
      daily.isNotEmpty ? daily.first.temperatureMax : null;

  double? get todayMinTemp =>
      daily.isNotEmpty ? daily.first.temperatureMin : null;

  /// Parsing keseluruhan JSON dari `https://api.open-meteo.com/v1/forecast`.
  /// Open-Meteo mengirimkan data `daily` dalam bentuk parallel arrays, sehingga
  /// fungsi ini menggabungkannya per indeks menjadi `List<DailyForecast>`.
  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final currentMap =
        (json['current'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    final dailyMap =
        (json['daily'] as Map<String, dynamic>?) ?? <String, dynamic>{};

    final times = (dailyMap['time'] as List<dynamic>?) ?? const [];
    final codes = (dailyMap['weather_code'] as List<dynamic>?) ?? const [];
    final maxTemps =
        (dailyMap['temperature_2m_max'] as List<dynamic>?) ?? const [];
    final minTemps =
        (dailyMap['temperature_2m_min'] as List<dynamic>?) ?? const [];
    final precipProbs =
        (dailyMap['precipitation_probability_max'] as List<dynamic>?) ??
            const [];

    final dailyList = <DailyForecast>[];
    for (var i = 0; i < times.length; i++) {
      final parsedDate = DateTime.tryParse(times[i].toString()) ??
          DateTime.now().add(Duration(days: i));
      dailyList.add(
        DailyForecast(
          date: parsedDate,
          weatherCode:
              i < codes.length ? ((codes[i] as num?)?.toInt() ?? 0) : 0,
          temperatureMax: i < maxTemps.length
              ? ((maxTemps[i] as num?)?.toDouble() ?? 0.0)
              : 0.0,
          temperatureMin: i < minTemps.length
              ? ((minTemps[i] as num?)?.toDouble() ?? 0.0)
              : 0.0,
          precipitationProbabilityMax: i < precipProbs.length
              ? ((precipProbs[i] as num?)?.toInt() ?? 0)
              : 0,
        ),
      );
    }

    return WeatherData(
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      timezone: (json['timezone'] as String?) ?? 'auto',
      timezoneAbbreviation: (json['timezone_abbreviation'] as String?) ?? '',
      current: CurrentWeather.fromJson(currentMap),
      daily: dailyList,
      fetchedAt: DateTime.now(),
    );
  }
}
