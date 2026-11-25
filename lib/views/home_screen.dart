import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/location_model.dart';
import '../models/weather_model.dart';
import '../theme/app_theme.dart';
import '../viewmodels/location_viewmodel.dart';
import '../viewmodels/weather_viewmodel.dart';
import '../widgets/hero_weather_card.dart';
import '../widgets/metric_card.dart';
import '../widgets/neumorphic_card.dart';
import '../widgets/state_feedback_view.dart';
import '../widgets/weekly_forecast_card.dart';
import 'search_screen.dart';

/// Screen Utama (Home / Weather Screen) menggunakan `StatelessWidget` karena
/// seluruh state cuaca dan lokasi dikelola secara reaktif oleh ViewModel (Provider).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _openSearchScreen(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const SearchScreen(),
      ),
    );
  }

  String _windDescription(double speed) {
    if (speed < 6) return 'Angin tenang';
    if (speed < 20) return 'Angin sepoi lembut';
    if (speed < 38) return 'Angin sedang';
    return 'Angin cukup kencang';
  }

  String _precipitationDescription(double mm) {
    if (mm <= 0) return 'Tidak ada hujan saat ini';
    if (mm < 2.5) return 'Intensitas ringan';
    if (mm < 10) return 'Intensitas sedang';
    return 'Curah hujan tinggi';
  }

  @override
  Widget build(BuildContext context) {
    final weatherVM = context.watch<WeatherViewModel>();
    final locationVM = context.watch<LocationViewModel>();
    final activeLocation = weatherVM.selectedLocation;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppTheme.primaryEnd,
          backgroundColor: AppTheme.cardSurface,
          onRefresh: () => context.read<WeatherViewModel>().refreshWeather(),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // 1. Header Lokasi Aktif + Navigasi Search & Refresh
                          _buildHeader(
                            context: context,
                            activeLocation: activeLocation,
                            isRefreshing: weatherVM.isRefreshing ||
                                weatherVM.state == WeatherLoadState.loading,
                            isFavorite: activeLocation != null &&
                                locationVM.isFavorite(activeLocation),
                          ),

                          // Quick-access chips bila pengguna memiliki kota favorit
                          if (locationVM.favorites.isNotEmpty) ...[
                            const SizedBox(height: 14),
                            _buildFavoriteQuickStrip(
                              context,
                              locationVM.favorites,
                              activeLocation,
                            ),
                          ],
                          const SizedBox(height: 20),

                          // 2. Konten Utama berdasarkan State (Loading / Empty / Error / Loaded)
                          _buildBodyByState(context, weatherVM),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader({
    required BuildContext context,
    required LocationModel? activeLocation,
    required bool isRefreshing,
    required bool isFavorite,
  }) {
    final cityName = activeLocation?.name ?? 'Memuat Lokasi...';
    final countrySubtitle =
        activeLocation?.subtitle ?? 'Open-Meteo Weather Forecast';

    return Row(
      children: [
        // Area nama kota aktif (bisa diketuk untuk langsung mengganti kota)
        Expanded(
          child: InkWell(
            onTap: () => _openSearchScreen(context),
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      shape: BoxShape.circle,
                      boxShadow: AppTheme.primaryGlowShadows,
                    ),
                    child: const Icon(
                      Icons.location_on_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                cityName,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ),
                            if (isFavorite) ...[
                              const SizedBox(width: 5),
                              const Icon(
                                Icons.star_rounded,
                                size: 18,
                                color: AppTheme.secondaryEnd,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 1),
                        Text(
                          countrySubtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Tombol Navigasi ke Search / Location Screen
        NeumorphicIconButton(
          icon: Icons.search_rounded,
          tooltip: 'Cari Kota & Favorit',
          iconColor: AppTheme.primaryEnd,
          onPressed: () => _openSearchScreen(context),
        ),
        const SizedBox(width: 10),

        // Tombol Refresh Data Cuaca Real-Time
        NeumorphicIconButton(
          icon: Icons.refresh_rounded,
          tooltip: 'Perbarui Data Cuaca',
          iconColor: AppTheme.textPrimary,
          isSpinning: isRefreshing,
          onPressed: isRefreshing
              ? null
              : () => context.read<WeatherViewModel>().refreshWeather(),
        ),
      ],
    );
  }

  Widget _buildFavoriteQuickStrip(
    BuildContext context,
    List<LocationModel> favorites,
    LocationModel? activeLocation,
  ) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: favorites.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = favorites[index];
          final isSelected =
              activeLocation != null && activeLocation.uniqueKey == item.uniqueKey;

          return GestureDetector(
            onTap: () {
              if (!isSelected) {
                context.read<WeatherViewModel>().selectLocation(item);
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                gradient: isSelected ? AppTheme.primaryGradient : null,
                color: isSelected ? null : AppTheme.cardSurface,
                borderRadius: BorderRadius.circular(999),
                boxShadow: isSelected
                    ? AppTheme.primaryGlowShadows
                    : AppTheme.softSmallShadows,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.star_rounded,
                    size: 14,
                    color: isSelected ? Colors.white : AppTheme.secondaryEnd,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    item.name,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.textPrimary,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBodyByState(BuildContext context, WeatherViewModel weatherVM) {
    switch (weatherVM.state) {
      case WeatherLoadState.initial:
      case WeatherLoadState.loading:
        return Padding(
          padding: const EdgeInsets.only(top: 36),
          child: StateFeedbackView.loading(
            title: 'Memuat Informasi Cuaca...',
            message:
                'Mengambil data cuaca terkini dan perkiraan mingguan dari Open-Meteo API.',
          ),
        );

      case WeatherLoadState.empty:
        return Padding(
          padding: const EdgeInsets.only(top: 36),
          child: StateFeedbackView.empty(
            title: 'Belum Ada Lokasi Dipilih',
            message:
                'Silakan cari dan pilih nama kota terlebih dahulu untuk menampilkan cuaca terkini.',
            actionLabel: 'CARI KOTA',
            onAction: () => _openSearchScreen(context),
          ),
        );

      case WeatherLoadState.error:
        return Padding(
          padding: const EdgeInsets.only(top: 36),
          child: StateFeedbackView.error(
            title: 'Gagal Memuat Cuaca',
            message: weatherVM.errorMessage ??
                'Terjadi gangguan saat menghubungi server cuaca.',
            onRetry: () => context.read<WeatherViewModel>().refreshWeather(),
          ),
        );

      case WeatherLoadState.loaded:
        final weather = weatherVM.weatherData!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero Weather Card
            HeroWeatherCard(weather: weather),
            const SizedBox(height: 22),

            // Judul Section Detail Metrics
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 12),
              child: Text(
                'Detail Kondisi Udara',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            // Detail Metrics Grid (Responsif untuk Mobile & Layar Lebar)
            _buildResponsiveMetricsGrid(weather),
            const SizedBox(height: 22),

            // Weekly Forecast Card (Perkiraan beberapa hari ke depan)
            WeeklyForecastCard(forecasts: weather.daily),
          ],
        );
    }
  }

  Widget _buildResponsiveMetricsGrid(WeatherData weather) {
    final current = weather.current;
    final rainChance = weather.todayPrecipitationProbability;

    final humidityCard = HumidityMetricCard(
      humidityPercent: current.relativeHumidity2m,
    );
    final windCard = WeatherMetricCard(
      title: 'Kecepatan Angin',
      value: current.windSpeed10m.toStringAsFixed(1),
      unit: 'km/h',
      subtitle: _windDescription(current.windSpeed10m),
      icon: Icons.air_rounded,
    );
    final precipCard = WeatherMetricCard(
      title: 'Curah Hujan',
      value: current.precipitation.toStringAsFixed(1),
      unit: 'mm',
      subtitle: _precipitationDescription(current.precipitation),
      icon: Icons.grain_rounded,
    );
    final rainProbCard = WeatherMetricCard(
      title: 'Peluang Hujan',
      value: '$rainChance',
      unit: '%',
      subtitle: 'Maksimum hari ini',
      icon: Icons.umbrella_rounded,
      progressFraction: rainChance / 100.0,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        // Pada layar lebar/tablet (>= 620px), tampilkan 4 kolom sejajar
        if (constraints.maxWidth >= 620) {
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: humidityCard),
                const SizedBox(width: 14),
                Expanded(child: windCard),
                const SizedBox(width: 14),
                Expanded(child: precipCard),
                const SizedBox(width: 14),
                Expanded(child: rainProbCard),
              ],
            ),
          );
        }

        // Pada layar smartphone standar, tampilkan grid 2x2 bebas overflow
        return Column(
          children: [
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: humidityCard),
                  const SizedBox(width: 14),
                  Expanded(child: windCard),
                ],
              ),
            ),
            const SizedBox(height: 14),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: precipCard),
                  const SizedBox(width: 14),
                  Expanded(child: rainProbCard),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
