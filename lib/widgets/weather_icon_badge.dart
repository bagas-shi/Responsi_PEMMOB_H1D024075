import 'package:flutter/material.dart';

import '../models/weather_condition.dart';
import '../theme/app_theme.dart';

/// Komponen ikon cuaca Soft UI berlapis warna cerah dan lembut
/// (matahari kuning hangat, awan biru langit, tetesan hujan cyan, petir emas)
/// di dalam container halus.
class WeatherIconBadge extends StatelessWidget {
  final WeatherVisualType visualType;
  final double size;
  final bool onHeroGradient;

  const WeatherIconBadge({
    super.key,
    required this.visualType,
    this.size = 56,
    this.onHeroGradient = false,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(size * 0.34);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: onHeroGradient
            ? Colors.white.withValues(alpha: 0.20)
            : AppTheme.recessedSurface,
        borderRadius: borderRadius,
        border: Border.all(
          color: onHeroGradient
              ? Colors.white.withValues(alpha: 0.35)
              : Colors.white.withValues(alpha: 0.9),
          width: 1.2,
        ),
        boxShadow: onHeroGradient ? null : AppTheme.softSmallShadows,
      ),
      child: Center(
        child: SizedBox(
          width: size * 0.68,
          height: size * 0.68,
          child: _buildLayeredWeatherArtwork(),
        ),
      ),
    );
  }

  Widget _buildLayeredWeatherArtwork() {
    final cloudColor =
        onHeroGradient ? Colors.white : const Color(0xFF4FC3F7);
    final dropColor =
        onHeroGradient ? const Color(0xFFE0F7FA) : const Color(0xFF0288D1);

    switch (visualType) {
      case WeatherVisualType.clearSunny:
        return Center(
          child: Container(
            width: size * 0.46,
            height: size * 0.46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppTheme.secondaryGradient,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.secondaryEnd.withValues(alpha: 0.45),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Icon(
              Icons.wb_sunny_rounded,
              size: size * 0.30,
              color: Colors.white,
            ),
          ),
        );

      case WeatherVisualType.partlyCloudy:
        return Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Positioned(
              top: size * 0.02,
              right: size * 0.04,
              child: Container(
                width: size * 0.30,
                height: size * 0.30,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppTheme.secondaryGradient,
                ),
              ),
            ),
            Positioned(
              bottom: size * 0.02,
              left: size * 0.02,
              child: Icon(
                Icons.cloud_rounded,
                size: size * 0.48,
                color: cloudColor,
              ),
            ),
          ],
        );

      case WeatherVisualType.cloudy:
        return Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: size * 0.05,
              right: size * 0.04,
              child: Icon(
                Icons.cloud_rounded,
                size: size * 0.36,
                color: cloudColor.withValues(alpha: 0.55),
              ),
            ),
            Positioned(
              bottom: size * 0.04,
              left: size * 0.04,
              child: Icon(
                Icons.cloud_rounded,
                size: size * 0.46,
                color: cloudColor,
              ),
            ),
          ],
        );

      case WeatherVisualType.foggy:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_rounded,
              size: size * 0.36,
              color: cloudColor,
            ),
            const SizedBox(height: 2),
            Icon(
              Icons.dehaze_rounded,
              size: size * 0.24,
              color: onHeroGradient
                  ? Colors.white.withValues(alpha: 0.85)
                  : AppTheme.textSecondary,
            ),
          ],
        );

      case WeatherVisualType.drizzle:
      case WeatherVisualType.rain:
        return Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: size * 0.02,
              child: Icon(
                Icons.cloud_rounded,
                size: size * 0.44,
                color: cloudColor,
              ),
            ),
            Positioned(
              bottom: size * 0.02,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.water_drop_rounded,
                      size: size * 0.17, color: dropColor),
                  if (visualType == WeatherVisualType.rain) ...[
                    const SizedBox(width: 2),
                    Icon(Icons.water_drop_rounded,
                        size: size * 0.19, color: dropColor),
                  ],
                ],
              ),
            ),
          ],
        );

      case WeatherVisualType.snow:
        return Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: size * 0.02,
              child: Icon(
                Icons.cloud_rounded,
                size: size * 0.42,
                color: cloudColor,
              ),
            ),
            Positioned(
              bottom: size * 0.01,
              child: Icon(
                Icons.ac_unit_rounded,
                size: size * 0.22,
                color: dropColor,
              ),
            ),
          ],
        );

      case WeatherVisualType.thunderstorm:
        return Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: size * 0.01,
              child: Icon(
                Icons.cloud_rounded,
                size: size * 0.44,
                color: cloudColor,
              ),
            ),
            Positioned(
              bottom: 0,
              child: Icon(
                Icons.bolt_rounded,
                size: size * 0.30,
                color: AppTheme.secondaryStart,
              ),
            ),
          ],
        );
    }
  }
}
